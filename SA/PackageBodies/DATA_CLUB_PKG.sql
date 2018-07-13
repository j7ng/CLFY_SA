CREATE OR REPLACE PACKAGE BODY sa.data_club_pkg AS
--------------------------------------------------------------------------------------------
--$RCSfile: data_club_pkb.sql,v $
--$Revision: 1.49 $
--$Author: rvegi $
--$Date: 2018/05/24 18:36:05 $
--$ $Log: data_club_pkb.sql,v $
--$ Revision 1.49  2018/05/24 18:36:05  rvegi
--$ *** empty log message ***
--$
--$ Revision 1.48  2018/05/23 21:52:27  rvegi
--$ *** empty log message ***
--$
--$ Revision 1.47  2018/05/22 15:44:39  rvegi
--$ Defect 39853
--$
--$ Revision 1.46  2018/04/25 21:49:24  rvegi
--$ CR57400 Changes
--$
--$ Revision 1.45  2018/04/20 13:27:57  rvegi
--$ CR57400
--$
--$ Revision 1.44  2018/02/19 14:41:19  oimana
--$ CR52532 - Package Body
--$
--$ Revision 1.38  2017/03/16 20:56:50  akhan
--$ initital checkin
--$
--$ Revision 1.37  2017/02/28 15:54:37  akhan
--$ added PROCESSED for ACH transactions
--$
--$ Revision 1.36  2017/02/21 22:04:28  akhan
--$ Suppressing the base throttle requests
--$
--$ Revision 1.35  2017/02/07 18:44:09  akhan
--$ minor bug fix
--$
--$ Revision 1.34  2017/02/04 00:01:07  akhan
--$ fixing an issue
--$
--$ Revision 1.33  2017/01/30 16:50:23  akhan
--$ First commit CR47808
--$
--$ Revision 1.32  2016/12/29 00:35:28  akhan
--$ added functionality
--$
--$ Revision 1.31  2016/12/28 20:17:25  akhan
--$ fixing bugs in connected products
--$
--------------------------------------------------------------------------------------------
--
--
-- This is specific to data club.
-- This proc SOA will call only for DATA Club accounts
-- For the generic proc which is called for activation, refer towards the end of this package
PROCEDURE get_base_pin (i_esn                  IN  VARCHAR2,  -- ESN
                        i_service_plan_group   IN  VARCHAR2,  -- Pass "BASE" for Base plan, "DATA_ONLY" for data plan
                        o_pin                  OUT VARCHAR2,  -- This is PIN
                        o_pin_plan_id          OUT NUMBER  ,  -- Service plan for the PIN
                        o_err_code             OUT NUMBER  ,  -- If o_pin is null, check this for details of error
                        o_err_msg              OUT VARCHAR2)  -- If o_pin is null, check this for details of error
IS

BEGIN

 o_err_code := 0;
 o_err_msg  := 'Success';

 BEGIN

  IF i_service_plan_group = 'DATA_ONLY' THEN

   SELECT MAX(s1.x_red_code)  INTO o_pin
   FROM   sa.table_part_inst s1,
          sa.table_part_inst s2
   WHERE  s1.x_domain              = 'REDEMPTION CARDS'
   AND    s1.part_to_esn2part_inst = s2.objid
   AND    s2.part_serial_no        = i_esn
   AND    s1.x_part_inst_status    = 400
   AND    s2.x_domain              = 'PHONES'
   AND    EXISTS (SELECT 1
                  FROM   sa.table_mod_level ml,
                         sa.table_part_num pn,
                         sa.service_plan_feat_pivot_mv mv
                  WHERE  s1.n_part_inst2part_mod = ml.objid
                  AND    ml.part_info2part_num = pn.objid
                  AND    pn.domain = 'REDEMPTION CARDS'
                  AND    pn.part_number = mv.plan_purchase_part_number
                  AND    mv.service_plan_group = 'ADD_ON_DATA'
                  AND    mv.plan_type = 'DATA PLANS'
                  AND    mv.plan_category = 'CONNECTED_PRODUCTS_ADDON');

  ELSE

   SELECT MAX(s1.x_red_code)  INTO o_pin
   FROM   sa.table_part_inst s1,
          sa.table_part_inst s2
   WHERE  s1.x_domain              = 'REDEMPTION CARDS'
   AND    s1.part_to_esn2part_inst = s2.objid
   AND    s2.part_serial_no        = i_esn
   AND    s1.x_part_inst_status    = 400
   AND    s2.x_domain              = 'PHONES'
   AND    EXISTS (SELECT 1
                  FROM   sa.table_mod_level ml,
                         sa.table_part_num pn,
                         sa.service_plan_feat_pivot_mv mv
                  WHERE  s1.n_part_inst2part_mod = ml.objid
                  AND    ml.part_info2part_num   = pn.objid
                  AND    pn.domain               = 'REDEMPTION CARDS'
                  AND    pn.part_number          = mv.plan_purchase_part_number
                  AND    mv.service_plan_group   = 'FP_UNLIMITED'
                  AND    mv.plan_type            <> 'DATA PLANS'
                  AND    mv.plan_category        = 'CONNECTED_PRODUCTS_BASE');

  END IF;

 EXCEPTION
   WHEN no_data_found THEN
    o_err_code  := 100;
    o_err_msg   := 'No PIN found in reserve for ESN :- '||i_esn;
    UTIL_PKG.insert_error_tab_proc (ip_action => 'No PIN found in reserve',
                                    ip_key => i_esn || ' : Checking pins in reserve',
                                    ip_program_name => 'data_club_pkg.get_base_pin' ,
                                    ip_error_text => o_err_msg );
   WHEN OTHERS THEN
    o_err_code  := 110;
    o_err_msg   := 'Error getting PIN for ESN :- '||i_esn||' '||SQLERRM;
    UTIL_PKG.insert_error_tab_proc (ip_action => 'Error getting PIN',
                                    ip_key => i_esn || ' : Checking pins in reserve',
                                    ip_program_name => 'data_club_pkg.get_base_pin' ,
                                    ip_error_text => o_err_msg );
 END ;

  --get service plan for the PIN
 BEGIN
   SELECT mv.service_plan_objid
   INTO   o_pin_plan_id
   FROM   sa.table_part_inst pi,
          sa.table_mod_level ml,
          sa.table_part_num pn,
          sa.service_plan_feat_pivot_mv mv
   WHERE  pi.n_part_inst2part_mod=ml.objid
   AND    ml.part_info2part_num=pn.objid
   AND    mv.plan_purchase_part_number = part_number
   AND    pn.domain = 'REDEMPTION CARDS'
   AND    pi.x_red_code = o_pin;
 EXCEPTION
   WHEN OTHERS THEN
     o_err_code  := 110;
     o_err_msg   := 'Error getting PIN PLAN ID for ESN :- '||i_esn||' '||SQLERRM;
     UTIL_PKG.insert_error_tab_proc (ip_action => 'Error getting PIN PLAN ID',
                                     ip_key => i_esn || ' : Checking pins in reserve',
                                     ip_program_name => 'data_club_pkg.get_base_pin' ,
                                     ip_error_text => o_err_msg );
 END;

EXCEPTION
  WHEN OTHERS THEN
    o_err_code  := 110;
    o_err_msg   := 'Error getting pin from reserve :- '||i_esn||' '||SQLERRM;
    UTIL_PKG.insert_error_tab_proc (ip_action => 'Error getting PIN from reserve',
                                    ip_key => i_esn || ' : Checking pins in reserve',
                                    ip_program_name => 'data_club_pkg.get_base_pin' ,
                                    ip_error_text => o_err_msg );
END get_base_pin;
--
--
-- This is the gerneric proc called by SOA in activation flow
-- For data club, we'll always return base pin
-- for other flow, we'll return the first pin created (queue)
PROCEDURE get_base_pin (i_esn                IN  VARCHAR2,
                        o_pin                OUT VARCHAR2,
                        o_part_inst_status   OUT VARCHAR2,
                        o_err_code           OUT NUMBER  ,   -- If o_pin is null, check this for details of error
                        o_err_msg            OUT VARCHAR2)   -- If o_pin is null, check this for details of error
IS

BEGIN

  o_err_code := 0;
  o_err_msg  := 'SUCCESS';

  -- Below SQL will return PIN and part inst status assuming the PIN passed was for data club
  SELECT s1.x_red_code,
         s1.x_part_inst_status
  INTO   o_pin,
         o_part_inst_status
  FROM   sa.table_part_inst s1,
         sa.table_part_inst s2
  WHERE  s1.x_domain              = 'REDEMPTION CARDS'
  AND    s1.part_to_esn2part_inst = s2.objid
  AND    s2.part_serial_no        = i_esn
  AND    s1.x_part_inst_status    = 400
  AND    s2.x_domain              = 'PHONES'
  AND    EXISTS (SELECT 1
                 FROM   sa.table_mod_level ml,
                        sa.table_part_num pn,
                        sa.service_plan_feat_pivot_mv mv
                 WHERE  s1.n_part_inst2part_mod = ml.objid
                 AND    ml.part_info2part_num   = pn.objid
                 AND    pn.domain               = 'REDEMPTION CARDS'
                 AND    pn.part_number          = mv.plan_purchase_part_number
                 AND    mv.service_plan_group   = 'FP_UNLIMITED'
                 AND    mv.plan_type            <> 'DATA PLANS'
                 AND    mv.plan_category        = 'CONNECTED_PRODUCTS_BASE' )
  AND    ROWNUM = 1;

EXCEPTION
  WHEN no_data_found THEN
    -- if PIN is not found, then it is simply a non-data-club thing
    -- run the usual query SOA used to run and return
    -- retrict with rownum = 1 as SOA also doesnt have any checks
    BEGIN
     SELECT s1.x_red_code,
            s1.x_part_inst_status
       INTO o_pin,
            o_part_inst_status
       FROM sa.table_part_inst s1,
            sa.table_part_inst s2
      WHERE s1.x_domain              = 'REDEMPTION CARDS'
        AND s1.part_to_esn2part_inst = s2.objid
        AND s2.part_serial_no        = i_esn
        AND s1.x_part_inst_status    = 400
        AND s2.x_domain              = 'PHONES'
        AND ROWNUM                   = 1;
    EXCEPTION
      WHEN OTHERS THEN
        o_err_code := 10;
        o_err_msg  := 'ERROR Getting PIN from reserve '||SQLERRM;
        RETURN;
    END;
  WHEN OTHERS THEN
    o_err_code := 10;
    o_err_msg  := 'ERROR Getting DATA CLUB PIN from reserve '||SQLERRM;
END get_base_pin;
--
--
PROCEDURE create_group (i_esn                 IN  VARCHAR2,  -- ESN
                        i_pin                 IN  VARCHAR2,  -- This is PIN
                        i_web_user_objid      IN  NUMBER  ,  -- required for creating group
                        o_service_plan_group  OUT VARCHAR2,  -- "BASE" for Base plan, "DATA_ONLY" for data plan
                        o_account_group_id    OUT NUMBER  ,  -- GROUP ID
                        o_err_code            OUT NUMBER  ,  -- Standard error parameters, if o_account_group_id is null, check this for details of error
                        o_err_msg             OUT VARCHAR2)  -- Standard error parameters, if o_account_group_id is null, check this for details of error
IS

  grp                      group_type;
  grp_member               group_member_type;
  n_busorg_objid           NUMBER;
  n_service_planid         NUMBER;
  c_plan_part_num          VARCHAR2(50);
  c_is_dataclub            VARCHAR2(1);
  c_dataclub_plantype      VARCHAR2(10);

BEGIN

  o_err_code := 0;
  o_err_msg  := 'Success';
  -- get bus org
  n_busorg_objid := UTIL_PKG.get_bus_org_objid (i_esn => i_esn);

  IF n_busorg_objid = 0 OR n_busorg_objid IS NULL THEN
   o_err_code := 100;
   o_err_msg  := 'ESN Not Found';
   UTIL_PKG.insert_error_tab_proc (ip_action => 'Error getting Bus ORGANIZATION',
                                   ip_key => i_esn,
                                   ip_program_name => 'data_club_pkg.create_group' ,
                                   ip_error_text => o_err_msg );
   RETURN;
  END IF;

   -- get service plan id
  BEGIN
   SELECT pn.part_number
     INTO c_plan_part_num
     FROM sa.table_part_inst pi,
          sa.table_mod_level ml,
          sa.table_part_num pn
    WHERE pi.x_red_code   = i_pin
      AND pi.x_domain||'' = 'REDEMPTION CARDS'
      AND ml.objid        = pi.n_part_inst2part_mod
      AND pn.objid        = ml.part_info2part_num
      AND pn.domain       = 'REDEMPTION CARDS';
  EXCEPTION
   WHEN OTHERS THEN
   o_err_code := 110;
   o_err_msg := 'Invalid PIN passed';
   UTIL_PKG.insert_error_tab_proc (ip_action => 'Error getting plan part number',
                                   ip_key    => i_esn,
                                   ip_program_name => 'data_club_pkg.create_group' ,
                                   ip_error_text => o_err_msg );
    RETURN;
  END;

  -- Logic to validate if the PIN passed is for BASE only.
  -- and the validation will be based on service plan ID
  -- If it is not then simply send back saying, this is only.

  /*
  IF c_plan_part_num IN ('NTNSMB6005B2B','NTNSMB6050B2B') THEN
   c_is_dataclub        := 'Y';
   c_dataclub_plantype  := 'BASE';
  END IF;

  IF NVL(c_is_dataclub,'N') = 'N' THEN
   o_service_plan_group := NULL;
   o_account_group_id   := NULL;
   o_err_code           := 110;
   o_err_msg            := 'NON DATA CLUB PLAN';
   RETURN;
  END IF;

  IF NVL(c_is_dataclub,'N') = 'Y' AND NVL(c_dataclub_plantype,'DATA') = 'DATA' THEN
   o_service_plan_group := NULL;
   o_account_group_id   := NULL;
   o_err_code           := 120;
   o_err_msg            := 'DATA PIN PASSED';
   RETURN;
  END IF;
  */

  BEGIN
   SELECT service_plan_objid
   INTO   n_service_planid
   FROM   sa.service_plan_feat_pivot_mv
   WHERE  plan_purchase_part_number = c_plan_part_num
   AND    service_plan_group        = 'FP_UNLIMITED'
   AND    plan_type                 <> 'DATA PLANS'
   AND    plan_category             = 'CONNECTED_PRODUCTS_BASE';
  EXCEPTION
   WHEN OTHERS THEN
    o_err_code := 120;
    o_err_msg := 'PIN DOESNT BELONG TO DATA CLUB BASE PLAN';
    UTIL_PKG.insert_error_tab_proc (ip_action => 'Error getting Service PLAN',
                                    ip_key    => i_esn,
                                    ip_program_name => 'data_club_pkg.create_group' ,
                                    ip_error_text => o_err_msg );
    RETURN;
  END;
   --instanciate group type
  grp := group_type (i_web_user_objid    => i_web_user_objid,
                     i_service_plan_id   => n_service_planid,
                     i_status            => NULL,
                     i_bus_org_objid     => n_busorg_objid,
                     i_account_group_uid => NULL );
  -- Create group
  grp := grp.ins();

  IF grp.response LIKE '%SUCCESS%' THEN
   o_account_group_id := grp.group_objid;
   o_service_plan_group := 'BASE';
  ELSE
   o_err_code := 130;
   o_err_msg := 'Error Creating Group '||grp.response;
   UTIL_PKG.insert_error_tab_proc (ip_action => 'Error Creating Group',
                                   ip_key    => i_esn,
                                   ip_program_name => 'data_club_pkg.create_group' ,
                                   ip_error_text => o_err_msg );
   RETURN;
  END IF;

  -- Instanciate Group Member TYPE
  grp_member := group_member_type (i_esn            => i_esn,
                                   i_group_objid    => grp.group_objid,
                                   i_status         => 'ACTIVE',
                                   i_subscriber_uid => NULL);

  -- Create group member
  grp_member := grp_member.ins();

  IF grp_member.response NOT LIKE '%SUCCESS%' THEN
   o_err_code := 140;
   o_err_msg := 'Error Creating Group Member'||grp_member.response;
   UTIL_PKG.insert_error_tab_proc (ip_action => 'Error Creating Group MEMBER',
                                   ip_key    => i_esn,
                                   ip_program_name => 'data_club_pkg.create_group' ,
                                   ip_error_text => o_err_msg );
   RETURN;
  END IF;

  o_err_code := 0;
  o_err_msg := 'SUCCESS';

EXCEPTION
  WHEN OTHERS THEN
    o_err_code := 150;
    o_err_msg := 'ERROR INSIDE DATA_CLUB_PKG.create_group '||SQLERRM||SQLERRM;
    UTIL_PKG.insert_error_tab_proc (ip_action => 'Error in data_club_pkg.create_group',
                                    ip_key    => i_esn,
                                    ip_program_name => 'data_club_pkg.create_group' ,
                                    ip_error_text => o_err_msg );
END create_group;
--
--
PROCEDURE check_autorefill_eligibility (i_esn              IN  VARCHAR2,
                                        o_eligible_flag    OUT VARCHAR2,
                                        o_err_code         OUT NUMBER  ,
                                        o_err_msg          OUT VARCHAR2,
                                        o_pgm_enrl_objid   OUT NUMBER)
IS

  n_enrolled_status       x_program_enrolled.x_enrollment_status%TYPE;
  n_auto_refill_max_limit x_program_enrolled.auto_refill_max_limit%TYPE;
  n_auto_refill_counter   x_program_enrolled.auto_refill_counter%TYPE;

BEGIN

  --get esn details
  SELECT pe.x_enrollment_status,
         NVL(pe.auto_refill_max_limit,0),
         NVL(pe.auto_refill_counter,0),
         pe.objid
    INTO n_enrolled_status,
         n_auto_refill_max_limit,
         n_auto_refill_counter,
         o_pgm_enrl_objid
    FROM sa.x_program_enrolled pe,
         sa.x_program_parameters pgm
   WHERE pe.x_esn                    = i_esn
     AND pe.x_enrollment_status      = 'ENROLLED'
     AND pe.pgm_enroll2pgm_parameter = pgm.objid
     AND pgm.x_program_name LIKE '%Data Club Plan%B2B';

  dbms_output.put_line(o_pgm_enrl_objid);

  IF n_enrolled_status = 'ENROLLED' THEN

   IF n_auto_refill_max_limit = 0 THEN

    o_eligible_flag := 'N';
    o_err_msg  := 'AUTO REFILL LIMIT SET TO ZERO';

   ELSE

    IF n_auto_refill_counter >= n_auto_refill_max_limit THEN
      o_eligible_flag := 'N';
      o_err_msg  := 'MAX AUTO REFILL LIMIT REACHED';
    ELSIF n_auto_refill_counter < n_auto_refill_max_limit THEN
      o_eligible_flag := 'Y';
      o_err_code      := 0;
      o_err_msg       := 'SUCCESS';
    END IF;

   END IF;

  ELSE

   o_eligible_flag := 'N';
   o_err_msg  := 'ESN NOT ENROLLED FOR AUTO REFILL';

  END IF;

EXCEPTION
  WHEN no_data_found THEN
   o_eligible_flag := 'N';
   o_err_msg       := 'ESN NOT FOUND/ NOT ENROLLED';
  WHEN OTHERS THEN
   o_eligible_flag := 'N';
   o_err_msg       := 'ERROR CHECKING ELIGIBILITY '||SUBSTR(dbms_utility.format_error_backtrace(),1,3000);
END check_autorefill_eligibility;
--
--
PROCEDURE increment_autorefill_counter (i_esn       IN  VARCHAR2,
                                        o_err_code  OUT NUMBER  ,
                                        o_err_msg   OUT VARCHAR2)
IS

BEGIN

  UPDATE sa.x_program_enrolled pe
  SET    pe.auto_refill_counter = pe.auto_refill_counter + 1
  WHERE  pe.x_esn               = i_esn
  AND    pe.x_enrollment_status = 'ENROLLED'
  AND    pe.auto_refill_counter IS NOT NULL
  AND    EXISTS (SELECT 1
                   FROM sa.x_program_parameters pgm
                  WHERE pe.pgm_enroll2pgm_parameter = pgm.objid
                    AND pgm.x_program_name LIKE '%Data Club Plan%B2B');

  o_err_code := 0;
  o_err_msg  := 'Success';

  IF SQL%rowcount = 0 THEN
   o_err_code := 100;
   o_err_msg  := 'ESN NOT FOUND OR NOT ENROLLED';
  ELSIF SQL%rowcount > 1 THEN
   o_err_code := 200;
   o_err_msg  := 'ESN ENROLLED IN MULTIPLE PROGRAMS';
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    o_err_code := SQLCODE ;
    o_err_msg  := 'ERROR UPDATING COUNTERS, ROLLBACK THIS TRANSACTION '||SUBSTR(dbms_utility.format_error_backtrace,1,3000)  ;
END increment_autorefill_counter;
--
--
FUNCTION debug_set4esn (ip_esn IN VARCHAR2)
RETURN BOOLEAN IS

   debug_set4esn NUMBER;

BEGIN
   BEGIN
     SELECT 1
     INTO   debug_set4esn
     FROM   sa.table_x_parameters
     WHERE  x_param_name = 'DEBUG_CONNECTED_PRODUCT_ESNS'
     AND    instr(x_param_value,ip_esn) > 0;
   EXCEPTION
     WHEN OTHERS THEN
       debug_set4esn := 2;
   END;

   RETURN debug_set4esn=1;
END debug_set4esn;
--
--
PROCEDURE handle_throttling_event (i_esn               IN  VARCHAR2,
                                   i_throttle_params   IN  VARCHAR2,
                                   o_throttle_flag     OUT VARCHAR2)
IS

  c_err_msg             VARCHAR2(4000);
  n_err_number          NUMBER;
  c_elig_flag           VARCHAR2(1);
  n_service_planid      NUMBER;
  c_data_club_flag      VARCHAR2(1);
  c_pinpartnumber       VARCHAR2(50);
  pgm_enrl_objid        NUMBER;
  c_min                 VARCHAR2(20);
  n_webuser_objid       NUMBER;
  n_payment_src_id      NUMBER;
  c_plan_part_num       VARCHAR2(50);
  c_batch_mode_flag     VARCHAR2(1);
  c_payment_source      VARCHAR2(50);
  c_brand               VARCHAR2(50);
  found_trans           NUMBER;
  res                   VARCHAR2(100);
  v_usagetierid         VARCHAR2(1);
  v_found_expired_addon NUMBER;

  s                     subscriber_type;

BEGIN

    IF debug_set4esn (i_esn) THEN
      UTIL_PKG.insert_error_tab (i_throttle_params,
                                 i_esn,
                                 'SA.data_club_pkg.handle_throttling_event');
    END IF;

    check_autorefill_eligibility (i_esn            => i_esn,
                                  o_eligible_flag  => c_elig_flag,
                                  o_err_code       => n_err_number,
                                  o_err_msg        => c_err_msg,
                                  o_pgm_enrl_objid => pgm_enrl_objid );

   dbms_output.put_line('ESN: '||i_esn||' c_elig_flag: '||c_elig_flag||' pgm_enrl_objid: '||pgm_enrl_objid);

   IF c_elig_flag = 'N' THEN
     o_throttle_flag := 'Y';
     RETURN;
   END IF;

   --Only comes here if it is Data Club ESN - From here on it is only data club specific code
   dbms_output.put_line ('pgm_enrl_objid: '||pgm_enrl_objid);

   SELECT COUNT(1)
   INTO   found_trans
   FROM   sa.x_balance_transaction_order
   WHERE  esn = i_esn
   AND    status = 'FAILED'
   AND    throttle_params = i_throttle_params
   AND    update_timestamp > (sysdate -5/(24*60));

   IF found_trans > 0 THEN
     o_throttle_flag := 'Y';
     RETURN;
   END IF;

   --Check the usage tier. Charge the customer only if he used up all data
   SELECT INSTR(i_throttle_params,'i_cos=NTH2'),
          SUBSTR(i_throttle_params,instr(i_throttle_params,'i_usage_tier_id=')+16,1)
   INTO   v_found_expired_addon,
          v_usagetierid
   FROM   dual;

   dbms_output.put_line('v_usagetierid: '||v_usagetierid);

   IF v_usagetierid = '1' THEN
     --Even though we are saying to throtle tier1 is used for other activties such as send notifications etc
     o_throttle_flag := 'Y';
     RETURN;
   END IF;

   -- Get Service Plan ID and web_user_objid
   BEGIN
    SELECT mtm.program_para2x_sp
    INTO   n_service_planid
    FROM   sa.x_program_enrolled pe,
           sa.mtm_sp_x_program_param mtm
    WHERE  mtm.x_sp2program_param = pe.pgm_enroll2pgm_parameter
    AND    pe.objid != pgm_enrl_objid
    AND    pe.x_enrollment_status = 'ENROLLED'
    AND    pe.x_esn = i_esn;
   EXCEPTION
     WHEN OTHERS THEN
      o_throttle_flag := 'Y';
      UTIL_PKG.insert_error_tab_proc (ip_action => '2',
                                      ip_key    => i_esn ,
                                      ip_program_name => 'SA.data_club_pkg.handle_throttling_event',
                                      ip_error_text => 'Getting Service Plan ID '||SQLERRM);
      RETURN;
   END;

   dbms_output.put_line('n_service_planid: '||n_service_planid);

   BEGIN
    SELECT plan_purchase_part_number
    INTO   c_plan_part_num
    FROM   sa.service_plan_feat_pivot_mv
    WHERE  service_plan_objid = n_service_planid
    AND    service_plan_group = 'FP_UNLIMITED'
    AND    plan_type          <> 'DATA PLANS'
    AND    plan_category      = 'CONNECTED_PRODUCTS_BASE';
   EXCEPTION
     WHEN OTHERS THEN
      o_throttle_flag := 'Y';
      UTIL_PKG.insert_error_tab_proc (ip_action => '3',
                                      ip_key => i_esn,
                                      ip_program_name => 'data_club_pkg.handle_throttling_event',
                                      ip_error_text => 'Getting plan purchase part num '||SQLERRM);
      RETURN;
   END;

   -- Get MIN
   dbms_output.put_line('Before MIN');

   c_min := UTIL_PKG.get_min_by_esn (i_esn => i_esn);

   IF c_min IS NULL THEN
     o_throttle_flag := 'Y';
     UTIL_PKG.insert_error_tab_proc (ip_action => '4',
                                     ip_key =>    i_esn,
                                     ip_program_name => 'SA.data_club_pkg.handle_throttling_event',
                                     ip_error_text => 'Error Getting MIN ');
     RETURN;
   END IF;

   dbms_output.put_line('c_min: '||c_min);

   -- Get web_user_objid and payment_source_id from x_program_enrolled
   BEGIN
     SELECT pgm_enroll2web_user,
            pgm_enroll2x_pymt_src,
            x_sourcesystem
     INTO   n_webuser_objid,
            n_payment_src_id,
            c_payment_source
     FROM   sa.x_program_enrolled
     WHERE  objid = pgm_enrl_objid;
   EXCEPTION
     WHEN OTHERS THEN
      o_throttle_flag := 'Y';
      UTIL_PKG.insert_error_tab_proc (ip_action => '5',
                                      ip_key => i_esn ,
                                      ip_program_name => 'SA.data_club_pkg.handle_throttling_event',
                                      ip_error_text => 'Getting Payment Source '||SQLERRM);
      RETURN;
   END;

   -- check if this account is configured for batch payment or real time payment
   dbms_output.put_line('n_webuser_objid: '||n_webuser_objid);

   c_batch_mode_flag := get_batch_mode_config_flag (i_webuser_objid => n_webuser_objid,
                                                    i_request_type  => 'PAYMENT');
   BEGIN
     SELECT x_source_part_num
     INTO   c_pinpartnumber
     FROM   sa.x_ff_part_num_mapping
     WHERE  x_ff_objid = (SELECT objid
                          FROM   x_program_parameters pgm
                          WHERE  pgm.x_program_name LIKE '%Data Club Plan%B2B'
                          AND    x_charge_frq_code = 'LOWBALANCE' );
   EXCEPTION
     WHEN OTHERS THEN
      o_throttle_flag := 'Y';
      UTIL_PKG.insert_error_tab_proc (ip_action => '7',
                                      ip_key =>  i_esn,
                                      ip_program_name => 'SA.data_club_pkg.handle_throttling_event',
                                      ip_error_text => 'Getting Pin Partnumber '||SQLERRM);
      RETURN;
   END;

   c_brand  := UTIL_PKG.get_bus_org_id (i_esn => i_esn);

   dbms_output.put_line('c_brand: '||c_brand);

   --everything checked out so far. Now expire the old addons
   s := subscriber_type (i_esn);

   IF s.expireaddons (o_result => res) THEN
     NULL;
   END IF;

   dbms_output.put_line('res: '||res);
   dbms_output.put_line('c_batch_mode_flag: '||c_batch_mode_flag);

   BEGIN
        INSERT INTO sa.x_balance_transaction_order
                   (objid,
                    min,
                    esn,
                    status,
                    pin_partnumber,
                    web_user_objid,
                    source_system,
                    brand,
                    payment_source_id,
                    transaction_ref_id,
                    throttle_params,
                    insert_timestamp,
                    update_timestamp)
            VALUES (sequ_x_balance_trans_order.NEXTVAL,
                    c_min,
                    i_esn,
                    decode(c_batch_mode_flag,'Y','PAYMENT_PENDING','QUEUED'),
                    c_pinpartnumber,
                    n_webuser_objid,
                    c_payment_source,
                    c_brand,
                    n_payment_src_id,
                    '9999', --CR57400 (SELECT sa.merchant_ref_number FROM dual),
                    i_throttle_params,
                    current_timestamp,
                    current_timestamp);
   EXCEPTION
     WHEN DUP_VAL_ON_INDEX THEN
       dbms_output.put_line('Error DUP_VAL_ON_INDEX for: '||i_esn);
       NULL;
     WHEN OTHERS THEN
       dbms_output.put_line('Error: Insert of sa.x_balance_transaction_order: '||SQLERRM);
       NULL;
   END;

   dbms_output.put_line('o_throttle_flag(0): '||o_throttle_flag);

   -- Return Throttle flag as "N"
   o_throttle_flag := 'N';

   dbms_output.put_line('o_throttle_flag(1): '||o_throttle_flag);

EXCEPTION
  WHEN OTHERS THEN
    o_throttle_flag := 'Y';
    dbms_output.put_line('Main exception(1): '||SQLERRM);
    UTIL_PKG.insert_error_tab_proc (ip_action => '7',
                                    ip_key =>    i_esn,
                                    ip_program_name => 'SA.data_club_pkg.handle_throttling_event',
                                    ip_error_text => 'General Exception '||SQLERRM);
    RETURN;
END handle_throttling_event;
--
--
PROCEDURE get_payment_source_information (i_bal_tran_objid      IN  NUMBER,
                                          o_x_merchant_id       OUT VARCHAR2,
                                          o_x_merchant_ref_id   OUT VARCHAR2,
                                          o_billing_zipcode     OUT VARCHAR2,
                                          o_cc_objid            OUT NUMBER,
                                          o_amount              OUT NUMBER,
                                          o_error_msg           OUT VARCHAR2)
IS

 c_pinpartnumber VARCHAR2(50);

BEGIN

  BEGIN
   SELECT ta.zipcode,
          sbt.transaction_ref_id,
          cc.objid,
          pin_partnumber
   INTO   o_billing_zipcode,
          o_x_merchant_ref_id,
          o_cc_objid,
          c_pinpartnumber
   FROM   sa.x_balance_transaction_order sbt,
          sa.x_payment_source ps,
          sa.table_x_credit_card cc,
          sa.table_address ta
   WHERE  sbt.objid                 = i_bal_tran_objid
   AND    ps.objid                  = sbt.payment_source_id
   AND    ps.pymt_src2x_credit_card = cc.objid
   AND    cc.x_credit_card2address  = ta.objid
   AND    cc.x_card_status          = 'ACTIVE';
  EXCEPTION
   WHEN no_data_found THEN
    BEGIN
     SELECT ta.zipcode,
            sbt.transaction_ref_id,
            cc.objid,
            pin_partnumber
     INTO   o_billing_zipcode,
            o_x_merchant_ref_id,
            o_cc_objid,
            c_pinpartnumber
     FROM   sa.x_balance_transaction_order sbt,
            sa.x_payment_source ps,
            sa.table_x_bank_account cc,
            sa.table_address ta
     WHERE  sbt.objid                  = i_bal_tran_objid
     AND    ps.objid                   = sbt.payment_source_id
     AND    ps.pymt_src2x_bank_account = cc.objid
     AND    cc.x_bank_acct2address     = ta.objid
     AND    cc.x_status                = 'ACTIVE';
    EXCEPTION
     WHEN OTHERS THEN
      o_error_msg := 'Error retrieving payment source '||SQLERRM;
      UTIL_PKG.insert_error_tab_proc (ip_action => 'Getting Payment Source',
                                      ip_key => i_bal_tran_objid,
                                      ip_program_name => 'SA.data_club_pkg.get_payment_source_information',
                                      ip_error_text => o_error_msg);
      RETURN;
    END;
   WHEN OTHERS THEN
    o_error_msg := 'Error retrieving payment source '||SQLERRM;
    UTIL_PKG.insert_error_tab_proc (ip_action => 'Getting Payment Source',
                                    ip_key => i_bal_tran_objid,
                                    ip_program_name => 'SA.data_club_pkg.get_payment_source_information',
                                    ip_error_text => o_error_msg);
    RETURN;
   END;

  BEGIN
   SELECT x_merchant_id
   INTO   o_x_merchant_id
   FROM   sa.table_x_cc_parms
   WHERE  x_bus_org = 'BILLING B2B';
  EXCEPTION
   WHEN OTHERS THEN
    o_error_msg := 'Error retrieving Merchant ID '||SQLERRM;
    UTIL_PKG.insert_error_tab_proc (ip_action => 'Getting Merchant ID',
                                    ip_key => i_bal_tran_objid,
                                    ip_program_name => 'SA.data_club_pkg.get_payment_source_information',
                                    ip_error_text => o_error_msg);
    RETURN;
  END;

   -- Get amount based on PIN PART NUMBER
   BEGIN
    SELECT x_retail_price
    INTO   o_amount
    FROM   sa.table_x_pricing tp,
           sa.table_part_num pn
    WHERE  tp.x_pricing2part_num = pn.objid
    AND    pn.part_number        =  c_pinpartnumber;
  EXCEPTION
   WHEN OTHERS THEN
    o_error_msg := 'Error retrieving AMOUNT '||SQLERRM;
    UTIL_PKG.insert_error_tab_proc (ip_action => 'Getting AMOUNT',
                                    ip_key => i_bal_tran_objid,
                                    ip_program_name => 'SA.data_club_pkg.get_payment_source_information',
                                    ip_error_text => o_error_msg);
    RETURN;
  END;

  o_error_msg := 'SUCCESS';

EXCEPTION
  WHEN OTHERS THEN
    o_error_msg := 'ERROR GETTING PAYMENT SOURCE '||SUBSTR(dbms_utility.format_error_backtrace(),1,3000);
    UTIL_PKG.insert_error_tab_proc(ip_action => 'Error in get payment source',ip_key =>
    i_bal_tran_objid,ip_program_name => 'SA.data_club_pkg.get_payment_source_information',ip_error_text => o_error_msg);
END get_payment_source_information;
--
--
PROCEDURE insert_x_program_gencode (i_esn                      IN  VARCHAR2,
                                    i_insert_date              IN  DATE    ,
                                    i_post_date                IN  DATE    ,
                                    i_status                   IN  VARCHAR2,
                                    i_error_num                IN  VARCHAR2,
                                    i_error_string             IN  VARCHAR2,
                                    i_gencode2prog_purch_hdr   IN  NUMBER  ,
                                    i_gencode2call_trans       IN  NUMBER  ,
                                    i_x_ota_trans_id           IN  NUMBER  ,
                                    i_x_sweep_and_add_flag     IN  NUMBER  ,
                                    i_x_priority               IN  NUMBER  ,
                                    i_sw_flag                  IN  VARCHAR2,
                                    i_smp                      IN  VARCHAR2,
                                    o_x_pgm_gencode_objid      OUT NUMBER  ,
                                    o_err_code                 OUT NUMBER  ,
                                    o_err_msg                  OUT VARCHAR2)
IS
BEGIN

  IF i_esn IS NULL OR i_insert_date IS NULL OR i_status IS NULL THEN
   o_err_code := 1;
   o_err_msg  := 'MISSING REQUIED INFORMATION (ESN OR INSERT_DATE OR STATUS)';
   RETURN;
  END IF;

  INSERT INTO sa.x_program_gencode
  (
   objid                 ,
   x_esn                 ,
   x_insert_date         ,
   x_post_date           ,
   x_status              ,
   x_error_num           ,
   x_error_string        ,
   gencode2prog_purch_hdr,
   gencode2call_trans    ,
   x_ota_trans_id        ,
   x_sweep_and_add_flag  ,
   x_priority            ,
   sw_flag               ,
   x_smp
  )
  VALUES
  (
   sa.seq_x_program_gencode.NEXTVAL,
   i_esn                           ,
   sysdate                         ,
   i_post_date                     ,
   i_status                        ,
   i_error_num                     ,
   i_error_string                  ,
   i_gencode2prog_purch_hdr        ,
   i_gencode2call_trans            ,
   i_x_ota_trans_id                ,
   i_x_sweep_and_add_flag          ,
   i_x_priority                    ,
   i_sw_flag                       ,
   i_smp
  )
  RETURNING objid INTO o_x_pgm_gencode_objid;

  o_err_code := 0;
  o_err_msg  := 'Success';

EXCEPTION
  WHEN OTHERS THEN
    o_err_code := 2;
    o_err_msg  := 'ERROR INSERTING X_PROGRAM_GENCODE '||SUBSTR(dbms_utility.format_error_backtrace,1,3000);
END insert_x_program_gencode;
--
--
PROCEDURE update_x_program_gencode (i_x_pgm_gencode_objid  IN  NUMBER,
                                    i_smp                  IN  NUMBER,
                                    i_gencode2call_trans   IN  NUMBER,
                                    o_err_code             OUT NUMBER,
                                    o_err_msg              OUT VARCHAR2)
IS
BEGIN

  o_err_code := 0;
  o_err_msg  := 'Success';

  IF i_x_pgm_gencode_objid IS NULL THEN
   o_err_code := 1;
   o_err_msg  := 'MISSING REQUIRED PARAMETER X_PROGRAM_GENCODE OBJID';
   RETURN;
  END IF;

  UPDATE sa.x_program_gencode
  SET    x_smp              = nvl(i_smp,x_smp),
         gencode2call_trans = nvl(i_gencode2call_trans,gencode2call_trans)
  WHERE objid = i_x_pgm_gencode_objid;

  CASE
   WHEN SQL%rowcount = 0 THEN
    o_err_code := 2;
    o_err_msg  := 'ERROR UPDATING X_PROGRAM_GENCODE, OBJID NOT FOUND';
    RETURN;
   WHEN SQL%rowcount > 1 THEN
    o_err_code := 3;
    o_err_msg  := 'ERROR UPDATING X_PROGRAM_GENCODE, MULTIPLE ENTRIES FOR OBJID';
    RETURN;
   WHEN SQL%rowcount =  1 THEN
    o_err_code := 0;
    o_err_msg  := 'SUCCESS';
  END CASE;

EXCEPTION
  WHEN OTHERS THEN
    o_err_code := 4;
    o_err_msg  := 'ERROR UPDATING X_PROGRAM_GENCODE '||SUBSTR(dbms_utility.format_error_backtrace,1,3000);
END update_x_program_gencode;
--
--
FUNCTION get_batch_mode_config_flag (i_webuser_objid   IN NUMBER,
                                     i_request_type    IN VARCHAR2)
RETURN VARCHAR2
IS

  c_batch_mode_flag  VARCHAR2(1);
  n_esn_count        NUMBER;
  n_org_class_1      NUMBER;

BEGIN

  BEGIN

    SELECT CASE WHEN i_request_type = 'EMAIL'
                THEN batch_config_email
                WHEN i_request_type = 'PAYMENT'
                THEN batch_config_payment
                ELSE NULL
           END
      INTO c_batch_mode_flag
      FROM sa.x_site_web_accounts
     WHERE site_web_acct2web_user = i_webuser_objid;

    dbms_output.put_line('c_batch_mode_flag(1): <'||c_batch_mode_flag||'>');

    IF NVL(c_batch_mode_flag,'N') = 'Y' THEN
      RETURN 'Y';
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      -- always default to batch
      RETURN 'Y';
  END;

  -- get active esn count
  SELECT COUNT(DISTINCT pe.x_esn)
  INTO   n_esn_count
  FROM   sa.x_program_enrolled pe,
         sa.table_part_inst pi
  WHERE  pe.pgm_enroll2web_user  = i_webuser_objid
  AND    pe.pgm_enroll2part_inst = pi.objid
  AND    pi.part_status          = 'Active'
  AND    pi.x_domain             = 'PHONES'
  AND    pi.x_part_inst_status   = 52;

  -- And then get the parameter which defines the threshold of small accounts
  SELECT TO_NUMBER(x_param_value)
  INTO   n_org_class_1
  FROM   sa.table_x_parameters
  WHERE  x_param_name = 'ORG_CLASSIFICATION_LEVEL_1';

  dbms_output.put_line('n_esn_count vs n_org_class_1 - <'||n_esn_count||'><'||n_org_class_1||'>');

  --if number of esn is greater then the defined value then send for batch
  IF NVL(n_esn_count,0) > NVL(n_org_class_1,0) THEN
    RETURN 'Y';
  ELSE
    RETURN 'N';
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    RETURN 'Y';
END get_batch_mode_config_flag;
--
--
PROCEDURE update_billing_cycle (i_esn               IN  VARCHAR2,
                                i_pgm_parameter_id  IN  NUMBER,
                                o_err_code          OUT NUMBER,
                                o_err_msg           OUT VARCHAR2)
IS

  c_program_name    x_program_parameters.x_program_name%TYPE;

BEGIN

  IF i_esn IS NULL OR i_pgm_parameter_id IS NULL THEN
   o_err_code := 100;
   o_err_msg  := 'esn or program parameter id cant be null';
  END IF;

  o_err_code := 0;
  o_err_msg  := 'success';

  BEGIN
   SELECT x_program_name
   INTO   c_program_name
   FROM   sa.x_program_parameters
   WHERE  objid = i_pgm_parameter_id;
  EXCEPTION
   WHEN  no_data_found  THEN
    o_err_code := 200;
    o_err_msg  := 'program not found';
    RETURN;
   WHEN OTHERS THEN
    o_err_code := 300;
    o_err_msg  := 'error in retrieving program';
    RETURN;
  END;

  IF c_program_name LIKE '%Data Club Plan%B2B' THEN
   UPDATE sa.x_program_enrolled
   SET    auto_refill_max_limit    = 999,
          auto_refill_counter      = 0
   WHERE  x_esn                    = i_esn
   AND    x_enrollment_status      ='ENROLLED'
   AND    pgm_enroll2pgm_parameter = i_pgm_parameter_id;
  ELSE
   o_err_code   := 0;
   o_err_msg    :=  'Success';
   RETURN;
  END IF;

  IF SQL%rowcount = 0 THEN
   o_err_code := 500;
   o_err_msg  := 'Enroll Record not found';
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    o_err_code := SQLCODE;
    o_err_msg  := SUBSTR(SQLERRM,1,100);
END update_billing_cycle;
--
--
PROCEDURE upd_lowbalance_dataclub_pr (i_esn IN VARCHAR2)
IS

  CURSOR dataclub_lowbalance_pymnt IS
    SELECT *
      FROM (SELECT bto.objid bto_objid,
                   bto.*,
                   pe.objid pe_objid,
                   RANK() OVER(PARTITION BY bto.esn ORDER BY insert_timestamp) rnk
              FROM sa.x_balance_transaction_order bto,
                   sa.x_program_enrolled          pe,
                   sa.x_program_parameters        pr
             WHERE bto.status = 'PAYMENT_REQUIRED'
               AND bto.esn = i_esn
               AND bto.esn = pe.x_esn
               AND pe.pgm_enroll2pgm_parameter = pr.objid
               AND pe.x_enrollment_status = 'ENROLLED'
               AND pr.x_program_name LIKE '%Data Club Plan%B2B' -- CR57400 Excluded NOT Exists Condition to Pick all PAYMENT Required Records
              /* AND NOT EXISTS (SELECT 1
                                 FROM sa.x_balance_transaction_order bton
                                WHERE bton.esn = bto.esn
                                  AND bton.status = 'PAYMENT_QUEUED')*/
								  ) ORDER BY RNK
     --WHERE rnk = 1 -- CR57400 Removed rnk=1 Condition to Process all Payment_Required Records at same Day.
	 ;

BEGIN

   dbms_output.put_line('before upd_lowbalance_dataclub_pr: '||i_esn);

   FOR rec IN dataclub_lowbalance_pymnt LOOP

     UPDATE sa.x_program_enrolled
        SET x_next_charge_date = TRUNC(sysdate),
            x_update_stamp = sysdate
      WHERE objid = rec.pe_objid;

     dbms_output.put_line('rec.pe_objid: '||rec.pe_objid||' rec.bto_objid: '||rec.bto_objid);

     UPDATE sa.x_balance_transaction_order
        SET status = 'PAYMENT_QUEUED',
            update_timestamp = sysdate
      WHERE objid = rec.bto_objid;

   END LOOP;

   dbms_output.put_line('after upd_lowbalance_dataclub_pr');

EXCEPTION
  WHEN OTHERS THEN
    UTIL_PKG.insert_error_tab (i_action        =>  'Updating  payment queued status in x_balance_transaction_order' ,
                               i_key           =>  i_esn       ,
                               i_program_name  =>  'sa.data_club_pkg.upd_lowbalance_dataclub_pr'      ,
                               i_error_text    =>  'sqlcode='||SQLCODE ||', SQLERRM='||SUBSTR(SQLERRM,1,200) );
END upd_lowbalance_dataclub_pr;
--
--
PROCEDURE batch_addon_recon (i_prog_purch_hdr_id       IN NUMBER,
                             i_prog_purch_hdr_status   IN VARCHAR2,
                             i_esn                     IN VARCHAR2 DEFAULT NULL)
IS

  n_prg_gencode_objid   NUMBER;
  n_bto_objid           NUMBER;
  c_smp                 VARCHAR2(30);
  c_merchant_ref_number VARCHAR2(100);
  c_call_trans_objid    NUMBER;
  c_program_name        VARCHAR2(100) := 'SA.DATA_CLUB_PKG.batch_addon_recon';
  o_error_msg           VARCHAR2(300);

  CURSOR bto_trans_cur (ip_purch_hdr_objid NUMBER) IS
    SELECT bto.smp,
           bto.objid,
           hdr.x_merchant_ref_number
      FROM sa.x_balance_transaction_order bto,
           sa.x_program_enrolled          pe,
           sa.x_program_parameters        pr,
           sa.x_program_purch_hdr         hdr,
           sa.x_program_purch_dtl         dtl
     WHERE bto.status = 'PAYMENT_QUEUED'
       AND bto.esn = pe.x_esn
       AND pe.pgm_enroll2pgm_parameter = pr.objid
       AND pr.x_program_name LIKE '%Data Club Plan%B2B'
       AND pr.x_charge_frq_code = 'LOWBALANCE'
       AND dtl.x_esn = pe.x_esn
       AND dtl.pgm_purch_dtl2pgm_enrolled = pe.objid
       AND dtl.pgm_purch_dtl2prog_hdr = hdr.objid
       AND hdr.x_payment_type = 'RECURRING'
       AND hdr.objid = ip_purch_hdr_objid;

BEGIN

    OPEN bto_trans_cur (i_prog_purch_hdr_id);
    LOOP
       FETCH bto_trans_cur INTO c_smp, n_bto_objid, c_merchant_ref_number;
       EXIT WHEN bto_trans_cur%notfound;

       dbms_output.put_line('i_prog_purch_hdr_status(1): '||i_prog_purch_hdr_status);

       dbms_output.put_line('c_smp, n_bto_objid, c_merchant_ref_number(1): '||c_smp||'-'||n_bto_objid||'-'||c_merchant_ref_number);

       -- CR52532 - NET10 ACH batch payments in recurring setup should update the status from RECURACHPENDING to COMPLETED.
       IF i_prog_purch_hdr_status IN ('SUCCESS','PROCESSED','RECURACHPENDING') THEN

         BEGIN
           SELECT red_card2call_trans
             INTO c_call_trans_objid
             FROM sa.table_x_red_card
            WHERE x_smp = c_smp;
         EXCEPTION
           WHEN OTHERS THEN
             o_error_msg := 'Error:'||SUBSTR(SQLERRM,1,300);
             UTIL_PKG.insert_error_tab_proc (ip_action => 'Retrieving RED CARD info',
                                             ip_key => c_smp ,
                                             ip_program_name => c_program_name,
                                             ip_error_text => o_error_msg);
             CONTINUE;
         END;

         dbms_output.put_line('c_call_trans_objid(1): '||c_call_trans_objid);

         UPDATE sa.x_program_gencode
            SET gencode2prog_purch_hdr = i_prog_purch_hdr_id
          WHERE gencode2call_trans = c_call_trans_objid;

         dbms_output.put_line('i_prog_purch_hdr_id(1): '||i_prog_purch_hdr_id);

         UPDATE sa.x_balance_transaction_order
            SET status             = 'COMPLETED',
                transaction_ref_id = c_merchant_ref_number,
                update_timestamp   = sysdate
          WHERE objid = n_bto_objid;

       ELSE

         UPDATE sa.x_balance_transaction_order
            SET status             = 'FAILED_PAYMENT',
                transaction_ref_id = c_merchant_ref_number,
                update_timestamp   = sysdate
          WHERE objid = n_bto_objid;

       END IF;

       --procedure to update next esn to payment_pending
       upd_lowbalance_dataclub_pr (i_esn => i_esn);

    END LOOP;

    dbms_output.put_line('exit batch_addon_recon(1)');

EXCEPTION
  WHEN OTHERS THEN
    UTIL_PKG.insert_error_tab (i_action       => 'Main Exception',
                               i_key          => i_esn,
                               i_program_name => c_program_name,
                               i_error_text   => 'sqlcode=' || SQLCODE || ', SQLERRM=' || SUBSTR(SQLERRM, 1, 200));
END batch_addon_recon;
--
--
PROCEDURE update_auto_refill_counter (i_esn IN VARCHAR2)
IS

  n_pgm_enrl_objid NUMBER;

BEGIN

   BEGIN
    SELECT objid
    INTO   n_pgm_enrl_objid
    FROM   sa.x_program_enrolled pe
    WHERE  x_esn                    = i_esn
    AND    x_enrollment_status      = 'ENROLLED'
    AND    pgm_enroll2pgm_parameter = (SELECT objid
                                       FROM   x_program_parameters pp
                                       WHERE  pp.x_program_name LIKE '%Data Club Plan%B2B%'
                                       AND    x_charge_frq_code ='LOWBALANCE');
   EXCEPTION
    WHEN OTHERS THEN
     UTIL_PKG.insert_error_tab_proc (ip_action =>'2001: Updating autorefill counter',
                                     ip_key => i_esn ,
                                     ip_program_name => 'data_club_pkg.update_auto_refill_counter' ,
                                     ip_error_text => SUBSTR(SQLERRM,1,290));
     RETURN;
   END;

   UPDATE sa.x_program_enrolled
   SET    auto_refill_counter = 0
   WHERE  objid               = n_pgm_enrl_objid;

EXCEPTION
  WHEN OTHERS THEN
    UTIL_PKG.insert_error_tab_proc (ip_action => '2002: ' || to_char(SQLCODE),
                                    ip_key => i_esn || ' : Resetting auto refill counter',
                                    ip_program_name => 'data_club_pkg.update_auto_refill_counter' ,
                                    ip_error_text => SQLERRM );
END update_auto_refill_counter;
--
--
PROCEDURE update_throttling_transaction (i_esn               IN VARCHAR2,
                                         i_bal_trans_objid   IN NUMBER)
IS

 n_tton_objid NUMBER;

BEGIN

 BEGIN
   SELECT MAX(objid )
   INTO   n_tton_objid
   FROM   w3ci.table_x_throttling_transaction tt
   WHERE  tt.x_esn = i_esn
   AND    tt.x_status = 'C'
   AND    EXISTS (SELECT 1
                    FROM sa.x_balance_transaction_order bto
                   WHERE bto.objid = i_bal_trans_objid
                     AND bto.esn = i_esn
                     AND bto.status = 'FAILED'
                     AND bto.min = tt.x_min);
 EXCEPTION
  WHEN OTHERS THEN
    UTIL_PKG.insert_error_tab_proc (ip_action         => 'retreive throttling Transaction for Data Club ',
                                    ip_key            => i_esn ,
                                    ip_program_name   => 'data_club_pkg.update throttling_transaction' ,
                                    ip_error_text     => 'sqlcode='||SQLCODE ||', SQLERRM='||SUBSTR(SQLERRM,1,200));
    RETURN;
 END;

 IF n_tton_objid IS NOT NULL THEN
   UPDATE w3ci.table_x_throttling_transaction
      SET x_status = 'W',
          x_api_status = NULL,
          x_api_message = NULL
    WHERE objid = n_tton_objid;
 END IF;

EXCEPTION
  WHEN OTHERS THEN
    UTIL_PKG.insert_error_tab_proc (ip_action          => 'update  throttling Transaction for Data Club',
                                    ip_key             => i_esn ,
                                    ip_program_name    => 'data_club_pkg.update throttling_transaction' ,
                                    ip_error_text      => 'sqlcode='||SQLCODE ||', SQLERRM='||SUBSTR(SQLERRM,1,200));
END update_throttling_transaction;

FUNCTION b2b_payment_required_counter (i_esn  IN VARCHAR2) --CR57400 Function to get Number of Payment Required Records Count
RETURN NUMBER
IS
l_count NUMBER (5);

BEGIN

SELECT COUNT(*) INTO l_count
FROM x_balance_transaction_order
WHERE esn=i_esn
AND status ='PAYMENT_QUEUED'
AND insert_timestamp > SYSDATE-5;

RETURN l_count;

EXCEPTION
  WHEN OTHERS THEN
  RETURN 1;
    UTIL_PKG.insert_error_tab_proc (ip_action          => 'Get Payment Required Record Count',
                                    ip_key             => i_esn ,
                                    ip_program_name    => 'data_club_pkg.b2b_payment_required_counter' ,
                                    ip_error_text      => 'sqlcode='||SQLCODE ||', SQLERRM='||SUBSTR(SQLERRM,1,200));

END b2b_payment_required_counter;

--
--
END data_club_pkg;
/