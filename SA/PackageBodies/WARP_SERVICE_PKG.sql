CREATE OR REPLACE PACKAGE BODY sa.warp_service_pkg
/*******************************************************************************************************
  * --$RCSfile: warp_service_pkb.sql,v $
  --$Revision: 1.7 $
  --$Author: vnainar $
  --$Date: 2016/09/28 16:50:19 $
  --$ $Log: warp_service_pkb.sql,v $
  --$ Revision 1.7  2016/09/28 16:50:19  vnainar
  --$ CR44390 remove from account added for active phones
  --$
  --$ Revision 1.6  2016/09/28 10:30:59  vnainar
  --$ CR44390 deact_device procedure updated
  --$
  --$ Revision 1.5  2016/09/28 10:24:41  vnainar
  --$ CR44390 x_reccurring condition added
  --$
  --$ Revision 1.4  2016/09/19 22:00:57  mgovindarajan
  --$ CR44390 - Corrected Error Codes and changed a parameter to IN OUT
  --$
  --$ Revision 1.3  2016/09/16 23:13:35  vnainar
  --$ CR44390 new procedure added
  --$
  --$ Revision 1.2  2016/07/26 21:54:51  vnainar
  --$ CR43088 p_deact_service modified and 2 procedures removed
  --$
  --$ Revision 1.1  2016/07/07 23:11:14  smeganathan
  --$ CR43088 new package for warp2
  --$
  --$ Revision 1.1  2016/07/07  18:17:25  smeganathan
  --$ New package for WARP
  *
  * -----------------------------------------------------------------------------------------------------
*********************************************************************************************************/
AS
PROCEDURE p_get_phone_type
(
ip_esn		IN VARCHAR2,
op_phone_type	OUT VARCHAR2,
op_error_code   OUT NUMBER,
op_error_msg	OUT VARCHAR2
) AS

 rc     sa.customer_type  := customer_type ( i_esn => ip_esn );
 cst    sa.customer_type;
 l_simout_flag  VARCHAR2(1):='N';
BEGIN

 cst := rc.get_part_class_attributes(i_esn => ip_esn);

IF cst.response LIKE '%SUCCESS%' THEN

 --code block if it is simout device or not
    BEGIN
     SELECT 'Y'
     INTO l_simout_flag
     FROM simoutconfrules
     WHERE  phone_part_num =cst.esn_part_number
     AND rownum =1;
    EXCEPTION
     WHEN OTHERS THEN
       NULL;
    END;

     op_error_code := 0;
     op_error_msg  :='SUCCESS';

    IF l_simout_flag ='Y' THEN
     op_phone_type := 'SIM_OUT';
     RETURN;
    ELSIF cst.device_type ='BYOP' THEN
     op_phone_type := 'BYOP';
     RETURN;
    ELSE
     op_phone_type :='NOT SUPPORTED DEVICE';
     op_error_code := 100;
     op_error_msg  :='Device is neither BYOP nor SIM OUT';
    END IF;

ELSE

  op_phone_type :='ESN NOT FOUND';
  op_error_code := 200;
  op_error_msg  :='Device not found in Inventory';

END IF;

EXCEPTION
 WHEN OTHERS THEN
    op_error_code := sqlcode;
    op_error_msg  := sqlerrm;
END p_get_phone_type;
PROCEDURE p_get_web_user_attributes
(
ip_login_name	        IN VARCHAR2,
ip_bus_org_id           IN  VARCHAR2,
op_web_user_objid	OUT NUMBER,
op_error_code           OUT NUMBER,
op_error_msg	     OUT VARCHAR2
)
AS
 rc     sa.customer_type  := customer_type();
 cst    sa.customer_type;

BEGIN

cst     := rc.retrieve_login(i_login_name => ip_login_name,i_bus_org_id =>ip_bus_org_id);

IF (cst.response LIKE '%SUCCESS%') THEN
 op_web_user_objid := cst.web_user_objid;
 op_error_code := 0;
 op_error_msg  := 'SUCCESS';
 RETURN;
ELSE
   op_error_code := -100;
   op_error_msg  := cst.response;
 RETURN;

END IF;

EXCEPTION
 WHEN OTHERS THEN
    op_error_code := sqlcode;
    op_error_msg  := sqlerrm;
END p_get_web_user_attributes;
-- stored proc to deactivate an esn from clarify
PROCEDURE p_deact_service ( ip_sourcesystem   IN  VARCHAR2 ,
                            ip_esn            IN  VARCHAR2 ,
                            ip_web_user_objid IN  NUMBER   ,
                            ip_deactreason    IN  VARCHAR2 ,
                            op_error_code     OUT VARCHAR2 ,
                            op_error_msg      OUT VARCHAR2 ) AS

  n_user_objid      NUMBER;
  c_error_code      VARCHAR2(100);
  c_error_message   VARCHAR2(500);

  -- instantiate initial values
  rc   customer_type := customer_type ();
  cst  customer_type := customer_type ();
  mt   group_member_type := group_member_type();

BEGIN

  --
  IF ip_esn IS NULL THEN
    op_error_code := '-100';
    op_error_msg  := 'ESN is null';
    RETURN;
  END IF;

  -- get the min only if the line and esn are both active
  BEGIN
    SELECT pi_min.part_serial_no
    INTO   rc.min
    FROM   table_part_inst pi_min,
           table_part_inst pi_esn
    WHERE  pi_esn.part_serial_no = ip_esn
    AND    pi_esn.x_domain = 'PHONES'
    AND    pi_esn.objid = pi_min.part_to_esn2part_inst
    AND    pi_min.x_part_inst_status = '13' -- active line
    AND    pi_esn.x_part_inst_status = '52'; -- active esn
   EXCEPTION
     WHEN others THEN
       NULL;
  END;

  DBMS_OUTPUT.PUT_LINE('rc.min : ' || rc.min);

   cst := cst.retrieve ( i_esn => ip_esn );

       DBMS_OUTPUT.PUT_LINE('cst.response    : ' || cst.response);

    IF cst.response NOT LIKE '%SUCCESS%' THEN
      op_error_code	:= '-250';
      op_error_msg  := cst.response;
      RETURN;
    END IF;

  -- when the min is available (line is active)
  IF rc.min IS NOT NULL THEN
    -- get the user
    BEGIN
      SELECT objid
      INTO   n_user_objid
      FROM   table_user
      WHERE  s_login_name = (SELECT UPPER(USER) FROM DUAL);
    EXCEPTION
     WHEN OTHERS THEN
       -- default to SA objid
       n_user_objid := 268435556;
       RETURN;
    END;

    DBMS_OUTPUT.PUT_LINE('n_user_objid : ' || n_user_objid);

    -- call the original deactservice process when the line is active
    sa.service_deactivation_code.deactservice ( ip_sourcesystem    => ip_sourcesystem,
                                                ip_userobjid       => n_user_objid,
                                                ip_esn             => ip_esn,
                                                ip_min             => rc.min,
                                                ip_deactreason     => ip_deactreason,
                                                intbypassordertype => 0,
                                                ip_newesn          => NULL,
                                                ip_samemin         => 'true',
                                                op_return          => c_error_code,
                                                op_returnmsg       => c_error_message );

    DBMS_OUTPUT.PUT_LINE('c_error_code    : ' || c_error_code);
    DBMS_OUTPUT.PUT_LINE('c_error_message : ' || c_error_message);

    IF c_error_code <> 'true' THEN
      op_error_code := '-300';
      op_error_msg  := c_error_message;
       RETURN;
    END IF;

    -- exit the program

     IF cst.web_user_objid IS NOT NULL THEN
      -- remove the esn from the web account
      account_maintenance_pkg.remove_esn_from_account( ip_web_user_objid  => cst.web_user_objid ,
                                                       ip_esn             => ip_esn             ,
                                                       op_err_code        => c_error_code       ,
                                                       op_err_msg         => c_error_message    );

      DBMS_OUTPUT.PUT_LINE('c_error_code    : ' || c_error_code);
      DBMS_OUTPUT.PUT_LINE('c_error_message : ' || c_error_message);

      IF c_error_code <> '0' THEN
        op_error_code := '-400';
        op_error_msg  := c_error_message;
        RETURN;
      ELSE
        op_error_code := '0';
        op_error_msg  :=  'Success';
        RETURN;
      END IF;

    ELSE
        op_error_code := '0';
        op_error_msg  :=  'Success';
        RETURN;
    END IF; -- IF cst.web_user_objid IS NOT NULL THEN


  ELSE
  -- code for new/pastdue subscribers

    -- detach the line from the esn
    UPDATE table_part_inst
    SET    part_to_esn2part_inst = NULL
    WHERE  part_to_esn2part_inst = cst.esn_part_inst_objid
    AND    x_domain||'' = 'LINES'
    AND    objid = cst.min_part_inst_objid;

    IF cst.web_user_objid IS NOT NULL THEN
      -- remove the esn from the web account
      account_maintenance_pkg.remove_esn_from_account( ip_web_user_objid  => cst.web_user_objid ,
                                                       ip_esn             => ip_esn             ,
                                                       op_err_code        => c_error_code       ,
                                                       op_err_msg         => c_error_message    );

      DBMS_OUTPUT.PUT_LINE('c_error_code    : ' || c_error_code);
      DBMS_OUTPUT.PUT_LINE('c_error_message : ' || c_error_message);

      IF c_error_code <> '0' THEN
        op_error_code := '-400';
        op_error_msg  := c_error_message;
        RETURN;
      END IF;

    END IF; -- IF cst.web_user_objid IS NOT NULL THEN

    -- call method to delete an esn from the member table.
    -- this method considers all logic for shared and non-shared groups
    mt := mt.del ( i_esn => cst.esn );

    DBMS_OUTPUT.PUT_LINE('mt.response : ' || mt.response);

    --
    IF mt.response NOT LIKE '%SUCCESS%' THEN
      op_error_code := '-500';
      op_error_msg := mt.response;
      RETURN;
    END IF;

  END IF;

  op_error_code := '0';
  op_error_msg  := 'Success';

 EXCEPTION
   WHEN OTHERS THEN
     op_error_code := SQLCODE;
     op_error_msg  := SQLERRM;
END p_deact_service;
PROCEDURE p_validate_esn_service_plan  (i_esn               IN  VARCHAR2 ,
                                        i_service_plan_id   IN OUT VARCHAR2 ,
					o_billing_pgm_objid   OUT  VARCHAR2 ,
                                        o_error_code        OUT VARCHAR2 ,
                                        o_error_msg         OUT VARCHAR2 ) AS
c_is_esn_comp VARCHAR2(1);
  -- instantiate initial values
  rc   customer_type := customer_type ();
  cst  customer_type := customer_type ();
BEGIN

  IF i_esn IS NULL THEN
        o_error_code := '100';
        o_error_msg  := 'ESN IS NULL';

  END IF ;

  IF i_esn IS NOT NULL AND i_service_plan_id IS NOT NULL THEN

   c_is_esn_comp  := brand_x_pkg.valid_service_plan_esn ( ip_service_plan_id  => i_service_plan_id,
                                                          ip_esn              => i_esn);


     IF c_is_esn_comp = 'Y' THEN


        BEGIN

           SELECT spxpp.X_SP2PROGRAM_PARAM
               INTO o_billing_pgm_objid
           FROM MTM_SP_X_PROGRAM_PARAM spxpp
           WHERE 1=1
           and spxpp.PROGRAM_PARA2X_SP = i_service_plan_id
           AND spxpp.X_RECURRING        = 1
	   AND rownum < 2;

        EXCEPTION
          WHEN OTHERS THEN
           o_error_code := '200';
           o_error_msg  := 'Program Not Found';
	   RETURN;
        END ;

        o_error_code := '0';
        o_error_msg  := 'Success';
        RETURN;
     ELSE
        o_error_code := '300';
        o_error_msg  := 'Service Plan Not Compatible';
         RETURN;
     END IF;

  END IF;

  IF  i_esn IS   NOT NULL AND i_service_plan_id IS  NULL THEN

     rc.esn := i_esn;
     cst    := rc.get_service_plan_attributes;

     IF cst.response  LIKE '%SUCCESS%' THEN

        i_service_plan_id := cst.service_plan_objid	;

        BEGIN

           SELECT spxpp.X_SP2PROGRAM_PARAM
               INTO o_billing_pgm_objid
           FROM MTM_SP_X_PROGRAM_PARAM spxpp
           WHERE 1=1
           and spxpp.PROGRAM_PARA2X_SP = cst.service_plan_objid
           AND spxpp.X_RECURRING        = 1
	   AND rownum < 2;

	    o_error_code := '0';
            o_error_msg  := 'Success';
            RETURN;

        EXCEPTION
          WHEN OTHERS THEN
           o_error_code := '200';
           o_error_msg  := 'Program Not Found';
	   RETURN;
        END ;


     ELSE
           o_error_code := '400';
           o_error_msg  := 'No Service Plan Id Found for ESN';
           RETURN;

     END IF;

  END IF;


EXCEPTION
  WHEN OTHERS THEN
     o_error_code := sqlcode ;
     o_error_msg  := sqlerrm;
END  p_validate_esn_service_plan;
END warp_service_pkg;
/