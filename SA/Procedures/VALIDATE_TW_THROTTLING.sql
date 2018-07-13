CREATE OR REPLACE PROCEDURE sa."VALIDATE_TW_THROTTLING" ( i_esn       IN  VARCHAR2 ,
                                                        o_response  OUT VARCHAR2 ) IS

  --
  ---------------------------------------------------------------------------------------------
  --$RCSfile: validate_tw_throttling.sql,v $
  --$Revision: 1.7 $
  --$Author: skota $
  --$Date: 2017/01/30 22:30:43 $
  --$ $Log: validate_tw_throttling.sql,v $
  --$ Revision 1.7  2017/01/30 22:30:43  skota
  --$ removed the TTOFF check if the group is not been throttled
  --$
  --$ Revision 1.6  2016/11/28 20:11:11  skota
  --$ added carrier name while calling the throttling valve
  --$
  --$ Revision 1.5  2016/08/29 18:17:34  ddudhankar
  --$ CR44514 - TTOFF logic corrected
  --$
  --$ Revision 1.4  2016/08/29 16:09:10  ddudhankar
  --$ CR44514 - Changes to the logic to identify throttling transactions
  --$
  --$ Revision 1.3  2016/08/09 21:02:21  jpena
  --$ Modify logic on procedure validate_tw_throttling to add check for the ESN being processed. If ESN/MIN combination is currently TTON or TTOFF already (it is in the same status that the action to be taken) DO NOT take any action.
  --$
  --$ Revision 1.2  2015/08/31 21:16:38  aganesan
  --$ CR37016 changes.
  --$
  --$ Revision 1.1  2015/08/04 14:18:05  jpena
  --$ Changes
  --$
  --$ Revision 1.1  2015/08/04 11:49:58  jpena
  --$ Stored Procedure to process TW throttling
  --$
  --$
  --$
  ---------------------------------------------------------------------------------------------
  --

  c  customer_type := customer_type();
  n_exists            NUMBER := 0;
  n_err_code          NUMBER := 0;
  c_err_msg           VARCHAR2(300) := NULL;

  -- find out if the esn's group master is throttled
  CURSOR master_curs IS
    SELECT tc.x_policy_id,
           tp.x_policy_name
    FROM   x_account_group_member agm,
           x_account_group_member agm2,
           w3ci.table_x_throttling_cache tc,
           w3ci.table_x_throttling_policy tp
    WHERE  1 = 1
    AND    agm.esn = i_esn
    AND    agm2.account_group_id = agm.account_group_id
    AND    agm2.master_flag = 'Y'
    AND    UPPER(agm2.status) <> 'EXPIRED'
    AND    tc.x_esn = agm2.esn
    AND    tc.x_status IN ('P','A')
    AND    tp.objid = tc.x_policy_id;

  --
  master_rec  master_curs%ROWTYPE;

BEGIN

  -- block commits in w3ci.throttling package
  sa.globals_pkg.g_perform_commit := FALSE;

  -- set esn
  c.esn := i_esn;

  -- if the esn is not passed
  IF c.esn IS NULL THEN
    o_response := 'ESN INPUT PARAM CANNOT BE PASSED AS BLANK';
    sa.globals_pkg.g_perform_commit := TRUE;
    RETURN;
  END IF;

  -- validate if the esn is part of a shared group brand
  IF NVL(c.get_shared_group_flag ( i_esn => c.esn  ),'N') = 'N'
  THEN
    o_response := 'ESN DOES NOT BELONG TO A SHARED GROUP';
    sa.globals_pkg.g_perform_commit := TRUE;
    RETURN;
  END IF;

  -- get the account group id
  BEGIN
    SELECT account_group_id
    INTO   c.account_group_objid
    FROM   x_account_group_member
    WHERE  1 = 1
    AND    esn = c.esn
    AND    UPPER(status) <> 'EXPIRED'
    AND    ROWNUM = 1;
   EXCEPTION
  WHEN others THEN
    o_response := 'GROUP ID NOT FOUND';
    sa.globals_pkg.g_perform_commit := TRUE;
    RETURN;
  END;

  -- get the min
  BEGIN
    SELECT pi_min.part_serial_no min
    INTO   c.min
    FROM   table_part_inst pi_esn,
           table_part_inst pi_min
    WHERE  1 = 1
    AND    pi_esn.part_serial_no = c.esn
    AND    pi_esn.x_domain = 'PHONES'
    AND    pi_min.part_to_esn2part_inst = pi_esn.objid
    AND    pi_min.x_domain = 'LINES'
    AND    ROWNUM = 1;
   EXCEPTION
     WHEN no_data_found THEN
       -- get the min from active site part
       BEGIN
         SELECT x_min
         INTO   c.min
         FROM   table_site_part
         WHERE  x_service_id = c.esn
         AND    part_status||'' = 'Active';
        EXCEPTION
          WHEN others THEN
            NULL;
       END;
     WHEN others THEN
       NULL;
  END;

  -- if the min is temporary
  IF c.min LIKE 'T%' THEN
    c.min := NULL;
  END IF;

  -- enter only when the min is available
  IF c.min IS NOT NULL THEN

    -- get the active members when the master is throttled
    OPEN master_curs;
    FETCH master_curs INTO master_rec;
    IF master_curs%FOUND THEN
      CLOSE master_curs;
      -- find out if the esn/min combination is already throttled
      BEGIN
        SELECT COUNT(1)
        INTO   n_exists
        FROM   DUAL
        WHERE  EXISTS ( SELECT 1
                        FROM   w3ci.table_x_throttling_cache tc,
                               w3ci.table_x_throttling_policy tp
                        WHERE  1 = 1
                        AND    tc.x_esn = c.esn
                        AND    tc.x_min = c.min
                        AND    tc.x_status IN ('P','A')
                        AND    tp.objid = tc.x_policy_id
                        AND    EXISTS ( SELECT 1
                                        FROM   w3ci.table_x_throttling_transaction
                                        WHERE  x_esn = tc.x_esn
                                        AND    x_min = tc.x_min
                                        AND    x_transact_type = 'TTON'
                                      )
                     );
       EXCEPTION
         WHEN others THEN
           NULL;
      END;
      -- if the esn/min combination is not throttled
      IF NVL(n_exists,0) = 0 THEN

        --get the carrier name for the esn
        c.parent_name := c.get_parent_name(i_esn => c.esn);

        -- throttle the member when the master is throttled
        w3ci.throttling.sp_throttling_valve ( p_min             => c.min,
                                              p_esn             => c.esn,
                                              p_policy_name     => master_rec.x_policy_name,
                                              p_creation_date   => NULL,
                                              p_transaction_num => 'UPDATE_MEMBER',
                                              p_error_code      => n_err_code,
                                              p_error_message   => c_err_msg,
                                              p_usage           => NULL,
                                              p_bypass_off      => NULL ,
											                        p_parent_name     => c.parent_name);

      END IF; -- if the esn/min combination is not throttled

    ELSE
      -- close cursor
      CLOSE master_curs;

      -- set exist variable as zero
      n_exists := 0;

      -- find out if the esn/min combination is already throttled
      BEGIN
        SELECT COUNT(1)
        INTO   n_exists
        FROM   DUAL
        WHERE  EXISTS ( SELECT 1
                        FROM   w3ci.table_x_throttling_cache tc,
                               w3ci.table_x_throttling_policy tp
                        WHERE  1 = 1
                        AND    tc.x_esn = c.esn
                        AND    tc.x_min = c.min
                        AND    tc.x_status IN ('P','A')
                        AND    tp.objid = tc.x_policy_id
                        --AND    EXISTS ( SELECT 1
                        --                FROM   w3ci.table_x_throttling_transaction
                        --                WHERE  x_esn = tc.x_esn
                        --                AND    x_min = tc.x_min
                        --                AND    x_transact_type = 'TTOFF'
                        --              )
                     );
       EXCEPTION
         WHEN others THEN
           NULL;
      END;
      -- if the esn/min combination is throttled
      IF NVL(n_exists,0) > 0 THEN

        -- unthrottle the member when the master is not throttled
        w3ci.throttling.sp_expire_cache ( p_min           => c.min      ,
                                          p_esn           => c.esn      ,
                                          p_error_code    => n_err_code ,
                                          p_error_message => c_err_msg  ,
                                          p_bypass_off    => NULL       ,
                                          p_source        => 'UPDATE_MEMBER'  );

      END IF; -- if the esn/min combination is throttled

    END IF; -- IF master_curs%FOUND ...

  END IF; -- IF c.min IS NOT NULL ...

  -- set response as successful
  o_response := 'SUCCESS';

  -- set the global commit variable to true to allow default commits in w3ci.throttling package
  sa.globals_pkg.g_perform_commit := TRUE;

 EXCEPTION
   WHEN others THEN
     o_response := 'FAILED VALIDATE TW THROTTLING: ' || SUBSTR(SQLERRM,1,100);
     sa.globals_pkg.g_perform_commit := TRUE;
END;
/