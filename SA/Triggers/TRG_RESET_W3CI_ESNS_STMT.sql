CREATE OR REPLACE TRIGGER sa."TRG_RESET_W3CI_ESNS_STMT"
  --
  ---------------------------------------------------------------------------------------------
  --$RCSfile: trg_reset_w3ci_esns_stmt.sql,v $
  --$Revision: 1.5 $
  --$Author: vnainar $
  --$Date: 2017/01/10 22:54:53 $
  --$ $Log: trg_reset_w3ci_esns_stmt.sql,v $
  --$ Revision 1.5  2017/01/10 22:54:53  vnainar
  --$ CR46581 merged with production version
  --$
  --$ Revision 1.4  2016/11/28 16:16:44  skota
  --$ added carrier name while calling throttling valve
  --$
  --$ Revision 1.2  2015/08/31 21:21:53  aganesan
  --$ CR37016 changes.
  --$
  --$ Revision 1.1  2015/08/04 14:18:05  jpena
  --$ Changes
  --$
  --$ Revision 1.1  2015/08/04 11:49:58  jpena
  --$ Trigger to process w3ci esns
  --$
  --$
  --$
  ---------------------------------------------------------------------------------------------
  --
AFTER INSERT OR UPDATE ON sa.x_account_group_member
DISABLE DECLARE


  -- Get all the active members when the master is throttled
  CURSOR master_curs ( p_esn IN VARCHAR2) IS
    SELECT tc.x_policy_id,
           tp.x_policy_name,
           ( SELECT pi_min.part_serial_no
             FROM   table_part_inst pi_esn,
                    table_part_inst pi_min
             WHERE  pi_esn.part_serial_no = p_esn
             AND    pi_esn.x_domain = 'PHONES'
             AND    pi_min.part_to_esn2part_inst = pi_esn.objid
             AND    pi_min.x_domain = 'LINES'
             AND    ROWNUM = 1
           ) min
    FROM   x_account_group_member agm,
           x_account_group_member agm2,
           w3ci.table_x_throttling_cache tc,
           w3ci.table_x_throttling_policy tp
    WHERE  1 = 1
    AND    agm.esn = p_esn
    AND    agm2.account_group_id = agm.account_group_id
    AND    agm2.master_flag = 'Y'
    AND    UPPER(agm2.status) <> 'EXPIRED'
    AND    tc.x_esn = agm2.esn
    AND    tc.x_status IN ('P','A')
    AND    tp.objid = tc.x_policy_id;
  --
  master_rec      master_curs%ROWTYPE;


  -- Declaration of local variables for error handling.
  l_error_code    NUMBER := 0;
  l_error_message VARCHAR2(300):= NULL;
  c sa.customer_type := sa.customer_type();

BEGIN -- Trigger Main Section Starts
  --DBMS_OUTPUT.PUT_LINE('start of stmt');

   -- Go Smart changes
 -- Do not fire trigger if global variable is turned off
  if not sa.globals_pkg.g_run_my_trigger then
    return;
  end if;
-- End Go Smart changes

  sa.globals_pkg.g_perform_commit := FALSE;

  -- Loop through ESNs
  FOR i IN ( SELECT * FROM sa.gtt_reset_w3ci_esns ORDER BY insert_timestamp ) LOOP

    --DBMS_OUTPUT.PUT_LINE('after re-inserting inv cache');

    IF i.min IS NULL OR i.min LIKE 'T%' THEN
      -- Get the MIN
      BEGIN
        SELECT pi_min.part_serial_no min
        INTO   i.min
        FROM   table_part_inst pi_esn,
               table_part_inst pi_min
        WHERE  1 = 1
        AND    pi_esn.part_serial_no = i.esn
        AND    pi_esn.x_domain = 'PHONES'
        AND    pi_min.part_to_esn2part_inst = pi_esn.objid
        AND    pi_min.x_domain = 'LINES'
        AND    ROWNUM = 1;
       EXCEPTION
         WHEN no_data_found THEN
           BEGIN
             SELECT x_min
             INTO   i.min
             FROM   table_site_part
             WHERE  x_service_id = i.esn
             AND    part_status||'' = 'Active';
            EXCEPTION
              WHEN others THEN
                NULL;
           END;
         WHEN others THEN
           NULL;
      END;
    END IF;

    IF i.min LIKE 'T%' THEN
      i.min := NULL;
    END IF;

    -- Get all the active members when the master is throttled
    OPEN master_curs ( i.esn );
    FETCH master_curs INTO master_rec;
    IF master_curs%FOUND THEN
      CLOSE master_curs;

      --getting the parent name
      c.parent_name := c.get_parent_name(i_esn => i.esn);

      -- Throttle the member when the master is throttled
      w3ci.throttling.sp_throttling_valve ( p_min             => i.min,
                                            p_esn             => i.esn,
                                            p_policy_name     => master_rec.x_policy_name,
                                            p_creation_date   => NULL,
                                            p_transaction_num => 'ActGroupTrig',
                                            p_error_code      => l_error_code,
                                            p_error_message   => l_error_message,
                                            p_usage           => NULL,
                                            p_bypass_off      => NULL ,
                                            p_parent_name     => c.parent_name);

      --DBMS_OUTPUT.PUT_LINE('after calling sp_throttling_valve => code: ' || l_error_code || ' | msg: ' || l_error_message);


    ELSE
      CLOSE master_curs;

      --DBMS_OUTPUT.PUT_LINE('before calling sp_expire_cache');

      -- Unthrottle the member when the master is NOT throttled
      w3ci.throttling.sp_expire_cache ( p_min           => i.min,
                                        p_esn           => i.esn,
                                        p_error_code    => l_error_code,
                                        p_error_message => l_error_message,
                                        p_bypass_off    => NULL,
                                        p_source        => 'ActGroupTrig' );

      --DBMS_OUTPUT.PUT_LINE('after calling sp_expire_cache => code: ' || l_error_code || ' | msg: ' || l_error_message);

    END IF; -- IF master_curs%FOUND THEN

    --DBMS_OUTPUT.PUT_LINE('before delete global temporary row');

    -- Delete global temporary row
    DELETE sa.gtt_reset_w3ci_esns WHERE esn = i.esn;

    --DBMS_OUTPUT.PUT_LINE('after delete global temporary row');

  END LOOP; -- Ending the if loop for completed condition check.

  --DBMS_OUTPUT.PUT_LINE('before delete the complete GTT');

  sa.globals_pkg.g_perform_commit := TRUE;

 EXCEPTION
   WHEN others THEN
     --
     --DBMS_OUTPUT.PUT_LINE('error in stmt => ' || SQLERRM);
     -- Do not fail if there are exceptions
     sa.globals_pkg.g_perform_commit := TRUE;
END;
/