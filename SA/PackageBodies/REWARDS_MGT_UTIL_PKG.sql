CREATE OR REPLACE PACKAGE BODY sa.rewards_mgt_util_pkg
AS
 --$RCSfile: REWARDS_MGT_UTIL_PKB.sql,v $
 --$Revision: 1.223 $
 --$Author: abustos $
 --$Date: 2018/04/06 22:19:44 $
 --$ $Log: REWARDS_MGT_UTIL_PKB.sql,v $
 --$ Revision 1.223  2018/04/06 22:19:44  abustos
 --$ Added logic to get service_plan_id when soft pin is not present in table_x_red_card
 --$
 --$ Revision 1.222  2018/04/05 22:07:50  abustos
 --$ CR55200 - Re-initialize payload and nameval in p_rewar_req_process; modify p_event_processing to get service_plan by call_trans, esn and red_code
 --$
 --$ Revision 1.221  2018/04/02 19:33:10  abustos
 --$ CR55200 - Modify p_reward_request_processing to handle Multiple ESNs in an Account scenario
 --$
 --$ Revision 1.218  2018/03/30 15:32:09  abustos
 --$ CR55200 - Pass local variables to p_rewards_request_processing
 --$
 --$ Revision 1.217  2018/03/12 22:51:16  sgangineni
 --$ CR55200 - Removed debug messages to clear deployment issue
 --$
 --$ Revision 1.216  2018/03/12 22:02:35  rmorthala
 --$ Added new procedure p_reward_request_processing & modified p_enroll_cust_in_program
 --$
 --$ Revision 1.212  2018/01/09 15:50:32  mshah
 --$ CR49941 - ST Loyalty points with Autorefill Dummy Credit Card from WEB
 --$
 --$ Revision 1.211  2018/01/05 14:28:04  rmorthala
 --$ *** empty log message ***
 --$
 --$ Revision 1.210  2017/12/18 20:52:23  smeganathan
 --$ code fix in p_event_processing for ILD card
 --$
 --$ Revision 1.208  2017/12/12 17:11:46  rmorthala
 --$ *** empty log message ***
 --$
 --$ Revision 1.203  2017/11/06 19:21:26  abustos
 --$ New check for recurring as gencodes is not updated with the appropriate call_trans at runtime
 --$
 --$ Revision 1.202  2017/11/03 20:50:56  abustos
 --$ added logging to p_event_processing for testing
 --$
 --$ Revision 1.201  2017/11/03 15:15:17  abustos
 --$ C88132 - logic added to deliver AR pts only when there has been a RECURRING payment
 --$
 --$ Revision 1.200  2017/10/24 22:14:47  abustos
 --$ C88132 - If there is a Re-Activation due to MinChange do not give pts.
 --$
 --$ Revision 1.199  2017/10/03 19:32:08  abustos
 --$ C88132 - Modify logic p_event_processing to not provide pts when Reactivating using pin purchased with pts
 --$
 --$ Revision 1.198 2017/08/02 16:45:17 hcampano
 --$ CR52543 Straight Talks Rewards Program enrollment is failing in TAS - Part of REL900 - Scheduled for 8/22/17 - SITB
 --$ Added logic to insert_alternate_paymentsource to for LRP customers during enrollment.
 --$
 --$ Revision 1.197 2017/08/01 15:40:37 hcampano
 --$ CR52543 Straight Talks Rewards Program enrollment is failing in TAS - Part of REL900 - Scheduled for 8/22/17 - SITB
 --$ Fixed issue w/notes.
 --$
 --$ Revision 1.196 2017/07/31 14:32:24 hcampano
 --$ CR52543 Straight Talks Rewards Program enrollment is failing in TAS - Part of REL900 - Scheduled for 8/22/17 - SITB
 --$ MERGED WITH CODE VERSION 1.191 (CURRENT PRODUCTION), BECAUSE ORIGINALLY MERGED WITH 1.192 WHICH CURRENTLY HAS BEEN DELAYED.
 --$
 --$ Revision 1.195 2017/07/26 14:17:42 hcampano
 --$ CR52543 Straight Talks Rewards Program enrollment is failing in TAS - Part of REL900 - Scheduled for 8/22/17 - SITB
 --$
 --$ Revision 1.194 2017/07/21 15:03:47 hcampano
 --$ CR PENDING - Fixing production issue on p_enroll_cust_in_program where it would not attempt the customer enrollment if an alternate payment was found.
 --$
 --$ Revision 1.193 2017/07/21 14:57:58 hcampano
 --$ CR PENDING - Fixing production issue on p_get_reward_benefits that generates an sql error while trying to assign an empty value.
 --$
 --$ Revision 1.192 2017/06/20 20:36:32 vlaad
 --$ Merged with 6/20 BAU release
 --$
 --$ Revision 1.173 2016/09/22 17:57:45 pamistry
 --$ CR41473 - LRP2 Removed Debug messaged from p_event_processing procedure
 --$
 --$ Revision 1.172 2016/09/21 13:27:34 pamistry
 --$ CR41473 - LRP2 Modified p_validate_reward_request procedure to correct the condition for max usage validation
 --$
 --$ Revision 1.171 2016/09/19 22:24:11 pamistry
 --$ CR41473 LRP2 Modify the p_event_processing to skipt deletion of CHARGE transaction as point redemption is process with CHARGE from new flow.
 --$
 --$ Revision 1.170 2016/09/14 21:43:41 pamistry
 --$ CR41473 - LRP2 Modified p_process_reward_request to populate correct source id in benefit transaction table
 --$
 --$ Revision 1.169 2016/09/14 19:33:06 pamistry
 --$ CR41473 - LRP2 Modify p_event_processing procedure to Add Charge as with LRP2 the settlement replaced with Charge to avoid point award for redemption from points.
 --$
 --$ Revision 1.1 2016/09/14 14:22:50 pamistry
 --$ CR41473 - LRP2 Modify p_event_processing procedure by to avoid awarding points for redemption from points - Added CHARGE with SETTLEMENT.
 --$

 --------------------------------------------------------------------------------------------
 -- Author: snulu (Sujatha Nulu)
 -- Date: 2015/10/01
 -- <CR# 33098>
 -- Loyalty Rewards Program is to build a capability to give rewards for certain customer Actions
 -- and increase the Life Time value of the customer.
 -- This program is precisely targeting the customers who fall under the umbrella of Straight Talk.
 --------------------------------------------------------------------------------------------
PROCEDURE p_customer_is_enrolled
 ( in_cust_key IN VARCHAR2,
 in_cust_value IN VARCHAR2,
 in_program_name IN VARCHAR2,
 in_enrollment_type IN VARCHAR2,
 in_brand IN VARCHAR2,
 out_enrollment_status OUT VARCHAR2,
 out_enrollment_elig_status OUT VARCHAR2, --Modified for 2269
 out_err_code OUT NUMBER,
 out_err_msg OUT VARCHAR2
 )
IS
 l_prog_enroll_count NUMBER := 0;
 l_auto_refill_count NUMBER := 0;
 input_validation_failed EXCEPTION;
 l_web_account_id table_web_user.objid%TYPE;
 l_risk_status VARCHAR2(1) := 'N';
 l_enrollment_status VARCHAR2(30);
 -- Juda CR41145
 -- instantiate initial values
 rc sa.customer_type := customer_type ();
 rcwb sa.customer_type := customer_type (); -- CR41867 removed type initialization
 -- type to hold retrieved attributes
 cst sa.customer_type;
 cstwb sa.customer_type;
 PROMO_CHECK EXCEPTION; --CR42428
 l_promoflag varchar2(1):='N'; --CR42428
 o_promoflag varchar2(1):='N'; --CR42428
BEGIN
 out_err_code := 0;
 out_err_msg := 'SUCCESS';
 --
 IF upper(NVL(trim(in_cust_key),'XX')) = 'XX' OR trim(in_cust_value) IS NULL OR upper(trim(in_cust_value)) = 'NULL' THEN
 out_err_code := -311;
 out_err_msg := 'Error. Unsupported or Null values received for IN_CUST_KEY AND IN_CUST_VALUE';
 raise input_validation_failed;
 END IF;
 IF upper(NVL(trim(in_program_name),'~')) <> 'LOYALTY_PROGRAM' THEN
 out_err_code := -312;
 out_err_msg := 'Error. Unsupported or Null values received for IN_PROGRAM_NAME';
 raise input_validation_failed;
 END IF;
 IF upper(NVL(trim(in_brand),'~')) NOT IN ( 'STRAIGHT_TALK','ST') THEN
 out_err_code := -339;
 out_err_msg := 'Error. Unsupported or Null values received for IN_BRAND';
 raise input_validation_failed;
 END IF;
 IF upper(NVL(trim(in_enrollment_type),'~')) NOT IN ('PROGRAM_ENROLLMENT', 'AUTO_REFILL') OR trim(in_enrollment_type) IS NULL THEN
 out_err_code := -356;
 out_err_msg := 'Error. Unsupported or Null values received for IN_ENROLLMENT_TYPE';
 raise input_validation_failed;
 END IF;
 --
 -- CR40672 changes starts..
 -- Check whether the ESN has auto refill enrollment irrespective of the current state
 IF in_cust_key = 'ESN'
 THEN
 BEGIN
 SELECT /*+ INDEX(r idx2_rew_prog_enrol)*/ COUNT(1)
 INTO l_auto_refill_count
 FROM x_reward_program_enrollment r
 WHERE r.esn = in_cust_value
 AND r.enrollment_type = in_enrollment_type
 AND r.brand = in_brand
 AND r.program_name = in_program_name
 AND r.enroll_date IS NOT NULL;
 EXCEPTION
 WHEN OTHERS THEN
 l_auto_refill_count := 0;
 END;
 --
 BEGIN
 SELECT /*+ INDEX(txpe idx1_rew_prog_enrol)*/ COUNT(1)
 INTO l_prog_enroll_count
 FROM x_reward_program_enrollment txpe
 WHERE txpe.web_account_id = TO_CHAR(l_web_account_id)
 AND txpe.enrollment_flag IN ('Y','P')
 AND txpe.enrollment_type = 'PROGRAM_ENROLLMENT'
 AND txpe.brand = in_brand
 AND txpe.enroll_date IS NOT NULL
 AND txpe.deenroll_date IS NULL;
 EXCEPTION
 WHEN OTHERS THEN
 l_prog_enroll_count := 0;
 END;
 --
 IF l_auto_refill_count > 0 THEN
 out_enrollment_status := 'Y';
 ELSE
 out_enrollment_status := 'N';
 END IF;
 --
 -- CR41867 Moved the type initialization
 rcwb    := customer_type ( i_esn => in_cust_value );
 cstwb := rcwb.get_web_user_attributes;
 l_web_account_id := cstwb.web_user_objid;
 --
 ELSIF in_cust_key = 'EMAILID'
 THEN
 -- Juda CR41145
 -- call the retrieve method
 cst := rc.retrieve_login ( i_login_name => in_cust_value, i_bus_org_id => in_brand );
 --
 IF cst.web_user_objid IS NULL THEN
 out_err_code := -311;
 out_err_msg := 'ERROR: WEB ACCOUNT OBJID NOT FOUND';
 out_enrollment_status := 'NOT ENROLLED';
 out_enrollment_elig_status := 'Y';
 --RETURN;
 RAISE PROMO_CHECK; --CR42428
 END IF;
 --
 l_web_account_id := cst.web_user_objid;
 ELSE
 l_web_account_id := in_cust_value;
 END IF;
 --
 --
 IF in_cust_key <> 'ESN'
 THEN
 BEGIN
 SELECT /*+ INDEX(txpe idx1_rew_prog_enrol)*/ COUNT(1)
 INTO l_prog_enroll_count
 FROM x_reward_program_enrollment txpe
 WHERE txpe.web_account_id = TO_CHAR(l_web_account_id)
 AND txpe.enrollment_flag IN ('Y','P')
 AND txpe.enrollment_type = in_enrollment_type
 AND txpe.brand = in_brand
 AND txpe.enroll_date IS NOT NULL
 AND txpe.deenroll_date IS NULL;
 EXCEPTION
 WHEN OTHERS THEN
 l_prog_enroll_count := 0;
 END;
 END IF;
 --
 IF l_prog_enroll_count > 0
 THEN
 --Modified for 2269
 --out_enrollment_status := 'Y';
 BEGIN
 SELECT XRB.ACCOUNT_STATUS
 INTO l_enrollment_status
 FROM X_REWARD_BENEFIT XRB
 WHERE XRB.WEB_ACCOUNT_ID = TO_CHAR(l_web_account_id)
 AND XRB.brand = in_brand
 AND XRB.PROGRAM_NAME = in_program_name;
 EXCEPTION
 WHEN OTHERS THEN
 l_enrollment_status:= 'NOT ENROLLED';
 END;
 ELSE
 l_enrollment_status := 'NOT ENROLLED';
 END IF;
 --
 BEGIN
 SELECT 'Y'
 INTO l_risk_status
 FROM table_web_user web,
 table_x_contact_part_inst conpi,
 table_part_inst pi_esn
 WHERE web.web_user2contact = conpi.x_contact_part_inst2contact
 AND conpi.x_contact_part_inst2part_inst = pi_esn.objid
 AND web.objid = TO_CHAR(l_web_account_id)
 AND pi_esn.X_DOMAIN = 'PHONES'
 AND pi_esn.x_part_inst_status = '56' ;
 EXCEPTION
 WHEN no_data_found THEN
 l_risk_status := 'N';
 WHEN OTHERS THEN
 out_err_code := -312;
 out_err_msg := 'ERROR: WEB ACCOUNT ID NOT FOUND';
 out_enrollment_status := 'NOT ENROLLED';
 out_enrollment_elig_status := 'Y';
 --RETURN;
 RAISE PROMO_CHECK; --CR42428
 END;
 --
 out_enrollment_elig_status :=
 CASE
 WHEN l_enrollment_status IN ('ENROLLED','SUSPENDED','RISK ASSESSMENT') OR l_risk_status ='Y' THEN
 'N'
 WHEN l_enrollment_status IN ('DEENROLLED','EXPIRED') THEN
 'Y'
 ELSE
 'Y'
 END;
 --
 IF in_cust_key <> 'ESN'
 THEN
 out_enrollment_status := l_enrollment_status;
 END IF;
 --Modified for 2269
 --
 RAISE PROMO_CHECK; --CR42428
 ----
 ----
EXCEPTION
--CR42428 starts
WHEN PROMO_CHECK THEN
 BEGIN
 select x_param_value
 into l_promoflag
 from sa.table_x_parameters p
 where p.x_param_name='LRP_ENROLL_PROMO_ONLY';
 Exception WHEN no_data_found THEN
 l_promoflag := 'N';
 END;

 IF l_promoflag ='Y' and out_enrollment_elig_status ='Y' THEN

 p_customer_in_promo_group(
 in_cust_key => 'ACCOUNT',
 in_cust_value => l_web_account_id,
 in_program_name => in_program_name,
 in_benefit_type_code => 'LOYALTY_POINTS',
 in_brand => in_brand,
 out_promotional_flag => o_promoflag,
 out_err_code    => out_err_code,
 out_err_msg   => out_err_msg );

 if o_promoflag = 'N' then
 out_enrollment_elig_status := 'N';
 END IF;

 END IF;
--CR42428 Ends
WHEN input_validation_failed THEN
 --Modified for 2269
 out_enrollment_status := NULL;
 out_enrollment_elig_status :='N';
 out_err_msg :='Error_code: '||out_err_code||' Error_msg: '||out_err_msg || ' - ' ||dbms_utility.format_error_backtrace ;
 RETURN;
WHEN OTHERS THEN
 out_err_code := -99;
 out_err_msg := 'Error_code: '||out_err_code||' Error_msg: '||sqlerrm || ' - ' ||dbms_utility.format_error_backtrace ;
 --ota_util_pkg.err_log (p_action => 'CALLING REWARDS_MGT_UTIL_PKG.P_CUSTOMER_IS_ENROLLED', p_error_date => SYSDATE, p_key => in_cust_value, p_program_name => 'SA.REWARDS_MGT_UTIL_PKG.P_CUSTOMER_IS_ENROLLED', p_error_text => out_err_msg);
END p_customer_is_enrolled;
--
PROCEDURE p_customer_in_promo_group(
 in_cust_key IN VARCHAR2,
 in_cust_value IN VARCHAR2,
 in_program_name IN VARCHAR2,
 in_benefit_type_code IN VARCHAR2,
 in_promo_group IN VARCHAR2,
 in_brand IN VARCHAR2,
 out_promotional_flag OUT VARCHAR2,
 out_err_code OUT NUMBER,
 out_err_msg OUT VARCHAR2 )
IS
 l_value NUMBER :=0;
 input_validation_failed EXCEPTION;
 l_web_account_id table_web_user.objid%TYPE;
 --
BEGIN
 out_err_code := 0;
 out_err_msg := 'SUCCESS';
 --
 IF upper(NVL(trim(in_cust_key),'XX')) = 'XX' OR trim(in_cust_value) IS NULL OR upper(trim(in_cust_value)) = 'NULL' THEN
 out_err_code := -311;
 out_err_msg := 'Error. Unsupported or Null values received for IN_CUST_KEY and IN_CUST_VALUE';
 raise input_validation_failed;
 elsif upper(NVL(trim(in_program_name),'~')) <> 'LOYALTY_PROGRAM' THEN
 out_err_code := -312;
 out_err_msg := 'Error. Unsupported or Null values received for IN_PROGRAM_NAME';
 raise input_validation_failed;
 END IF;
 IF NVL(trim(in_benefit_type_code),'~') <> 'LOYALTY_POINTS' THEN
 out_err_code := -313;
 out_err_msg := 'Error. Unsupported or Null values received for IN_BENEFIT_TYPE_CODE';
 raise input_validation_failed;
 END IF;
 IF trim(in_promo_group) IS NULL THEN
 out_err_code := -357;
 out_err_msg := 'Error. Unsupported or Null values received for IN_PROMO_GROUP';
 raise input_validation_failed;
 END IF;
 IF upper(NVL(trim(in_brand),'~')) NOT IN ( 'STRAIGHT_TALK','ST') THEN
    out_err_code :=                      -352;
    out_err_msg  := 'Error. Unsupported or Null values received for IN_BRAND';
    raise input_validation_failed;
  END IF;
  --
  IF in_cust_key = 'EMAILID' THEN
    BEGIN
      SELECT wu.objid
      INTO l_web_account_id
      FROM table_web_user wu,
        table_bus_org bo
      WHERE wu.WEB_USER2BUS_ORG = bo.objid
      AND bo.ORG_ID             = in_brand
      AND ( wu.login_name       = in_cust_value
      OR wu.s_login_name        = UPPER(in_cust_value) );
    EXCEPTION
    WHEN OTHERS THEN
      l_web_account_id := NULL;
    END;
    --
  ELSE
    l_web_account_id := in_cust_value;
  END IF;
  --
  BEGIN
    SELECT COUNT(*)
    INTO l_value
    FROM x_loyalty_rewards
    WHERE cust_id =
      (SELECT x_cust_id
      FROM table_contact
      WHERE objid =
        (SELECT web_user2contact FROM table_web_user WHERE objid= l_web_account_id
        )
      );
  EXCEPTION
  WHEN no_data_found THEN
    l_value := 0;
  END;
  --
  IF l_value              > 0 THEN
    out_promotional_flag := 'Y';
  ELSE
    out_promotional_flag := 'N';
  END IF;
  --
EXCEPTION
WHEN input_validation_failed THEN
  out_promotional_flag := 'N';
  out_err_msg          :='Error_code: '||out_err_code||' Error_msg: '||out_err_msg || ' - ' ||dbms_utility.format_error_backtrace ;
  RETURN;
WHEN OTHERS THEN
  out_promotional_flag := 'N';
  out_err_code         := -99;
  out_err_msg          := 'Error_code: '||out_err_code||' Error_msg: '||sqlerrm|| ' - ' ||dbms_utility.format_error_backtrace ;
  ota_util_pkg.err_log (p_action => 'CALLING REWARDS_MGT_UTIL_PKG.P_CUSTOMER_IN_PROMO_GROUP', p_error_date => SYSDATE, p_key => in_cust_value, p_program_name => 'REWARDS_MGT_UTIL_PKG.P_CUSTOMER_IN_PROMO_GROUP', p_error_text => out_err_msg);
END p_customer_in_promo_group;
--
---- CR42428 Starts
PROCEDURE p_customer_in_promo_group(
    in_cust_key          IN VARCHAR2,
    in_cust_value        IN VARCHAR2,
    in_program_name      IN VARCHAR2,
    in_benefit_type_code IN VARCHAR2,
    in_brand             IN VARCHAR2,
    out_promotional_flag OUT VARCHAR2,
    out_err_code OUT NUMBER,
    out_err_msg OUT VARCHAR2 )
IS
  l_value                 NUMBER :=0;
  input_validation_failed EXCEPTION;
  l_web_account_id table_web_user.objid%TYPE;

  --
BEGIN
  out_err_code := 0;
  out_err_msg  := 'SUCCESS';
  --
  IF upper(NVL(trim(in_cust_key),'XX')) = 'XX' OR trim(in_cust_value) IS NULL OR upper(trim(in_cust_value)) = 'NULL' THEN
    out_err_code                       := -311;
    out_err_msg                        := 'Error. Unsupported or Null values received for IN_CUST_KEY and IN_CUST_VALUE';
    raise input_validation_failed;
  elsif upper(NVL(trim(in_program_name),'~')) <> 'LOYALTY_PROGRAM' THEN
    out_err_code                              := -312;
    out_err_msg                               := 'Error. Unsupported or Null values received for IN_PROGRAM_NAME';
    raise input_validation_failed;
  END IF;
  IF NVL(trim(in_benefit_type_code),'~') <> 'LOYALTY_POINTS' THEN
    out_err_code                         := -313;
    out_err_msg                          := 'Error. Unsupported or Null values received for IN_BENEFIT_TYPE_CODE';
    raise input_validation_failed;
  END IF;
  IF upper(NVL(trim(in_brand),'~')) NOT IN ( 'STRAIGHT_TALK','ST') THEN
    out_err_code :=                      -352;
    out_err_msg  := 'Error. Unsupported or Null values received for IN_BRAND';
    raise input_validation_failed;
  END IF;
  --
  IF in_cust_key = 'EMAILID' THEN
    BEGIN
      SELECT wu.objid
      INTO l_web_account_id
      FROM table_web_user wu,
        table_bus_org bo
      WHERE wu.WEB_USER2BUS_ORG = bo.objid
      AND bo.ORG_ID             = in_brand
      AND ( wu.login_name       = in_cust_value
      OR wu.s_login_name        = UPPER(in_cust_value) );
    EXCEPTION
    WHEN OTHERS THEN
      l_web_account_id := NULL;
    END;
    --
  ELSE
    l_web_account_id := in_cust_value;
  END IF;
  --

    BEGIN
      SELECT COUNT(*)
      INTO l_value
      FROM x_loyalty_rewards
      WHERE cust_id =
        (SELECT x_cust_id
        FROM table_contact
        WHERE objid =
    (SELECT web_user2contact FROM table_web_user WHERE objid= l_web_account_id
    )
        );
    EXCEPTION
    WHEN no_data_found THEN
      l_value := 0;
    END;

  --
  IF l_value              > 0 THEN
    out_promotional_flag := 'Y';
  ELSE
    out_promotional_flag := 'N';
  END IF;
  --
EXCEPTION
WHEN input_validation_failed THEN
  out_promotional_flag := 'N';
  out_err_msg          :='Error_code: '||out_err_code||' Error_msg: '||out_err_msg || ' - ' ||dbms_utility.format_error_backtrace ;
  RETURN;
WHEN OTHERS THEN
  out_promotional_flag := 'N';
  out_err_code         := -99;
  out_err_msg          := 'Error_code: '||out_err_code||' Error_msg: '||sqlerrm|| ' - ' ||dbms_utility.format_error_backtrace ;
  ota_util_pkg.err_log (p_action => 'CALLING REWARDS_MGT_UTIL_PKG.P_CUSTOMER_IN_PROMO_GROUP', p_error_date => SYSDATE, p_key => in_cust_value, p_program_name => 'REWARDS_MGT_UTIL_PKG.P_CUSTOMER_IN_PROMO_GROUP', p_error_text => out_err_msg);
END p_customer_in_promo_group;

---- CR42428 Ends

-- Procedure to deenroll only for Loyalty program
PROCEDURE p_deenroll_cust_from_program(
    in_key             IN VARCHAR2 ,
    in_value           IN VARCHAR2 ,
    in_program_name    IN VARCHAR2 ,
    in_benefit_type    IN VARCHAR2 ,
    in_enrollment_type IN VARCHAR2 ,
    in_brand           IN VARCHAR2 ,
    out_err_code OUT NUMBER ,
    out_err_msg OUT VARCHAR2)
IS
  --Modified for 2269
  l_enrolled_flag         VARCHAR2(30):='NOT ENROLLED';
  l_eligible_status       VARCHAR2(20):='N';
  input_validation_failed EXCEPTION;
  l_reward_benefit_trans_objid x_reward_benefit_transaction.objid%TYPE;
  bobjid x_reward_benefit.objid%TYPE;
  btrans typ_lrp_benefit_trans;
  l_web_account_id table_web_user.objid%TYPE;

  l_transaction_status     x_reward_benefit_transaction.transaction_status%type;     -- CR41473 PMistry 08/03/2016 LRP2
  --
BEGIN
  out_err_code := 0;
  out_err_msg  := 'SUCCESS';
  -- Initialize BENEFIT TRANSACTION
  btrans := typ_lrp_benefit_trans();
  --
  IF upper(NVL(trim(in_key),'XX')) = 'XX' OR trim(in_value) IS NULL OR trim(in_value) ='null' THEN
    out_err_code                  := -311;
    out_err_msg                   := 'Error. Unsupported or Null values received for IN_KEY and IN_VALUE';
    raise input_validation_failed;
  END IF;
  IF upper( NVL(trim(in_benefit_type),'~')) <> 'LOYALTY_POINTS' THEN
    out_err_code                            := -313;
    out_err_msg                             := 'Error. Unsupported or Null values received for IN_BENEFIT_TYPE_CODE';
    raise input_validation_failed;
  END IF;
  IF upper(NVL(trim(in_brand),'~')) NOT IN ( 'STRAIGHT_TALK','ST') THEN
    out_err_code :=                      -352;
    out_err_msg  := 'Error. Unsupported or Null values received for IN_BRAND';
    raise input_validation_failed;
  END IF;
  IF upper(NVL(trim(in_program_name),'~')) <> 'LOYALTY_PROGRAM' THEN
    out_err_code                           := -312;
    out_err_msg                            := 'Error. Unsupported or Null values received for IN_PROGRAM_NAME';
    raise input_validation_failed;
  END IF;
  IF upper( NVL(trim(in_enrollment_type),'~')) NOT IN ('PROGRAM_ENROLLMENT','AUTO_REFILL') THEN
    out_err_code :=                                 -356;
    out_err_msg  := 'Error. Unsupported or Null values received for IN_ENROLLMENT_TYPE';
    raise input_validation_failed;
  END IF;
  --
  IF in_key = 'EMAILID' THEN
    BEGIN
      SELECT wu.objid
      INTO l_web_account_id
      FROM table_web_user wu,
        table_bus_org bo
      WHERE wu.WEB_USER2BUS_ORG = bo.objid
      AND bo.ORG_ID             = in_brand
      AND ( wu.login_name       = in_value
      OR wu.s_login_name        = UPPER(in_value) );
    EXCEPTION
    WHEN OTHERS THEN
      l_web_account_id := NULL;
    END;
    --
  ELSE
    l_web_account_id := in_value;
  END IF;
  --
  p_customer_is_enrolled( in_cust_key => in_key, in_cust_value => in_value, in_program_name => in_program_name, in_enrollment_type => in_enrollment_type, in_brand => in_brand, out_enrollment_status => l_enrolled_flag, out_enrollment_elig_status => l_eligible_status, --Modified for 2269
  out_err_code => out_err_code, out_err_msg => out_err_msg );
  IF l_enrolled_flag = 'ENROLLED' THEN
    UPDATE x_reward_program_enrollment txpe
    SET enrollment_flag                                                             = 'N',
      deenroll_date                                                                 = SYSDATE
    WHERE txpe.benefit_type_code                                                    = in_benefit_type
    AND DECODE(in_key,'ACCOUNT',txpe.web_account_id, 'EMAILID',txpe.web_account_id) = TO_CHAR(l_web_account_id)
    AND txpe.enrollment_flag                                                        = 'Y' -- To check if a customer is already en-rolled.
    AND txpe.program_name                                                           = in_program_name
    AND txpe.enrollment_type                                                        = in_enrollment_type
    AND txpe.brand                                                                  = in_brand
    AND txpe.enroll_date                                                           IS NOT NULL
    AND txpe.deenroll_date                                                         IS NULL;
    --
    -- Insert a Record for De-enrollment
    btrans.objid                       := 0;
    btrans.trans_date                  := SYSDATE;
    btrans.web_account_id              := l_web_account_id;
    btrans.subscriber_id               := NULL;
    btrans.MIN                         := NULL;
    btrans.esn                         := NULL;
    btrans.old_min                     := NULL;
    btrans.old_esn                     := NULL;
    btrans.trans_type                  := in_enrollment_type;
    btrans.trans_desc                  := 'DEENROLLMENT FROM LOYALTY PROGRAM'; --Modified for 2175
    btrans.amount                      := 0;
    btrans.benefit_type_code           := in_benefit_type;
    btrans.action                      := 'NOTE';
    btrans.action_type                 := 'NOTE';
    btrans.action_reason               := 'DEENROLLMENT FROM LOYALTY PROGRAM';
    btrans.action_notes                := NULL;
    btrans.benefit_trans2benefit_trans := NULL;
    btrans.svc_plan_pin                := NULL;
    btrans.svc_plan_id                 := NULL;
    btrans.brand                       := in_brand;
    btrans.benefit_trans2benefit       := NULL;
    btrans.agent_login_name            := NULL;
    --
    p_create_benefit_trans( ben_trans => btrans,
                            reward_benefit_trans_objid => l_reward_benefit_trans_objid,
                            o_transaction_status => l_transaction_status);               -- CR41473 PMistry 08/03/2016 LRP2 added new output parameter to procedure to get the status of transaction the procedure have inserted.
    --
    bobjid := f_get_cust_benefit_id ('ACCOUNT', btrans.WEB_ACCOUNT_ID, 'LOYALTY_PROGRAM', 'LOYALTY_POINTS');
    --
    UPDATE x_reward_benefit_transaction rbt
    SET rbt.benefit_trans2benefit = bobjid
    WHERE rbt.objid               = l_reward_benefit_trans_objid;
    --
    --After De-enrolled updating the user status to "UNAVAILABLE"
    IF in_enrollment_type = 'PROGRAM_ENROLLMENT' THEN
      UPDATE X_REWARD_BENEFIT
      SET STATUS           = 'UNAVAILABLE',
        account_status     = 'DEENROLLED' --Modified for 2269
      WHERE WEB_ACCOUNT_ID = TO_CHAR(l_web_account_id);
      --
      --Updating the payment source table to set the status to "DELETED"
      UPDATE Table_X_Altpymtsource
      SET X_Application_Key = X_Application_Key
        ||'--'
        ||Objid ,
        X_Status   = 'DELETED'
      WHERE objid IN
        (SELECT Pymt_Src2x_Altpymtsource
        FROM X_Payment_Source
        WHERE pymt_src2web_user = l_web_account_id
        )
      AND X_Alt_Pymt_Source = 'LOYALTY_PTS';
      --
      UPDATE X_Payment_Source Ps
      SET X_Status                     ='DELETED'
      WHERE ps.Pymt_Src2web_User       = l_web_account_id
      AND ps.x_pymt_type               = 'APS'
      AND ps.pymt_src2x_altpymtsource IN
        (SELECT aps.objid
        FROM Table_X_Altpymtsource aps
        WHERE aps.Objid           = ps.Pymt_Src2x_Altpymtsource
        AND aps.X_Alt_Pymt_Source = 'LOYALTY_PTS'
        );
      --
    END IF;
    --
  ELSE
    out_err_code := -200;
    out_err_msg  := 'Customer Is Not Enrolled';
    RETURN;
  END IF;
  --
EXCEPTION
WHEN input_validation_failed THEN
  out_err_msg:='Error_code: '||out_err_code||' Error_msg: '||out_err_msg || ' - ' ||dbms_utility.format_error_backtrace ;
  RETURN;
-- CR42235 Changes Starts
WHEN DUP_VAL_ON_INDEX THEN
  out_err_code := -99;
  out_err_msg  := 'p_deenroll_cust_from_program ='||SUBSTR(sqlerrm, 1, 2000)|| ' - ' ||dbms_utility.format_error_backtrace;
-- CR42235 Changes Ends
WHEN OTHERS THEN
  out_err_code := -99;
  out_err_msg  := 'Error_code: '||out_err_code||' Error_msg: '||sqlerrm || ' - ' ||dbms_utility.format_error_backtrace ;
  ota_util_pkg.err_log (p_action => 'CALLING REWARDS_MGT_UTIL_PKG.P_DEENROLL_CUST_FROM_PROGRAM', p_error_date => SYSDATE, p_key => in_value, p_program_name => 'REWARDS_MGT_UTIL_PKG.P_DEENROLL_CUST_FROM_PROGRAM', p_error_text => out_err_msg);
END p_deenroll_cust_from_program;
--
-- this procedure is for non loyalty program enrollment.
PROCEDURE p_deenroll_esn_from_program(
    in_brand           IN VARCHAR2 ,
    in_web_account_id  IN VARCHAR2 ,
    x_subscriber_id    IN VARCHAR2 ,
    x_min              IN VARCHAR2 ,
    x_esn              IN VARCHAR2 ,
    in_program_name    IN VARCHAR2 ,
    in_benefit_type    IN VARCHAR2 ,
    in_enrollment_type IN VARCHAR2 ,
    out_err_code OUT NUMBER ,
    out_err_msg OUT VARCHAR2)
IS
  l_enrolled_flag         VARCHAR2(30):='NOT ENROLLED'; --Modified for 2269
  l_eligible_status       VARCHAR2(20):='N';            --Modified for 2269
  input_validation_failed EXCEPTION;
  l_reward_benefit_trans_objid x_reward_benefit_transaction.objid%TYPE;
  bobjid x_reward_benefit.objid%TYPE;
  btrans typ_lrp_benefit_trans;

  l_transaction_status     x_reward_benefit_transaction.transaction_status%type;     -- CR41473 PMistry 08/03/2016 LRP2

  --
BEGIN
  out_err_code := 0;
  out_err_msg  := 'SUCCESS';
  -- Initialize BENEFIT TRANSACTION
  btrans := typ_lrp_benefit_trans();
  --
  IF upper( NVL(trim(in_benefit_type),'~')) <> 'LOYALTY_POINTS' THEN
    out_err_code                            := -313;
    out_err_msg                             := 'Error. Unsupported or Null values received for IN_BENEFIT_TYPE_CODE';
    raise input_validation_failed;
  END IF;
  IF upper(NVL(trim(in_brand),'~')) NOT IN ( 'STRAIGHT_TALK','ST') THEN
    out_err_code :=                      -352;
    out_err_msg  := 'Error. Unsupported or Null values received for IN_BRAND';
    raise input_validation_failed;
  END IF;
  IF upper(NVL(trim(in_program_name),'~')) <> 'LOYALTY_PROGRAM' THEN
    out_err_code                           := -312;
    out_err_msg                            := 'Error. Unsupported or Null values received for IN_PROGRAM_NAME';
    raise input_validation_failed;
  END IF;
  IF upper( NVL(trim(in_enrollment_type),'~')) NOT IN ('PROGRAM_ENROLLMENT','AUTO_REFILL') THEN
    out_err_code :=                                 -356;
    out_err_msg  := 'Error. Unsupported or Null values received for IN_ENROLLMENT_TYPE';
    raise input_validation_failed;
  END IF;
  --
  p_customer_is_enrolled( in_cust_key => 'ACCOUNT', in_cust_value => in_web_account_id, in_program_name => in_program_name, in_enrollment_type => in_enrollment_type, in_brand => in_brand, out_enrollment_status => l_enrolled_flag, out_enrollment_elig_status => l_eligible_status, --Modified for 2269
  out_err_code => out_err_code, out_err_msg => out_err_msg );
  --
  IF l_enrolled_flag = 'ENROLLED' THEN
    UPDATE x_reward_program_enrollment txpe
    SET enrollment_flag        = 'N',
      deenroll_date            = SYSDATE
    WHERE 1                    = 1
    AND txpe.web_account_id    = in_web_account_id
    AND txpe.enrollment_flag   = 'Y' -- To check if a customer is already en-rolled.
    AND txpe.enrollment_type   = in_enrollment_type
    AND txpe.brand             = in_brand
    AND txpe.benefit_type_code = in_benefit_type
    AND txpe.esn               = x_esn
    AND txpe.program_name      = in_program_name
    AND txpe.enroll_date      IS NOT NULL
    AND txpe.deenroll_date    IS NULL;
    --
    -- Insert a Record for De-enrollment
    btrans.objid                       := 0;
    btrans.trans_date                  := SYSDATE;
    btrans.web_account_id              := in_web_account_id;
    btrans.subscriber_id               := NULL;
    btrans.MIN                         := x_min;
    btrans.esn                         := x_esn;
    btrans.old_min                     := NULL;
    btrans.old_esn                     := NULL;
    btrans.trans_type                  := in_enrollment_type;
    btrans.trans_desc                  := 'DEENROLLMENT FROM '||in_enrollment_type; --Modified for 2269
    btrans.amount                      := 0;
    btrans.benefit_type_code           := in_benefit_type;
    btrans.action                      := 'NOTE';
    btrans.action_type                 := 'NOTE';
    btrans.action_reason               := 'DEENROLLMENT FROM '||in_enrollment_type;
    btrans.action_notes                := NULL;
    btrans.benefit_trans2benefit_trans := NULL;
    btrans.svc_plan_pin                := NULL;
    btrans.svc_plan_id                 := NULL;
    btrans.brand                       := in_brand;
    btrans.benefit_trans2benefit       := NULL;
    btrans.agent_login_name            := NULL;
    --
    p_create_benefit_trans( ben_trans => btrans,
                            reward_benefit_trans_objid => l_reward_benefit_trans_objid,
                            o_transaction_status => l_transaction_status);               -- CR41473 PMistry 08/03/2016 LRP2 added new output parameter to procedure to get the status of transaction the procedure have inserted.

    --
    bobjid := f_get_cust_benefit_id ('ACCOUNT', btrans.WEB_ACCOUNT_ID, 'LOYALTY_PROGRAM', 'LOYALTY_POINTS');
    --
    UPDATE x_reward_benefit_transaction rbt
    SET rbt.benefit_trans2benefit = bobjid
    WHERE rbt.objid               = l_reward_benefit_trans_objid;
    --
  ELSE
    out_err_code := -200;
    out_err_msg  := 'Customer Is Not Enrolled';
    raise input_validation_failed;
  END IF;
  --
EXCEPTION
WHEN input_validation_failed THEN
  out_err_msg:='Error_code: '||out_err_code||' Error_msg: '||out_err_msg || ' - ' ||dbms_utility.format_error_backtrace ;
  RETURN;
-- CR42235 Changes Starts
WHEN DUP_VAL_ON_INDEX THEN
  out_err_code := -99;
  out_err_msg  := 'p_deenroll_esn_from_program ='||SUBSTR(sqlerrm, 1, 2000)|| ' - ' ||dbms_utility.format_error_backtrace;
-- CR42235 Changes Ends
WHEN OTHERS THEN
  out_err_code := -99;
  out_err_msg  := 'Error_code: '||out_err_code||' Error_msg: '||sqlerrm || ' - ' ||dbms_utility.format_error_backtrace ;
  --ota_util_pkg.err_log (p_action => 'CALLING REWARDS_MGT_UTIL_PKG.p_deenroll_esn_from_program', p_error_date => SYSDATE, p_key => in_web_account_id, p_program_name => 'REWARDS_MGT_UTIL_PKG.p_deenroll_esn_from_program', p_error_text => out_err_msg);
END p_deenroll_esn_from_program;
--
PROCEDURE P_GET_BENEFIT_PROGRAM_INFO(
    IN_PROGRAM_NAME      IN VARCHAR2,
    IN_BENEFIT_TYPE_CODE IN VARCHAR2,
    IN_BRAND             IN VARCHAR2,
    OUT_BENEFIT_INFO_LIST OUT BENEFITS_INFO_TAB,
    out_err_code OUT NUMBER,
    out_err_msg OUT VARCHAR2 )
IS
  input_validation_failed EXCEPTION;
  tab_benefits_info BENEFITS_INFO_TAB;
  Allow_Purch PURCH_USAGE_ALLOW;
  rul_earn BEN_EARNINGS_RULE_TBL;
  CURSOR cur_ben_pro
  IS
    SELECT TXBP.program_name,
      TXBP.benefit_type_CODE,
      TXBP.benefit_unit,
      TXBP.partial_usage_allowed,
      TXBP.min_threshold_value,
      TXBP.max_threshold_value,
      1 CONV_RATIO
    FROM X_REWARD_BENEFIT_PROGRAM TXBP
    WHERE TXBP.PROGRAM_NAME   = IN_PROGRAM_NAME
    AND TXBP.BENEFIT_TYPE_CODE= IN_BENEFIT_TYPE_CODE
    AND TXBP.BRAND            = IN_BRAND ;
  CURSOR cur_ben_usg(ben_typ VARCHAR2)
  IS
    SELECT XBU.benefit_usage,
      XBU.start_date,
      XBU.end_date
    FROM x_reward_benefit_usage XBU
    WHERE XBU.BENEFIT_TYPE_CODE = ben_typ;
  --
  CURSOR cur_ben_earn(prog_nam VARCHAR2,ben_typ VARCHAR2)
  IS
    SELECT XBE.transaction_type,
      XBE.benefits_earned,
      xbe.point_cooldown_days,  -- CR41473 - LRP2 - sethiraj
      xbe.point_expiration_days,-- CR41473 - LRP2 - sethiraj
      ( select catalog_provider
        from x_mtm_catalog_benefit_earning mtm, x_reward_catalog rc
        where rc.objid = mtm.catalog_objid
        and   mtm.benefit_earning_objid = xbe.objid )    AS catalog_provider  -- CR41473 - LRP2 - sethiraj
    FROM x_reward_benefit_earning XBE
    WHERE XBE.PROGRAM_NAME    =PROG_NAM
    AND XBE.BENEFIT_TYPE_CODE =ben_typ
    AND SYSDATE BETWEEN xbe.start_date AND xbe.end_date;  --Modified for CR41661
BEGIN
  out_err_code                                  := 0;
  out_err_msg                                   := 'SUCCESS';
  IF UPPER(NVL(trim(in_benefit_type_CODE),'~')) <> 'LOYALTY_POINTS' OR trim(in_benefit_type_CODE) IS NULL THEN
    out_err_code                                := -313;
    out_err_msg                                 := 'Error. Unsupported or Null values received for IN_BENEFIT_TYPE_CODE';
    raise input_validation_failed;
  END IF;
  IF UPPER(NVL(trim(IN_BRAND),'~')) NOT IN ( 'STRAIGHT_TALK','ST') THEN
    out_err_code :=                      -352;
    out_err_msg  := 'Error. Unsupported or Null values received for IN_BRAND';
    raise input_validation_failed;
  END IF;
  IF UPPER(NVL(trim(IN_PROGRAM_NAME),'~')) <>'LOYALTY_PROGRAM' THEN
    out_err_code                           := -312;
    out_err_msg                            := 'Error. Unsupported or Null values received for IN_PROGRAM_NAME';
    raise input_validation_failed;
  END IF;
  tab_benefits_info := BENEFITS_INFO_TAB();
  FOR R1 IN CUR_BEN_PRO
  LOOP
    Allow_Purch := PURCH_USAGE_ALLOW();
    rul_earn    := BEN_EARNINGS_RULE_TBL();
    FOR R2 IN CUR_BEN_USG(R1.benefit_type_CODE)
    LOOP
      Allow_Purch.extend(1);
      Allow_Purch(Allow_Purch.count) := (PURCH_USAGE_ALLOW_REC(R2.benefit_usage,r2.start_date,r2.end_date));
    END LOOP;
    FOR R3 IN CUR_BEN_EARN(R1.program_name,R1.benefit_type_CODE)
    LOOP
      rul_earn.extend(1);
      rul_earn(rul_earn.count) := (BEN_EARNINGS_RULE(R3.transaction_type,R3.benefits_earned,R3.point_cooldown_days,R3.point_expiration_days, R3.catalog_provider)); -- CR41473 - LRP2 - sethiraj - Added new columns point_cooldown_days, point_expiration_days , catalog_provider
    END LOOP;
    tab_benefits_info.extend(1);
    tab_benefits_info(tab_benefits_info.count) := TYP_BENEFITS_INFO(R1.program_name,R1.benefit_type_CODE,R1.benefit_unit,R1.partial_usage_allowed, Allow_Purch,R1.min_threshold_value,R1.max_threshold_value, rul_earn,R1.CONV_RATIO);
  END LOOP;
  OUT_BENEFIT_INFO_LIST := tab_benefits_info;
EXCEPTION
WHEN input_validation_failed THEN
  out_err_msg:='Error_code: '||out_err_code||' Error_msg: '||out_err_msg || ' - ' ||dbms_utility.format_error_backtrace ;
  RETURN;
WHEN OTHERS THEN
  out_err_code := -99;
  out_err_msg  := 'Error_code: '||out_err_code||' Error_msg: '||sqlerrm|| ' - ' ||dbms_utility.format_error_backtrace ;
  ota_util_pkg.err_log (p_action => 'CALLING REWARDS_MGT_UTIL_PKG.P_GET_BENEFIT_PROGRAM_INFO', p_error_date => SYSDATE, p_key => IN_PROGRAM_NAME, p_program_name => 'REWARDS_MGT_UTIL_PKG.P_GET_BENEFIT_PROGRAM_INFO', p_error_text => out_err_msg);
END P_GET_BENEFIT_PROGRAM_INFO;
FUNCTION f_create_btrans_from_event(
    in_event IN q_payload_t )
  RETURN typ_lrp_benefit_trans
IS
  btrans typ_lrp_benefit_trans;
BEGIN
  btrans := typ_lrp_benefit_trans ( 0, --OBJID
  SYSDATE,                             --TRANS_DATE,
  NULL,                                --ACCOUND_ID
  NULL,                                --IN_EVENT.SUBSCRIBER_ID, --SUBSCRIBER_ID
  in_event.MIN,                        --MIN
  in_event.esn,                        --ESN
  NULL,                                --IN_EVENT.NEW_MIN,       --NEW_MIN
  NULL,                                --IN_EVENT.NEW_ESN,       --NEW_ESN
  NULL,                                --IN_EVENT.TRANS_TYPE,    -- ARCHECK
  '',                                  --TRANS_DESC
  '0',                                 --AMOUNT
  '',                                  --BENEFIT_TYPE
  'NOTE',                              --deafult --ACTION
  'NOTE',                              --deafult  --ACTION_TYPE
  NULL,                                --IN_EVENT.ACTION_REASON, -- ARCHECK
  NULL,                                --IN_EVENT.ACTION_NOTES,
  0,                                   --BENEFIT_TRANS2BENEFIT_TRANS
  NULL,                                --IN_EVENT.PIN,           --SVC_PLAN_PIN
  NULL,                                --IN_EVENT.SVC_PLAN,      --SVC_PLAN_ID
  in_event.brand,                      --BRAND
  0 ,                                  --BENEFIT_TRANS2BENEFIT
  NULL,                                --agent login name
  -- CR41473 - Added new columns for for LRP2 - sethiraj
  NULL,                                --status;
  NULL,                                --maturity_date;
  NULL,                                --expiration_date;
  NULL,                                --SOURCE;
  NULL                                 --source_trans_id;
  );
  RETURN btrans;
END f_create_btrans_from_event;
--
FUNCTION f_get_svc_plan_benefits(
    in_svc_plan_id       IN VARCHAR2,
    in_program_name      IN x_reward_benefit_program.program_name%TYPE,
    in_benefit_type_code IN x_reward_benefit_program.benefit_type_code%TYPE,
    in_brand             IN x_reward_benefit_program.brand%TYPE,
    in_autorefill_flag   IN VARCHAR2    ) --Modified for CR41661
  RETURN NUMBER
IS
  --
  CURSOR cur_reward_point_service_plan(p_autorefill_flag varchar2) --Modified for CR41661
  IS
    SELECT case p_autorefill_flag
  when 'Y'
  then reward_point_auto_refill
  else reward_point
  end reward_point
    FROM mtm_sp_reward_program srp,
      x_reward_benefit_program rbp
    WHERE 1                = 1
    AND service_plan_objid = in_svc_plan_id
    AND SYSDATE BETWEEN srp.start_date AND srp.end_date
    AND srp.reward_program_objid = rbp.objid
    AND rbp.program_name         = in_program_name
    AND SYSDATE BETWEEN rbp.start_date AND rbp.end_date
    AND rbp.benefit_type_code = in_benefit_type_code
    AND rbp.brand             = in_brand;
  rec_reward_point_service_plan cur_reward_point_service_plan%rowtype;
  --
BEGIN
  --
  OPEN cur_reward_point_service_plan(nvl(in_autorefill_flag,'N')); --Modified for CR41661
  FETCH cur_reward_point_service_plan INTO rec_reward_point_service_plan;
  --
  IF cur_reward_point_service_plan%found THEN
    CLOSE cur_reward_point_service_plan;
    RETURN rec_reward_point_service_plan.reward_point;
  ELSE
    CLOSE cur_reward_point_service_plan;
    RETURN -1;
  END IF;
  --
END f_get_svc_plan_benefits;
--
FUNCTION f_benefits_prev_awarded(
    in_web_account_id    IN VARCHAR2,
    in_esn               IN VARCHAR2,
    in_program_name      IN VARCHAR2,
    in_trans_type        IN VARCHAR2,
    in_benefit_type_code IN VARCHAR2,
    in_brand             IN VARCHAR2,
    in_svc_plan_id       IN VARCHAR2,
    in_svc_plan_pin      IN VARCHAR2 )
  RETURN BOOLEAN
IS
  --
  svc_plan_points NUMBER;
  svc_plan_ar_points NUMBER; --Modified for CR41661
  --
  CURSOR cur_get_benefit_earning_hist
  IS
    SELECT spr.reward_point , spr.reward_point_auto_refill,  --Modified for CR41661
      TRUNC(spr.START_DATE) START_DATE ,
      TRUNC(spr.END_DATE) END_DATE
    FROM MTM_SP_REWARD_PROGRAM spr
    WHERE spr.SERVICE_PLAN_OBJID = in_svc_plan_id
    AND TRUNC(SYSDATE) BETWEEN TRUNC(spr.START_DATE) AND TRUNC(spr.END_DATE);
  /* SELECT *
  FROM
  (SELECT rh_val.column_name,
  NVL(rh_val.new_value, rh_val.current_value) curr_val,
  rh_val.objid_to_action
  FROM x_reward_history rh_sp,
  x_reward_history rh_val
  WHERE rh_sp.table_name                   = 'MTM_SP_REWARD_PROGRAM'
  AND rh_sp.column_name                    = 'SERVICE_PLAN_OBJID'
  AND (rh_sp.new_value                     = in_svc_plan_id
  OR rh_sp.current_value                   = in_svc_plan_id)
  AND rh_sp.objid_to_action                = rh_val.objid_to_action
  AND rh_val.table_name                    = 'MTM_SP_REWARD_PROGRAM'
  AND rh_val.column_name                  IN ('REWARD_POINT', 'START_DATE', 'END_DATE')
  ) pivot ( MAX(curr_val) FOR column_name IN ('REWARD_POINT' AS reward_point , 'START_DATE' AS start_date, 'END_DATE' AS end_date) );
  */
  --Modified code to fix Defect 2409
  /*     SELECT *
  FROM
  (SELECT rh_val.column_name,
  NVL(rh_val.new_value, rh_val.current_value) curr_val,
  rh_val.objid_to_action
  FROM   x_reward_history rh_sp  ,
  x_reward_history rh_val ,
  (SELECT objid_to_action ,
  column_name     ,
  MAX(rh.objid) max_objid
  FROM    x_reward_history rh
  WHERE   rh.table_name   IN  'MTM_SP_REWARD_PROGRAM'
  AND     rh.column_name  IN ('REWARD_POINT','START_DATE','END_DATE')
  GROUP BY objid_to_action, column_name
  )max_objid
  WHERE rh_sp.table_name               = 'MTM_SP_REWARD_PROGRAM'
  AND   rh_sp.column_name              = 'SERVICE_PLAN_OBJID'
  AND   (rh_sp.new_value               = in_svc_plan_id
  OR rh_sp.current_value              = in_svc_plan_id
  )
  AND   rh_sp.objid_to_action          = rh_val.objid_to_action
  AND   rh_val.table_name              = 'MTM_SP_REWARD_PROGRAM'
  AND   rh_val.column_name             IN ('REWARD_POINT', 'START_DATE', 'END_DATE')
  AND   rh_val.objid_to_action         = max_objid.objid_to_action
  AND   rh_val.objid                   = max_objid.max_objid
  AND   rh_val.column_name             = max_objid.column_name
  ) pivot (MAX(curr_val) FOR column_name IN ('REWARD_POINT' AS reward_point ,
  'START_DATE'   AS start_date   ,
  'END_DATE'     AS end_date
  )
  );*/
  --
  CURSOR cur_benefit_awarded (c_amount NUMBER, c_start_date DATE, c_end_date DATE)
  IS
    SELECT 1
    FROM x_reward_benefit_transaction
    WHERE web_account_id  = in_web_account_id
    AND esn               = in_esn
    AND trans_type        = in_trans_type
    AND benefit_type_code = in_benefit_type_code
    AND brand             = in_brand
    AND amount            = c_amount
    AND TRUNC(trans_date) BETWEEN TRUNC(c_start_date) AND TRUNC(c_end_date)
    AND svc_plan_id          = in_svc_plan_id
    AND NVL(svc_plan_pin, 0) = NVL(in_svc_plan_pin, 0) ;
  --
  rec_benefit_awarded cur_benefit_awarded%rowtype;
  --
BEGIN
  --list the benefits from history table for the service plan
  FOR rec IN cur_get_benefit_earning_hist
  LOOP
    --
    svc_plan_points := rec.reward_point;
    svc_plan_ar_points := rec.reward_point_auto_refill; --Modified for CR41661
    --
    IF NVL(svc_plan_points,0) > 0 THEN
      OPEN cur_benefit_awarded (rec.reward_point, rec.START_DATE, rec.END_DATE);
      FETCH cur_benefit_awarded INTO rec_benefit_awarded;
      --check if benefit is already awarded
      IF cur_benefit_awarded%found THEN
        CLOSE cur_benefit_awarded;
        RETURN TRUE;
      ELSE
        CLOSE cur_benefit_awarded;
  OPEN cur_benefit_awarded (rec.reward_point_auto_refill, rec.START_DATE, rec.END_DATE);
  FETCH cur_benefit_awarded INTO rec_benefit_awarded;
  IF cur_benefit_awarded%found THEN
      CLOSE cur_benefit_awarded;
      RETURN TRUE;
  ELSE
      CLOSE cur_benefit_awarded;
        RETURN FALSE;
  END IF;
      END IF;
      --IF cur_benefit_awarded%found THEN
    END IF;
    --IF NVL(svc_plan_points,0) > 0 THEN
  END LOOP;
  RETURN FALSE; -- temp
EXCEPTION
WHEN OTHERS THEN
  dbms_output.put_line('EXCEPTION! : f_benefits_prev_awarded');
  RETURN FALSE; -- temp
END f_benefits_prev_awarded;
--
PROCEDURE p_create_benefit_trans(
    ben_trans IN typ_lrp_benefit_trans,
    reward_benefit_trans_objid OUT x_reward_benefit_transaction.objid%TYPE,
    o_transaction_status   out x_reward_benefit_transaction.transaction_status%type)        -- CR41473 08/03/2016 PMistry LRP2 Added new output parameter to return the transaction status.
IS
  -- CR41473 Start 07/21/2016 PMistry Added to consider cooling period.
  --l_status    varchar2(60 char);

  cursor cur_benefit_earning_detail(c_transaction_type   VARCHAR2) is
      select *
      from   sa.x_reward_benefit_earning
      where  transaction_type = c_transaction_type
      and    end_date > sysdate
      and    rownum = 1;

  rec_benefit_earning_detail     cur_benefit_earning_detail%rowtype;

  l_maturity_date   date;
  -- CR41473 End 07/21/2016 PMistry Added to consider cooling period.

BEGIN
  -- CR41473 Start 07/21/2016 PMistry Added to consider cooling period.
  if ben_trans.transaction_status is null then
    if ben_trans.action = 'ADD' then


      open cur_benefit_earning_detail( ben_trans.trans_type );
      fetch cur_benefit_earning_detail into rec_benefit_earning_detail;

      if cur_benefit_earning_detail%found and nvl(rec_benefit_earning_detail.POINT_COOLDOWN_DAYS,0) <> 0 then
        l_maturity_date := ben_trans.trans_date + rec_benefit_earning_detail.POINT_COOLDOWN_DAYS;
        o_transaction_status := 'PENDING';
      else
        o_transaction_status := 'COMPLETE';
        l_maturity_date := ben_trans.trans_date;
      end if;
      --
      close cur_benefit_earning_detail;
--------------
      IF ben_trans.trans_type = 'AUTO_REFILL'
      THEN --{
        l_maturity_date      := NVL(sa.customer_info.get_expiration_date(i_esn => ben_trans.esn), (ben_trans.trans_date + rec_benefit_earning_detail.POINT_COOLDOWN_DAYS));
        o_transaction_status := 'PENDING';
      END IF; --}
--------------


    else
      o_transaction_status := 'COMPLETE';
      l_maturity_date := ben_trans.trans_date;
    end if;
  else
    o_transaction_status := ben_trans.transaction_status;
    l_maturity_date := ben_trans.maturity_date;
  end if;
  -- CR41473 End 07/21/2016 PMistry Added to consider cooling period.

  --get sequence no
  SELECT SEQ_X_REW_BEN_TRANS_ID.nextval
  INTO reward_benefit_trans_objid
  FROM DUAL;
  --insert record
  INSERT
  INTO x_reward_benefit_transaction
    (
      OBJID ,
      TRANS_DATE ,
      WEB_ACCOUNT_ID ,
      SUBSCRIBER_ID ,
      MIN ,
      ESN ,
      OLD_MIN ,
      OLD_ESN ,
      TRANS_TYPE ,
      TRANS_DESC ,
      AMOUNT ,
      BENEFIT_TYPE_CODE ,
      ACTION ,
      ACTION_TYPE ,
      ACTION_REASON ,
      BENEFIT_TRANS2BENEFIT_TRANS ,
      SVC_PLAN_PIN ,
      SVC_PLAN_ID ,
      BRAND ,
      BENEFIT_TRANS2BENEFIT,
      ACTION_NOTES,
      AGENT_LOGIN_NAME,
      Transaction_Status, -- CR41473 - LRP2 - sethiraj
      Maturity_date,      -- CR41473 - LRP2 - sethiraj
      Expiration_date,    -- CR41473 - LRP2 - sethiraj
      Source,             -- CR41473 - LRP2 - sethiraj
      Source_trans_ID     -- CR41473 - LRP2 - sethiraj
    )
    VALUES
    (
      reward_benefit_trans_objid,
      ben_trans.trans_date ,
      ben_trans.web_account_id ,
      ben_trans.subscriber_id ,
      ben_trans.MIN ,
      ben_trans.esn ,
      ben_trans.old_min ,
      ben_trans.old_esn ,
      ben_trans.trans_type ,
      ben_trans.trans_desc ,
      ben_trans.amount ,
      ben_trans.benefit_type_code ,
      ben_trans.action ,
      ben_trans.action_type ,
      ben_trans.action_reason ,
      ben_trans.benefit_trans2benefit_trans ,
      ben_trans.svc_plan_pin ,
      ben_trans.svc_plan_id ,
      ben_trans.brand ,
      ben_trans.benefit_trans2benefit,
      ben_trans.action_notes,
      ben_trans.agent_login_name,
      o_transaction_status,               -- CR41473 - LRP2 - sethiraj
      l_maturity_date,                    -- CR41473 - LRP2 - sethiraj
      ben_trans.Expiration_date,          -- CR41473 - LRP2 - sethiraj
      ben_trans.Source,                   -- CR41473 - LRP2 - sethiraj
      ben_trans.Source_trans_ID           -- CR41473 - LRP2 - sethiraj
    );
  --
/*EXCEPTION
WHEN OTHERS THEN
  dbms_output.put_line('EXCEPTION! .... p_create_benefit_trans');*/ -- CR42235 commented
END p_create_benefit_trans;
--
FUNCTION f_get_enrollment_benefits
  (
    in_program_name    IN VARCHAR2,
    in_benefit_type    IN VARCHAR2,
    in_enrollment_type IN VARCHAR2
  )
  RETURN NUMBER
IS
  CURSOR cur_ben_earned
  IS
    SELECT rbe.benefits_earned benefits_earned
    FROM x_reward_benefit_earning rbe
    WHERE rbe.program_name    = in_program_name
    AND rbe.benefit_type_code = in_benefit_type
    AND rbe.transaction_type  = in_enrollment_type
    AND SYSDATE BETWEEN rbe.start_date AND rbe.end_date;
  rec_ben_earned cur_ben_earned%rowtype;
BEGIN
  OPEN cur_ben_earned;
  FETCH cur_ben_earned INTO rec_ben_earned;
  IF cur_ben_earned%found THEN
    CLOSE cur_ben_earned;
    RETURN rec_ben_earned.benefits_earned;
  ELSE
    CLOSE cur_ben_earned;
    RETURN 0;
  END IF;
END f_get_enrollment_benefits;
--
FUNCTION f_get_cust_benefit_id(
    in_cust_key     IN VARCHAR2,
    in_cust_value   IN VARCHAR2,
    in_program_name IN VARCHAR2,
    in_benefit_type IN VARCHAR2,
    in_brand        IN varchar2 default 'STRAIGHT_TALK')   -- CR41437 Added new parameter to remove hard coded value for STRAIGHT_TALK.
  RETURN NUMBER
IS
  --
  CURSOR cur_reward_benefit
  IS
    SELECT objid result_objid
    FROM x_reward_benefit
    WHERE web_account_id = in_cust_value
    AND program_name     = in_program_name
    AND benefit_owner    = in_cust_key
    AND brand            = in_brand           -- CR41437 Modify to remove hard coded value for STRAIGHT_TALK.
      --AND benefit_owner     = in_cust_key
    AND benefit_type_code = in_benefit_type
      --AND status            = 'AVAILABLE'
    AND ROWNUM = 1;
  rec_reward_benefit cur_reward_benefit%rowtype;
  --
BEGIN
  OPEN cur_reward_benefit;
  FETCH cur_reward_benefit INTO rec_reward_benefit;
  --
  IF cur_reward_benefit%found THEN
    CLOSE cur_reward_benefit; -- Juda CR41145
    RETURN NVL(rec_reward_benefit.result_objid, 0);
  ELSE
    CLOSE cur_reward_benefit; -- Juda CR41145
    RETURN 0;
  END IF;
  --
END f_get_cust_benefit_id;
--
PROCEDURE p_update_benefit(
    in_cust_key         IN VARCHAR2, -- {OBJECT, ESN, SID, ACCOUNT, MIN}
    in_cust_value       IN VARCHAR2,
    in_program_name     IN VARCHAR2,
    in_benefit_type     IN VARCHAR2,
    in_brand            IN VARCHAR2,
    in_new_min          IN VARCHAR2,
    in_new_esn          IN VARCHAR2,
    in_new_status       IN VARCHAR2, --{AVAILABLE, UNAVAILABLE, USED, CANCELLED, EXPIRED}
    in_new_notes        IN VARCHAR2,
    in_new_expiry_date  IN DATE,
    in_change_quantity  IN NUMBER,   -- this is delta change to make, plus or minus
    in_transaction_status IN VARCHAR2 DEFAULT 'COMPLETE', -- CR41473 - LRP2 - sethriaj
    in_value            IN NUMBER DEFAULT NULL,         -- CR41473 - LRP2 - sethriaj
    in_account_status   IN VARCHAR2) --Modified for defect 2269)
IS
BEGIN
  -- @@@ make sure to update X_UPDATE_DATE, and X_VALUE, and X_EXPIRY_DATE (when applic)
  -- do simple case first, if we have OBJID we dont need to check anythng else
  -- FOR NOW, assume anything passed in "IN_NEW..." will be used (@@@ check this logic later)
  IF (in_cust_key = 'OBJID' AND in_cust_value <> 0) THEN

    UPDATE x_reward_benefit
    SET esn              = NVL(in_new_esn, esn),
        MIN              = NVL(in_new_min, MIN),
        status           = NVL(in_new_status, status),
        notes            = NVL(in_new_notes, notes),
        expiry_date      = in_new_expiry_date, --nvl(IN_NEW_EXPIRY_DATE, X_EXPIRY_DATE), => clear if not being set
        quantity         = (CASE WHEN nvl(in_transaction_status,'COMPLETE') = 'COMPLETE' THEN
                                      nvl(quantity,0) + nvl(in_change_quantity,0)
                                 ELSE quantity
                            END),                                                                 -- CR41473 - LRP2 - sethriaj
        pending_quantity = (CASE WHEN nvl(in_transaction_status,'COMPLETE') = 'PENDING' THEN
                                      nvl(pending_quantity,0) + nvl(in_change_quantity,0)
                                 ELSE pending_quantity                                            -- CR41473 - LRP2 - sethriaj
                            END),
        total_quantity   = nvl(pending_quantity,0) + nvl(quantity,0) + nvl(in_change_quantity,0), -- CR41473 - LRP2 - sethriaj
        update_date      = SYSDATE, --Modified for 2269
        value            = nvl(value,0) + nvl(in_value,value), -- CR41473 - LRP2
        account_status   =
        CASE
        WHEN (nvl(in_change_quantity,0) > 0 AND ACCOUNT_STATUS='SUSPENDED') -- AND nvl(in_pending_quantity,0) = 0) -- CR41473 - LRP2 - sethriaj
          THEN 'ENROLLED'
        WHEN in_new_status = 'AVAILABLE'
          THEN 'ENROLLED'
        ELSE account_status
        END --Modified for defect 2269
    WHERE objid = in_cust_value;


  ELSE -- if we dont have OBJID, then check other ID params (account, ESN, etc., as approp)
    UPDATE x_reward_benefit
    SET esn              = NVL(in_new_esn, esn),
        MIN              = NVL(in_new_min, MIN),
        status           = NVL(in_new_status, status),
        notes            = NVL(in_new_notes, notes),
        expiry_date      = in_new_expiry_date, --nvl(IN_NEW_EXPIRY_DATE, X_EXPIRY_DATE), => clear if not being set
        quantity         = (CASE WHEN nvl(in_transaction_status,'COMPLETE') = 'COMPLETE' THEN
                                      nvl(quantity,0) + nvl(in_change_quantity,0)
                                 ELSE quantity
                            END),                                                                 -- CR41473 - LRP2 - sethriaj
        pending_quantity = (CASE WHEN nvl(in_transaction_status,'COMPLETE') = 'PENDING' THEN
                                      nvl(pending_quantity,0) + nvl(in_change_quantity,0)
                                 ELSE pending_quantity                                            -- CR41473 - LRP2 - sethriaj
                            END),
        total_quantity   = nvl(pending_quantity,0) + nvl(quantity,0) + nvl(in_change_quantity,0), -- CR41473 - LRP2 - sethriaj
        update_date      = SYSDATE,
        value            = nvl(value,0) + nvl(in_value,value), -- CR41473 - LRP2
        account_status   =
        CASE
          WHEN (in_change_quantity > 0 AND ACCOUNT_STATUS='SUSPENDED')
            THEN 'ENROLLED'
          WHEN in_new_status = 'AVAILABLE'
            THEN 'ENROLLED'
          ELSE account_status
        END --Modified for defect 2269
    WHERE program_name = in_program_name
    AND brand          = in_brand
    AND ( (in_cust_key = 'ESN'
    AND in_cust_value  = esn)
    OR (in_cust_key    = 'MIN'
    AND in_cust_value  = MIN)
    OR (in_cust_key    = 'SID'
    AND in_cust_value  = subscriber_id)
    OR (in_cust_key    = 'ACCOUNT'
    AND in_cust_value  = web_account_id) );
  END IF;
  --
EXCEPTION
WHEN OTHERS THEN
  dbms_output.put_line('EXCEPTION! ...p_update_benefit');
END p_update_benefit;
--
FUNCTION f_create_ben_from_event(
    in_event IN q_payload_t )
  RETURN typ_lrp_reward_benefit
IS
  --
  benefit typ_lrp_reward_benefit;
  --
BEGIN
  --
  benefit := typ_lrp_reward_benefit ( 0, NULL,                  --WEB_ACCOUND_ID,  -ARCHECK
  NULL,                                                         --SUBSCRIBER_ID,
  in_event.MIN, in_event.esn, SYSDATE, NULL,                    --BENEFIT_OWNER
  'AVAILABLE',                                                  --dafault
  '', '', SYSDATE, NULL, in_event.brand, 0, 0, '', 'ENROLLED',  --Modified for defect 2269
  -- CR41473 - Added new columns for for LRP2 - sethiraj
  0, --pending_quantity
  0, --expired_quantity
  0, --total_quantity
  1 --loyalty_tier DEFAULT
    );
  RETURN benefit;
  --
END f_create_ben_from_event;
--
PROCEDURE p_create_benefit(
    benefit IN typ_lrp_reward_benefit,
    reward_benefit_objid OUT x_reward_benefit.objid%TYPE )
IS
  --
BEGIN
  --
  SELECT SEQ_X_REWARD_BENEFIT.nextval --use this sequence..
  INTO reward_benefit_objid
  FROM DUAL;
  --
  INSERT
  INTO x_reward_benefit
    (
      OBJID ,
      WEB_ACCOUNT_ID ,
      SUBSCRIBER_ID ,
      MIN ,
      ESN ,
      BENEFIT_OWNER ,
      CREATED_DATE ,
      STATUS ,
      NOTES ,
      BENEFIT_TYPE_CODE ,
      UPDATE_DATE ,
      EXPIRY_DATE ,
      BRAND ,
      QUANTITY ,
      VALUE ,
      PROGRAM_NAME,
      ACCOUNT_STATUS,
      PENDING_QUANTITY, -- CR41473 - LRP2 - sethiraj
      EXPIRED_QUANTITY, -- CR41473 - LRP2 - sethiraj
      TOTAL_QUANTITY,   -- CR41473 - LRP2 - sethiraj
      LOYALTY_TIER      -- CR41473 - LRP2 - sethiraj
    ) --Modified for defect 2269
    VALUES
    (
      reward_benefit_objid,
      benefit.web_account_id ,
      benefit.subscriber_id ,
      benefit.MIN ,
      benefit.esn ,
      benefit.benefit_owner ,
      benefit.created_date ,
      benefit.status ,
      benefit.notes ,
      benefit.benefit_type_code ,
      benefit.update_date ,
      benefit.expiry_date ,
      benefit.brand ,
      nvl(benefit.quantity,0) ,
      benefit.VALUE ,
      benefit.program_name,
      CASE
        WHEN benefit.status = 'AVAILABLE'
        THEN 'ENROLLED'
        ELSE benefit.account_status
      END, --Modified for defect 2269
      nvl(benefit.pending_quantity,0), -- CR41473 - LRP2 - sethiraj
      nvl(benefit.expired_quantity,0), -- CR41473 - LRP2 - sethiraj
      nvl(benefit.quantity,0) + nvl(benefit.pending_quantity,0), --benefit.total_quantity,   -- CR41473 - LRP2 - sethiraj
      nvl(benefit.loyalty_tier,1)      -- CR41473 - LRP2 - sethiraj
    );
  --
EXCEPTION
WHEN OTHERS THEN
  dbms_output.put_line('EXCEPTION! ...p_create_benefit');
END p_create_benefit;
--
PROCEDURE p_compensate_reward_points
  (
    btrans  IN OUT typ_lrp_benefit_trans, ---ARCHECK EITHER OUT PARAMETER OR CREATE VARIABLES
    benefit IN OUT typ_lrp_reward_benefit,
    out_error_num OUT NUMBER,
    out_error_message OUT VARCHAR2
  )
IS
  --
  bobjid x_reward_benefit.objid%TYPE;
  estatus                     VARCHAR2(10);
  pts                         NUMBER;
  l_error_code                NUMBER;
  l_error_msg                 VARCHAR2(2000);
  lv_reward_benefit_calculate VARCHAR2(1) := 'Y';
  ln_reward_benefit_trans_objid x_reward_benefit_transaction.objid%TYPE;
  --
  CURSOR cur_reward_benefit(c_bobjid NUMBER) IS
   SELECT *
     FROM x_reward_benefit
    WHERE objid = c_bobjid;
  --
  reward_benefit_rec    cur_reward_benefit%ROWTYPE;
  l_transaction_status  x_reward_benefit_transaction.transaction_status%TYPE;
  l_action_notes        x_reward_benefit_transaction.action_notes%TYPE;
  --
BEGIN
  out_error_num     := 0;
  out_error_message := 'SUCCESS';
  --
    p_create_benefit_trans( ben_trans => btrans,
                            reward_benefit_trans_objid => ln_reward_benefit_trans_objid,
                            o_transaction_status => l_transaction_status);               -- CR41473 PMistry 08/03/2016 LRP2 added new output parameter to procedure to get the status of transaction the procedure have inserted.

  --
  pts := 0;
  -- pts           := pts + f_get_enrollment_benefits (benefit.program_name, btrans.benefit_type_code,btrans.trans_type);
  -- btrans.amount := pts;
  IF (btrans.trans_type='AGENT' AND btrans.amount IS NOT NULL ) THEN
    pts               := btrans.amount ;
  ELSE
    pts           := pts + f_get_enrollment_benefits (benefit.program_name, btrans.benefit_type_code,btrans.trans_type);
    btrans.amount := pts;
  END IF;
  --
  bobjid := f_get_cust_benefit_id ( 'ACCOUNT', btrans.WEB_ACCOUNT_ID, 'LOYALTY_PROGRAM', 'LOYALTY_POINTS');
  --
  IF btrans.action    = 'ADD' THEN
    pts              := pts;
  ELSIF btrans.action = 'DEDUCT' THEN
    pts              := pts * -1;
  ELSIF btrans.action = 'NOTE' AND btrans.trans_type = 'DEENROLLMENT' THEN
    pts              := 0;
  ELSE
    lv_reward_benefit_calculate := 'N';
  END IF;
  --
  IF lv_reward_benefit_calculate = 'Y' THEN
    --
    IF (trim(bobjid) <> 0 ) THEN

      IF deduct_benefit_points(i_benefit_objid      => bobjid,
                         i_transaction_status => l_transaction_status,
                         i_points_to_deduct   => pts
                         )  = 'N' THEN
        --
        l_transaction_status := 'FAILED';
        l_action_notes       := 'Not enough qty to deduct';
      ELSE
        p_update_benefit(in_cust_key            =>  'OBJID',
                         in_cust_value          =>  bobjid,
                         in_program_name        =>  '',
                         in_benefit_type        =>  '',
                         in_brand               =>  '',
                         in_new_min             =>  '',
                         in_new_esn             =>  '',
                         in_new_status          =>  benefit.status,
                         in_new_notes           =>  '',
                         in_new_expiry_date     =>  NULL,
                         in_change_quantity     =>  pts,                  -- CR41473-LRP2
                         in_transaction_status  =>  l_transaction_status, -- CR41473-LRP2
                         in_value               =>  NULL,                 -- CR41473-LRP2
                         in_account_status      =>  NULL); --ARCURRENT --Modified for defect 2269
      END IF;
    ELSE
      -- CR41473 LRP2 create reward benefit record with either pending quantity or actual quantity based on transaction_status
      if l_transaction_status = 'PENDING' then
        benefit.pending_quantity := pts;
      elsif l_transaction_status = 'COMPLETE' then
        benefit.quantity := pts;
      end if;
      p_create_benefit(benefit, bobjid);
    END IF;
    --
    --IF (trim(bobjid)            <> 0 ) THEN
    --
    UPDATE x_reward_benefit_transaction rbt
    SET rbt.benefit_trans2benefit = bobjid,
        rbt.amount              = pts,
        rbt.trans_type          = case trans_type when 'AUTO_REFILL_EXISTING' THEN 'AUTO_REFILL' ELSE TRANS_TYPE END, --Modified for CR41661
        rbt.transaction_status  = l_transaction_status,
        rbt.action_notes        = CASE WHEN l_transaction_status = 'FAILED' THEN
                                          l_action_notes
                                       ELSE
                                         rbt.action_notes
                                   END
    WHERE rbt.objid           = ln_reward_benefit_trans_objid;
      --
  END IF;
  --IF lv_reward_benefit_calculate = 'Y' THEN
EXCEPTION
-- CR42235 Changes Starts
WHEN DUP_VAL_ON_INDEX THEN
  out_error_num       := -99;
  out_error_message   := 'p_compensate_reward_points ='||SUBSTR(sqlerrm, 1, 2000)|| ' - ' ||dbms_utility.format_error_backtrace;
-- CR42235 Changes Ends
WHEN OTHERS THEN
  out_error_num     := -99;
  out_error_message := 'Error_code: '||out_error_num||' Error_msg: '||sqlerrm || ' - ' ||dbms_utility.format_error_backtrace ;
END p_compensate_reward_points;
--
-- TAS calls this
PROCEDURE p_compensate_reward_points(
    in_source_system     IN VARCHAR2,
    in_program_name      IN x_reward_benefit_program.program_name%TYPE,
    in_brand             IN x_reward_benefit_program.brand%TYPE,
    in_web_account_id    IN x_reward_program_enrollment.web_account_id%TYPE,
    in_min               IN x_reward_program_enrollment.MIN%TYPE,
    in_esn               IN x_reward_program_enrollment.esn%TYPE,
    in_action            IN x_reward_benefit_transaction.action%TYPE,
    in_amount            IN x_reward_benefit_transaction.amount%TYPE,
    in_benefit_type_code IN x_reward_benefit_program.benefit_type_code%TYPE,
    in_action_reason     IN x_reward_benefit_transaction.action_reason%TYPE,
    in_action_notes      IN x_reward_benefit_transaction.action_notes%TYPE,
    in_agent_login_name  IN x_reward_benefit_transaction.agent_login_name%TYPE,
    out_error_num OUT NUMBER,
    out_error_message OUT VARCHAR2 )
IS
  --
  btrans typ_lrp_benefit_trans;
  benefit typ_lrp_reward_benefit;
  l_enrolled_status VARCHAR2(30):='NOT ENROLLED';
  l_eligible_status VARCHAR2(20):='N';
  --
  input_validation_failed EXCEPTION;
  --
BEGIN
  --
  out_error_num     := 0;
  out_error_message := 'SUCCESS';
  --
  IF NVL(trim(in_source_system), '~') NOT IN ('TAS', 'WEBCSR') THEN
    raise_application_error (              -20100,SUBSTR(' THIS PROGRAM IS ONLY USED BY TAS '||sqlerrm,1,255));
  END IF;
  --
  IF upper(NVL(trim(in_program_name),'~')) <> 'LOYALTY_PROGRAM' THEN
    out_error_num                          := -10;
    out_error_message                      := 'IN PARAMETER is not passed correctly';
    raise input_validation_failed;
  END IF;
  IF trim(in_web_account_id) IS NULL THEN
    out_error_num            := -10;
    out_error_message        := 'IN PARAMETER is not passed correctly';
    raise input_validation_failed;
  END IF;
  IF trim(in_esn)     IS NULL THEN
    out_error_num     := -10;
    out_error_message := 'IN PARAMETER is not passed correctly';
    raise input_validation_failed;
  END IF;
  IF upper(NVL(trim(in_action),'~')) NOT IN ( 'ADD', 'DEDUCT') THEN
    out_error_num     :=                      -10;
    out_error_message := 'IN PARAMETER is not passed correctly';
    raise input_validation_failed;
  END IF;
  IF trim(in_amount)  IS NULL THEN
    out_error_num     := -10;
    out_error_message := 'IN PARAMETER is not passed correctly';
    raise input_validation_failed;
  END IF;
  IF NVL(trim(in_benefit_type_code),'~') <> 'LOYALTY_POINTS' THEN
    out_error_num                        := -10;
    out_error_message                    := 'IN PARAMETER is not passed correctly';
    raise input_validation_failed;
  END IF;
  IF upper(NVL(trim(in_brand),'~')) NOT IN ( 'STRAIGHT_TALK') THEN
    out_error_num     :=                     -10;
    out_error_message := 'IN PARAMETER is not passed correctly';
    raise input_validation_failed;
  END IF;
  --
  p_customer_is_enrolled( in_cust_key => 'ACCOUNT', in_cust_value => in_web_account_id, in_program_name => in_program_name, in_enrollment_type => 'PROGRAM_ENROLLMENT', in_brand => in_brand, out_enrollment_status => l_enrolled_status, out_enrollment_elig_status => l_eligible_status, out_err_code => out_error_num, out_err_msg => out_error_message );
  --
  IF l_enrolled_status IN ('ENROLLED','SUSPENDED','RISK ASSESSMENT') THEN
    ---CREATE BENEFIT TRANSACTION RECORD
    btrans := typ_lrp_benefit_trans();
    --
    btrans.objid                       := 0;
    btrans.trans_date                  := SYSDATE;
    btrans.web_account_id              := in_web_account_id;
    btrans.subscriber_id               := NULL;
    btrans.MIN                         := in_min;
    btrans.esn                         := in_esn;
    btrans.old_min                     := NULL;
    btrans.old_esn                     := NULL;
    btrans.trans_type                  := 'AGENT';
    btrans.trans_desc                  := 'Agent provided: '||in_action_reason; --Modified for 2175
    btrans.amount                      := in_amount;
    btrans.benefit_type_code           := in_benefit_type_code;
    btrans.action                      := in_action;
    btrans.action_type                 := 'REPL';
    btrans.action_reason               := 'Agent provided: '||in_action_reason; --Modified for Defect 472
    btrans.action_notes                := in_action_notes;
    btrans.benefit_trans2benefit_trans := NULL;
    btrans.svc_plan_pin                := NULL;
    btrans.svc_plan_id                 := NULL;
    btrans.brand                       := in_brand;
    btrans.benefit_trans2benefit       := NULL;
    btrans.agent_login_name            := in_agent_login_name;
    --
    --CREATE BENEFIT REWARD RECORD
    benefit := typ_lrp_reward_benefit (); --Modified for defect 2269
    --
    benefit.objid          := 0;
    benefit.web_account_id := in_web_account_id;
    benefit.subscriber_id  := NULL;
    benefit.MIN            := in_min;
    benefit.esn            := in_esn;
    benefit.benefit_owner  := 'ACCOUNT';
    benefit.created_date   := SYSDATE;
    --benefit.status            := 'AVAILABLE';
    benefit.notes             := NULL;
    benefit.benefit_type_code := in_benefit_type_code;
    benefit.update_date       := NULL;
    benefit.expiry_date       := NULL;
    benefit.brand             := in_brand;
    benefit.quantity          := NULL;
    benefit.VALUE             := NULL;
    benefit.program_name      := in_program_name;
    benefit.account_status    := l_enrolled_status; --modified for 2269
    --
    p_compensate_reward_points( btrans => btrans, benefit => benefit, out_error_num => out_error_num, out_error_message => out_error_message );
  ELSE
    out_error_num     := -100;
    out_error_message := 'INVALID Account Status';
    RETURN;
  END IF;
  --
EXCEPTION
WHEN input_validation_failed THEN
  out_error_message:='Error_code: '||out_error_num||' Error_msg: '||out_error_message || ' - ' ||dbms_utility.format_error_backtrace ;
  RETURN;
WHEN OTHERS THEN
  out_error_num     := -99;
  out_error_message := 'Error_code: '||out_error_num||' Error_msg: '||sqlerrm || ' - ' ||dbms_utility.format_error_backtrace ;
  --    ota_util_pkg.err_log (p_action => 'CALLING OVERLOADING PROC REWARDS_MGT_UTIL_PKG.P_COMPENSATE_REWARD_POINTS', p_error_date => SYSDATE, p_key => in_web_account_id, p_program_name => 'REWARDS_MGT_UTIL_PKG.P_COMPENSATE_REWARD_POINTS', p_error_text => out_error_message);
END p_compensate_reward_points;
--
PROCEDURE p_enroll_cust_in_program(
    IN_CUST_KEY        IN VARCHAR2,
    IN_CUST_VALUE      IN VARCHAR2,
    IN_BRAND           IN VARCHAR2 ,
    X_SUBSCRIBER_ID    IN VARCHAR2 ,
    X_MIN              IN VARCHAR2 ,
    X_ESN              IN VARCHAR2 ,
    IN_PROGRAM_NAME    IN VARCHAR2 ,
    in_benefit_type    IN VARCHAR2 ,
    IN_ENROLLMENT_TYPE IN VARCHAR2 ,
    IN_ENROLL_CHANNEL  IN VARCHAR2 ,  -- CR41665 added
    IN_ENROLL_MIN      IN VARCHAR2 ,  -- CR41665 added
    out_err_code OUT NUMBER ,
    out_err_msg OUT VARCHAR2)
IS
  input_validation_failed EXCEPTION;
  l_web_account_id table_web_user.objid%TYPE;
BEGIN
  --
  IF upper(NVL(trim(in_cust_key),'XX')) = 'XX' OR trim(in_cust_value) IS NULL OR upper(trim(in_cust_value)) = 'NULL' THEN
    out_err_code                       := -311;
    out_err_msg                        := 'Error. Unsupported or Null values received for IN_CUST_KEY AND IN_CUST_VALUE';
    raise input_validation_failed;
  END IF;
  IF upper(NVL(trim(in_brand),'~')) NOT IN ('STRAIGHT_TALK','ST') THEN
    out_err_code :=                      -352;
    out_err_msg  := 'Error. Unsupported or Null values received for IN_BRAND';
    raise input_validation_failed;
  END IF;
  IF upper(NVL(trim(in_program_name),'~')) <> 'LOYALTY_PROGRAM' THEN
    out_err_code                           := -312;
    out_err_msg                            := 'Error. Unsupported or Null values received for IN_PROGRAM_NAME';
    raise input_validation_failed;
  END IF;
  IF upper(NVL(trim(in_benefit_type),'~')) <> 'LOYALTY_POINTS' THEN
    out_err_code                           := -313;
    out_err_msg                            := 'Error. Unsupported or Null values received for IN_BENEFIT_TYPE_CODE';
    raise input_validation_failed;
  END IF;
  IF upper(NVL(trim(in_enrollment_type),'~')) NOT IN ('PROGRAM_ENROLLMENT','AUTO_REFILL') THEN
    out_err_code :=                                -356;
    out_err_msg  := 'Error. Unsupported or Null values received for IN_ENROLLMENT_TYPE';
    raise input_validation_failed;
  END IF;
  --
  IF IN_CUST_KEY = 'EMAILID' THEN
    BEGIN
      SELECT wu.objid
      INTO l_web_account_id
      FROM table_web_user wu,
        table_bus_org bo
      WHERE wu.WEB_USER2BUS_ORG = bo.objid
      AND bo.ORG_ID             = in_brand
      AND ( wu.login_name       = IN_CUST_VALUE
      OR wu.s_login_name        = UPPER(IN_CUST_VALUE) );
    EXCEPTION
    WHEN OTHERS THEN
      l_web_account_id := NULL;
    END;
    --
  ELSE
    l_web_account_id := IN_CUST_VALUE;
  END IF;
  --
  out_err_code := 0;
  out_err_msg  := 'SUCCESS';
  --
  rewards_mgt_util_pkg.p_enroll_cust_in_program(  in_brand            => in_brand ,
                                                  in_web_account_id   => l_web_account_id ,
                                                  x_subscriber_id     => x_subscriber_id ,
                                                  x_min               => x_min ,
                                                  x_esn               => x_esn ,
                                                  in_program_name     => in_program_name ,
                                                  in_benefit_type     => in_benefit_type ,
                                                  in_enrollment_type  => in_enrollment_type ,
                                                  in_enroll_channel   => in_enroll_channel, --CR41665 added
                                                  in_enroll_min       => in_enroll_min,     --CR41665 added
                                                  out_err_code        => out_err_code ,
                                                  out_err_msg         => out_err_msg );
  --
  --
EXCEPTION
WHEN input_validation_failed THEN
  out_err_msg:=out_err_msg ;--|| ' - ' ||dbms_utility.format_error_backtrace ;
  RETURN;
WHEN OTHERS THEN
  out_err_code := -99;
  out_err_msg  := 'P_ENROLL_CUSTOMER_IN_PROGRAM ='||SUBSTR(sqlerrm, 1, 2000)|| ' - ' ||dbms_utility.format_error_backtrace;
  ota_util_pkg.err_log (p_action => 'CALLING REWARDS_MGT_UTIL_PKG.P_ENROLL_CUST_IN_PROGRAM', p_error_date => SYSDATE, p_key => IN_CUST_VALUE, p_program_name => 'REWARDS_MGT_UTIL_PKG.P_ENROLL_CUST_IN_PROGRAM', p_error_text => out_err_msg);
END p_enroll_cust_in_program;


--CR55200 start
--Procedure is to provide the reward points for past 30days transactions after enrollment in LRP.
PROCEDURE p_reward_request_processing (i_web_account_id IN VARCHAR2,
                                       out_err_code     OUT NUMBER,
                                       out_err_msg      OUT VARCHAR2)
IS
  pl      q_payload_t;
  nv      q_nameval_tab := q_nameval_tab();
  c_event VARCHAR2(20);

  CURSOR ct_trans (l_esn VARCHAR2)
  IS
    SELECT *
    FROM   table_x_call_trans ct
    WHERE  ct.x_service_id            = l_esn
      AND  ct.x_action_type          IN ('1','3','6')
      AND  TRUNC(ct.x_transact_date) >= TRUNC(SYSDATE-30);
  ct_trans_rec ct_trans%ROWTYPE;

  CURSOR cur_get_esns_by_web_account
  IS
    SELECT pi.part_serial_no
    FROM   table_web_user web,
           table_x_contact_part_inst conpi,
           table_part_inst pi
    WHERE  1                                 = 1
      AND  web.objid                         = i_web_account_id
      AND  pi.objid                          = conpi.x_contact_part_inst2part_inst
      AND  conpi.x_contact_part_inst2contact = web.web_user2contact
      AND  pi.x_domain                       = 'PHONES'
      AND  pi.x_part_inst_status             = '52';
  rec_get_esns_by_web_account cur_get_esns_by_web_account%ROWTYPE;

BEGIN

  --Get all ESNs tied to the web_account that are Active
  FOR rec_get_esns_by_web_account IN cur_get_esns_by_web_account
  LOOP
    --Get all applicable transactions for each ESN and try to deliver LRP pts
    FOR ct_trans_rec IN ct_trans(rec_get_esns_by_web_account.part_serial_no)
    LOOP
      -- Initialize
      pl      := NULL;
      nv      := q_nameval_tab();
      c_event := NULL;

      SELECT DECODE(ct_trans_rec.x_action_type,
                    '1', 'ACTIVATION',
                    '3', 'REACTIVATION',
                    '6', 'REDEMPTION',
                    ct_trans_rec.x_action_text)
        INTO c_event
      FROM   dual;

      sa.queue_pkg.add_nameval_elmt ('ACTION_TYPE'  ,  ct_trans_rec.x_action_type,  nv);
      sa.queue_pkg.add_nameval_elmt ('REASON_CODE'  ,  ct_trans_rec.x_reason,       nv);
      sa.queue_pkg.add_nameval_elmt ('SOURCESYSTEM' ,  ct_trans_rec.x_sourcesystem, nv);
      sa.queue_pkg.add_nameval_elmt ('CT_OBJID'     ,  ct_trans_rec.objid,          nv);
      sa.queue_pkg.add_nameval_elmt ('X_ACTION_TEXT',  ct_trans_rec.x_action_text,  nv);
      sa.queue_pkg.add_nameval_elmt ('X_REASON'     ,  ct_trans_rec.x_reason,       nv);

      --Form the payload type values
      pl := q_payload_t (NULL,                           -- source_type
                         NULL,                           -- source_tbl
                         NULL,                           -- source_status
                         ct_trans_rec.x_service_id,      -- esn
                         ct_trans_rec.x_min,             -- min
                         ct_trans_rec.x_sub_sourcesystem,-- brand
                         c_event,                        -- event_name
                         nv,                             -- varray
                         NULL );                         -- step_complete

    sa.rewards_mgt_util_pkg.p_event_processing(in_event     => pl,
                                               out_err_code => out_err_code,
                                               out_err_msg  => out_err_msg);
    END LOOP;
  END LOOP;
EXCEPTION
WHEN OTHERS THEN
  out_err_code := SQLCODE;
  out_err_msg  := SQLERRM;
END p_reward_request_processing;
--CR55200 end


--
PROCEDURE p_enroll_cust_in_program(
    in_brand           IN VARCHAR2 ,
    in_web_account_id  IN VARCHAR2 ,
    x_subscriber_id    IN VARCHAR2 ,
    x_min              IN VARCHAR2 ,
    x_esn              IN VARCHAR2 ,
    in_program_name    IN VARCHAR2 ,
    in_benefit_type    IN VARCHAR2 ,
    in_enrollment_type IN VARCHAR2 ,
    in_enroll_channel  IN VARCHAR2 ,  -- CR41665 added
    in_enroll_min      IN VARCHAR2 ,  -- CR41665 added
    out_err_code OUT NUMBER ,
    out_err_msg OUT VARCHAR2)
IS
  --
  l_exists               VARCHAR2(1)  := 'N';
  l_exist                NUMBER       := 0;
  l_auto_refill_reenroll VARCHAR2(1)  := 'N';
  l_program_reenroll     VARCHAR2(1)  := 'N';
  l_program_enrollment   VARCHAR2(30) := 'N';
  btrans typ_lrp_benefit_trans;
  benefit typ_lrp_reward_benefit;
  l_reward_benefit_trans_objid X_Reward_Benefit_Transaction.objid%TYPE;
  bobjid x_reward_benefit.objid%TYPE;
  l_prev_reward x_reward_benefit.quantity%TYPE;
  input_validation_failed EXCEPTION;
  l_min table_site_part.x_min%TYPE;
  l_enrolled_status VARCHAR2(30):='NOT ENROLLED'; --Modified for 2269
  l_eligible_status VARCHAR2(20):='N';
  l_promoflag     VARCHAR2(1):='N'; --CR42428
  o_promoflag     VARCHAR2(1):='N'; --CR42428
  l_enroll_min    VARCHAR2(255):=in_enroll_min; --CR41665
  l_enroll_channel VARCHAR2(255):=in_enroll_channel; --CR41665
  --CR55200 Local err variables to pass into p_event_processing
  l_err_code       NUMBER;
  l_err_msg        VARCHAR2(255);
  --
  CURSOR cur_get_esn_for_account (c_web_account_id table_web_user.objid%TYPE)
  IS
    SELECT ee.pgm_enroll2web_user,
      x_program_name,
      pp.x_prog_class,
      ee.x_esn,
      ee.x_enrollment_status
    FROM x_program_parameters pp,
      table_bus_org bo,
      x_program_enrolled ee
    WHERE bo.objid                  = pp.prog_param2bus_org
    AND org_id                      = in_brand
    AND ee.pgm_enroll2pgm_parameter = pp.objid
    AND ee.pgm_enroll2web_user     IS NOT NULL
    AND ee.x_enrollment_status      = 'ENROLLED'
    AND pp.x_prog_class             = 'SWITCHBASE'
    AND ee.x_next_charge_date      IS NOT NULL
    AND ee.pgm_enroll2web_user      = c_web_account_id ;
  rec_get_esn_for_account cur_get_esn_for_account%rowtype;

  l_transaction_status     x_reward_benefit_transaction.transaction_status%type;     -- CR41473 PMistry 08/03/2016 LRP2
BEGIN
  out_err_code := 0;
  out_err_msg  := 'SUCCESS';
  --
  IF upper(NVL(trim(in_brand),'~')) NOT IN ('STRAIGHT_TALK','ST') THEN
    out_err_code :=                      -352;
    out_err_msg  := 'Error. Unsupported or Null values received for IN_BRAND';
    raise input_validation_failed;
  END IF;
  IF upper(NVL(trim(in_program_name),'~')) <> 'LOYALTY_PROGRAM' THEN
    out_err_code                           := -312;
    out_err_msg                            := 'Error. Unsupported or Null values received for IN_PROGRAM_NAME';
    raise input_validation_failed;
  END IF;
  IF upper(NVL(trim(in_benefit_type),'~')) <> 'LOYALTY_POINTS' THEN
    out_err_code                           := -313;
    out_err_msg                            := 'Error. Unsupported or Null values received for IN_BENEFIT_TYPE_CODE';
    raise input_validation_failed;
  END IF;
  IF upper(NVL(trim(in_enrollment_type),'~')) NOT IN ('PROGRAM_ENROLLMENT','AUTO_REFILL') THEN
    out_err_code :=                                -356;
    out_err_msg  := 'Error. Unsupported or Null values received for IN_ENROLLMENT_TYPE';
    raise input_validation_failed;
  END IF;
  IF upper(NVL(trim(in_benefit_type),'~')) = 'LOYALTY_POINTS' AND trim(in_web_account_id) IS NULL THEN
    out_err_code                          := -358;
    out_err_msg                           := 'Error. Account ID is mandatory for Loyalty enrollment';
    raise input_validation_failed;
  END IF;

  ----
    -----Check whether the Promo Group check flag is set on before the customer is validated against the Promotion table.
  --CR42428 starts
  BEGIN
  select x_param_value
  into l_promoflag
  from sa.table_x_parameters p
  where p.x_param_name='LRP_ENROLL_PROMO_ONLY';
  Exception WHEN no_data_found THEN
    l_promoflag := 'N';
  END;

  IF l_promoflag ='Y' THEN

    rewards_mgt_util_pkg.p_customer_in_promo_group(
    in_cust_key          => 'ACCOUNT',
    in_cust_value        => in_web_account_id,
    in_program_name      => in_program_name,
    in_benefit_type_code => 'LOYALTY_POINTS',
    in_brand             => in_brand,
    out_promotional_flag => o_promoflag,
    out_err_code   => out_err_code,
    out_err_msg    => out_err_msg );

    if o_promoflag = 'N' then
        out_err_code := -199;
        out_err_msg  := 'Cannot Enroll. Customer is not part of Promotion Group.';
        raise input_validation_failed;
    END IF;
  ----
  END IF;
  --CR42428 Ends
  -- Initialize BENEFIT TRANSACTION
  btrans := typ_lrp_benefit_trans();
  -- Initialize BENEFIT REWARD RECORD
  benefit := typ_lrp_reward_benefit ();
  --check if customer is enrolled or not
  IF in_enrollment_type <> 'PROGRAM_ENROLLMENT' THEN
    rewards_mgt_util_pkg.p_customer_is_enrolled(in_cust_key => 'ACCOUNT', in_cust_value => in_web_account_id,             --IN_EVENT.accound_id--CHANGE
    in_program_name => in_program_name,                                                                                   --'LOYALTY_PROGRAM',
    in_enrollment_type => 'PROGRAM_ENROLLMENT',                                                                           --'PROGRAM_ENROLLMENT' ENROLLMENT,
    in_brand => in_brand, out_enrollment_status => l_program_enrollment, out_enrollment_elig_status => l_eligible_status, --Modified for 2269
    out_err_code => out_err_code, out_err_msg => out_err_msg );
    --
    IF NVL(l_program_enrollment,'NOT ENROLLED') = 'NOT ENROLLED' --Modified for 2269
      THEN
      out_err_code := -110;
      out_err_msg  := 'Customer Is Not Enrolled for Loyalty Program';
      RETURN;
    END IF;
  END IF;
  --
  --
  -- CR41665 starts
  -- Min associated to the Primary ESN is assumed to be the Enrolled Min.
  if l_enroll_min is null then
    begin
      SELECT pi.part_serial_no
        INTO l_enroll_min
        FROM table_x_contact_part_inst conpi, table_web_user web, table_part_inst pi
       WHERE 1 = 1
         AND web.objid = in_web_account_id
         and web.web_user2contact = conpi.x_contact_part_inst2contact
         and conpi.X_CONTACT_PART_INST2PART_INST = pi.part_to_esn2part_inst
         and x_is_default='1'
         and pi.x_domain='LINES';
    exception when others then
      l_enroll_min:=null;
    end;
  end if;
  --CR41665 ends
  ----
  IF x_esn IS NOT NULL THEN
    BEGIN
      SELECT
        /*+ INDEX(r idx2_rew_prog_enrol)*/
        COUNT(1)
      INTO l_exist
      FROM x_reward_program_enrollment r
      WHERE r.esn             = x_esn
      AND r.enrollment_flag   = 'Y'
      AND r.enrollment_type   = in_enrollment_type
      AND r.brand             = in_brand
      AND r.program_name      = in_program_name
      AND r.benefit_type_code = in_benefit_type
      AND r.enroll_date      IS NOT NULL
      AND r.deenroll_date    IS NULL;
    EXCEPTION
    WHEN OTHERS THEN
      l_exist := 0;
    END;
  ELSIF in_web_account_id IS NOT NULL THEN
    BEGIN
      SELECT
        /*+ INDEX(r idx1_rew_prog_enrol)*/
        COUNT(1)
      INTO l_exist
      FROM x_reward_program_enrollment r
      WHERE r.web_account_id  = in_web_account_id
      AND r.enrollment_flag   = 'Y'
      AND r.enrollment_type   = in_enrollment_type
      AND r.brand             = in_brand
      AND r.program_name      = in_program_name
      AND r.benefit_type_code = in_benefit_type
      AND r.enroll_date      IS NOT NULL
      AND r.deenroll_date    IS NULL;
    EXCEPTION
    WHEN OTHERS THEN
      l_exist := 0;
    END;
  ELSIF x_subscriber_id IS NOT NULL THEN
    BEGIN
      SELECT
        /*+ INDEX(r idx3_rew_prog_enrol)*/
        COUNT(1)
      INTO l_exist
      FROM x_reward_program_enrollment r
      WHERE r.subscriber_id   = x_subscriber_id
      AND r.enrollment_flag   = 'Y'
      AND r.enrollment_type   = in_enrollment_type
      AND r.brand             = in_brand
      AND r.program_name      = in_program_name
      AND r.benefit_type_code = in_benefit_type
      AND r.enroll_date      IS NOT NULL
      AND r.deenroll_date    IS NULL;
    EXCEPTION
    WHEN OTHERS THEN
      l_exist := 0;
    END;
  END IF;
  --
  IF NVL(l_exist,0) = 0 THEN
    INSERT
    INTO x_reward_program_enrollment
      (
        objid,
        brand,
        web_account_id,
        subscriber_id,
        MIN,
        esn,
        benefit_type_code,
        enrollment_flag,
        enroll_date,
        deenroll_date,
        program_name,
        enrollment_type,
        promotion_group,
        enroll_min, --CR41665
        enroll_channel --CR41665
      )
      VALUES
      (
        seq_x_rew_prog_enrol_id.nextval,
        in_brand,
        in_web_account_id,
        x_subscriber_id,
        (
        CASE
          WHEN NVL(in_enrollment_type, 'XX') <> 'PROGRAM_ENROLLMENT'
          THEN x_min
          ELSE NULL
        END),
        (
        CASE
          WHEN NVL(in_enrollment_type, 'XX') <> 'PROGRAM_ENROLLMENT'
          THEN x_esn
          ELSE NULL
        END),
        in_benefit_type,
        'Y',
        SYSDATE,
        NULL,
        in_program_name,
        in_enrollment_type,
        NULL,
        (
        CASE
          WHEN NVL(in_enrollment_type, 'XX') = 'PROGRAM_ENROLLMENT'
          THEN l_enroll_min
          ELSE NULL
        END), --CR41665
        in_enroll_channel --CR41665
      );
    --
    IF in_enrollment_type = 'PROGRAM_ENROLLMENT' THEN
      -- Check whether the customer was enrolled into this program previously
      BEGIN
        SELECT 'Y'
        INTO l_program_reenroll
        FROM x_reward_program_enrollment txpe
        WHERE 1                    = 1
        AND txpe.web_account_id    = in_web_account_id
        AND txpe.enrollment_flag   = 'N'
        AND txpe.enrollment_type   = in_enrollment_type
        AND txpe.brand             = in_brand
        AND txpe.program_name      = in_program_name
        AND txpe.benefit_type_code = in_benefit_type
        AND txpe.enroll_date      IS NOT NULL
        AND txpe.deenroll_date    IS NOT NULL
        AND ROWNUM                 = 1;
      EXCEPTION
      WHEN NO_DATA_FOUND THEN
        l_program_reenroll := 'N';
      WHEN too_many_rows THEN
        l_program_reenroll := 'Y';
      WHEN OTHERS THEN
        l_program_reenroll := 'N';
      END;
      --
      IF l_program_reenroll = 'Y' THEN
        -- Get the previous Reward benefit
        BEGIN
          SELECT quantity
          INTO l_prev_reward
          FROM sa.x_reward_benefit
          WHERE web_account_id  = in_web_account_id
          AND STATUS           <> 'AVAILABLE'
          AND BENEFIT_TYPE_CODE = in_benefit_type
          AND program_name      = in_program_name
          AND brand             = in_brand;
        EXCEPTION
        WHEN OTHERS THEN
          out_err_code := -130;
          out_err_msg  := 'Get the previous Reward benefit failed';
          raise input_validation_failed;
        END;
        -- Insert a Record for Re-enrollment
        btrans.objid                       := 0;
        btrans.trans_date                  := SYSDATE;
        btrans.web_account_id              := in_web_account_id;
        btrans.subscriber_id               := x_subscriber_id;
        btrans.MIN                         := NULL;
        btrans.esn                         := NULL;
        btrans.old_min                     := NULL;
        btrans.old_esn                     := NULL;
        btrans.trans_type                  := 'PROGRAM_ENROLLMENT';
        btrans.trans_desc                  := 'RE-ENROLLMENT IN LOYALTY PROGRAM'; --Modified for 2175
        btrans.amount                      := l_prev_reward * -1;
        btrans.benefit_type_code           := in_benefit_type;
        btrans.action                      := 'DEDUCT';
        btrans.action_type                 := 'FREE';
        btrans.action_reason               := 'RE-ENROLLMENT IN LOYALTY PROGRAM';
        btrans.action_notes                := NULL;
        btrans.benefit_trans2benefit_trans := NULL;
        btrans.svc_plan_pin                := NULL;
        btrans.svc_plan_id                 := NULL;
        btrans.brand                       := in_brand;
        btrans.benefit_trans2benefit       := NULL;
        btrans.agent_login_name            := NULL;
        --btrans.transaction_stauts        := 'COMPLETE' -- CR41473 - LRP2 - sethiraj
        --btrans.maturity_Date             := NULL;      -- CR41473 - LRP2 - sethiraj
        --btrans.expiration_Date           := NULL;      -- CR41473 - LRP2 - sethiraj
        --btrans.source                    := NULL;      -- CR41473 - LRP2 - sethiraj
        --btrans.source_trans_id           := NULL;      -- CR41473 - LRP2 - sethiraj


        --
        p_create_benefit_trans( ben_trans => btrans,
                                reward_benefit_trans_objid => l_reward_benefit_trans_objid,
                                o_transaction_status => l_transaction_status);               -- CR41473 PMistry 08/03/2016 LRP2 added new output parameter to procedure to get the status of transaction the procedure have inserted.

        -- Update the reward status as Available
        BEGIN
          UPDATE sa.x_reward_benefit
          SET status            = 'AVAILABLE',
              quantity          = 0,
              pending_quantity  = 0, -- CR41473 - LRP2 - sethiraj
              total_quantity    = 0, -- CR41473 - LRP2 - sethiraj
              update_date       = sysdate,
              account_status    = 'ENROLLED' --Modified for defect 2269
          WHERE web_account_id  = in_web_account_id
          AND STATUS           <> 'AVAILABLE'
          AND BENEFIT_TYPE_CODE = in_benefit_type
          AND program_name      = in_program_name
          AND brand             = in_brand;
        EXCEPTION
        WHEN OTHERS THEN
          out_err_code := -120;
          out_err_msg  := 'Update reward benefit failed during re enroll';
          raise input_validation_failed;
        END;
        --
        bobjid := f_get_cust_benefit_id ( in_cust_key => 'ACCOUNT', in_cust_value => btrans.web_account_id, in_program_name => 'LOYALTY_PROGRAM', in_benefit_type => 'LOYALTY_POINTS');
        --
        UPDATE x_reward_benefit_transaction rbt
        SET rbt.benefit_trans2benefit = bobjid
        WHERE rbt.objid               = l_reward_benefit_trans_objid;
        --
      END IF;
      --
      --CREATE BENEFIT TRANSACTION RECORD
      btrans.objid          := 0;
      btrans.trans_date     := SYSDATE;
      btrans.web_account_id := in_web_account_id;
      btrans.subscriber_id  := x_subscriber_id;
      btrans.MIN            := NULL;
      btrans.esn            := NULL;
      btrans.old_min        := NULL;
      btrans.old_esn        := NULL;
      btrans.trans_type     := 'PROGRAM_ENROLLMENT';
      btrans.trans_desc     :=
      CASE
      WHEN l_program_reenroll = 'Y' THEN
        'RE-ENROLLMENT IN LOYALTY PROGRAM'
      ELSE
        'Bonus: Enrollment in Loyalty Rewards Program'
      END; --Modified for 2175
      btrans.amount            := NULL;
      btrans.benefit_type_code := in_benefit_type;
      btrans.action            := 'ADD';
      btrans.action_type       := 'FREE';
      btrans.action_reason     :=
      CASE
      WHEN l_program_reenroll = 'Y' THEN
        'RE-ENROLLMENT IN LOYALTY PROGRAM'
      ELSE
        'Bonus: Enrollment in Loyalty Rewards Program'
      END;
      btrans.action_notes                := NULL;
      btrans.benefit_trans2benefit_trans := NULL;
      btrans.svc_plan_pin                := NULL;
      btrans.svc_plan_id                 := NULL;
      btrans.brand                       := in_brand;
      btrans.benefit_trans2benefit       := NULL;
      btrans.agent_login_name            := NULL;
      --
      --CREATE BENEFIT REWARD RECORD
      --
      benefit.objid             := 0;
      benefit.web_account_id    := in_web_account_id;
      benefit.subscriber_id     := x_subscriber_id;
      benefit.MIN               := NULL;
      benefit.esn               := NULL;
      benefit.benefit_owner     := 'ACCOUNT';
      benefit.created_date      := SYSDATE;
      benefit.status            := 'AVAILABLE';
      benefit.notes             := NULL;
      benefit.benefit_type_code := in_benefit_type;
      benefit.update_date       := NULL;
      benefit.expiry_date       := NULL;
      benefit.brand             := in_brand;
      benefit.quantity          := NULL;
      benefit.VALUE             := NULL;
      benefit.program_name      := in_program_name;
      benefit.account_status    := 'ENROLLED'; --Modified for defect 2269
      --
      p_compensate_reward_points( btrans => btrans, benefit => benefit, out_error_num => out_err_code, out_error_message => out_err_msg );
      --get the list of esn related to account
      FOR rec IN cur_get_esn_for_account ( in_web_account_id )
      LOOP
        --
        BEGIN
          SELECT x_min
          INTO l_min
          FROM table_site_part
          WHERE x_service_id = rec.x_esn
          AND part_status    = 'Active';
        EXCEPTION
        WHEN OTHERS THEN
          l_min := NULL;
        END;
        --
        BEGIN
          SELECT 'Y'
          INTO l_auto_refill_reenroll
          FROM sa.X_REWARD_BENEFIT_TRANSACTION
          WHERE esn             = rec.x_esn
          AND trans_type        = 'AUTO_REFILL'
          AND benefit_type_code = in_benefit_type
          AND web_account_id    = in_web_account_id
          AND brand             = in_brand
          AND amount            > 0
          AND ROWNUM            = 1;
        EXCEPTION
        WHEN OTHERS THEN
          l_auto_refill_reenroll := 'N';
        END;
        --
        IF l_auto_refill_reenroll = 'N' THEN
          INSERT
          INTO x_reward_program_enrollment
            (
              objid,
              brand,
              web_account_id,
              subscriber_id,
              MIN,
              esn,
              benefit_type_code,
              enrollment_flag,
              enroll_date,
              deenroll_date,
              program_name,
              enrollment_type,
              promotion_group,
              enroll_min, --CR41665
              enroll_channel --CR41665
            )
            VALUES
            (
              seq_x_rew_prog_enrol_id.nextval,
              in_brand,
              in_web_account_id,
              x_subscriber_id,
              l_min,
              rec.x_esn,
              in_benefit_type,
              'Y',
              SYSDATE,
              NULL,
              in_program_name,
              'AUTO_REFILL',
              NULL,
              null,--in_enroll_min, --CR41665 NULL for Autorefill
              NULL
            );
          --
          -- CREATE BENEFIT TRANSACTION RECORD
          btrans.objid                       := 0;
          btrans.trans_date                  := SYSDATE;
          btrans.web_account_id              := in_web_account_id;
          btrans.subscriber_id               := NULL;
          btrans.MIN                         := l_min;
          btrans.esn                         := rec.x_esn;
          btrans.old_min                     := NULL;
          btrans.old_esn                     := NULL;
          btrans.trans_type                  := 'AUTO_REFILL_EXISTING'; --Modified for CR41661  Converted from AUTO_REFILL
          btrans.trans_desc                  := 'Note: Already enrolled in Auto-Refill';--Modified for 2175
          btrans.amount                      := NULL;
          btrans.benefit_type_code           := in_benefit_type;
          btrans.action                      := 'NOTE'; -- CR41661
          btrans.action_type                 := 'NOTE'; -- CR41661
          btrans.action_reason               := 'Note: Already enrolled in Auto-Refill';
          btrans.benefit_trans2benefit_trans := NULL;
          btrans.svc_plan_pin                := NULL;
          btrans.svc_plan_id                 := NULL;
          btrans.brand                       := in_brand;
          btrans.benefit_trans2benefit       := NULL;
          btrans.agent_login_name            := NULL;
          --
          --CREATE BENEFIT REWARD RECORD
          benefit.objid             := 0;
          benefit.web_account_id    := in_web_account_id;
          benefit.subscriber_id     := NULL;
          benefit.MIN               := NULL;
          benefit.esn               := rec.x_esn;
          benefit.benefit_owner     := 'ACCOUNT';
          benefit.created_date      := SYSDATE;
          benefit.status            := 'AVAILABLE';
          benefit.notes             := NULL;
          benefit.benefit_type_code := in_benefit_type;
          benefit.update_date       := NULL;
          benefit.expiry_date       := NULL;
          benefit.brand             := in_brand;
          benefit.quantity          := NULL;
          benefit.VALUE             := NULL;
          benefit.program_name      := in_program_name;
          benefit.account_status    := 'ENROLLED'; --Modified for 2269
          --
          p_compensate_reward_points( btrans => btrans, benefit => benefit, out_error_num => out_err_code, out_error_message => out_err_msg );
        END IF;
      END LOOP;
      --CR55200 Begin - Only Applicable to first-time PROGRAM_ENROLLMENT scenarios
      IF NVL(l_program_reenroll, 'N') = 'N'
      THEN
        p_reward_request_processing (i_web_account_id => in_web_account_id,
                                     out_err_code     => l_err_code,
                                     out_err_msg      => l_err_msg);
        DBMS_OUTPUT.PUT_LINE('err code: ' || l_err_code || ', err msg: ' || l_err_msg);
      END IF;
      --CR55200 End
    ELSIF in_enrollment_type = 'AUTO_REFILL' AND x_esn IS NOT NULL AND in_web_account_id IS NOT NULL THEN
      --
      -- Check whether points are awarded for the esn in the previous enrollment if any
      BEGIN
        SELECT 'Y'
        INTO l_auto_refill_reenroll
        FROM sa.X_REWARD_BENEFIT_TRANSACTION
        WHERE esn             = x_esn
        AND trans_type        = in_enrollment_type
        AND benefit_type_code = in_benefit_type
        AND web_account_id    = in_web_account_id
        AND brand             = in_brand
        AND amount            > 0
        AND ROWNUM            = 1;
      EXCEPTION
      WHEN NO_DATA_FOUND THEN
        l_auto_refill_reenroll := 'N';
      WHEN OTHERS THEN
        l_auto_refill_reenroll := 'N';
      END;
      --
      --
      IF l_auto_refill_reenroll = 'N' THEN
        --CREATE BENEFIT TRANSACTION RECORD
        btrans.objid                       := 0;
        btrans.trans_date                  := SYSDATE;
        btrans.web_account_id              := in_web_account_id;
        btrans.subscriber_id               := NULL;
        btrans.MIN                         := x_min;
        btrans.esn                         := x_esn;
        btrans.old_min                     := NULL;
        btrans.old_esn                     := NULL;
        btrans.trans_type                  := 'AUTO_REFILL';
        btrans.trans_desc                  := 'Bonus: Enrollment in Auto-Refill'; --Modified for 2175
        btrans.amount                      := NULL;
        btrans.benefit_type_code           := in_benefit_type;
        btrans.action                      := 'ADD';
        btrans.action_type                 := 'FREE';
        btrans.action_reason               := 'Bonus: Enrollment in Auto-Refill';
        btrans.benefit_trans2benefit_trans := NULL;
        btrans.svc_plan_pin                := NULL;
        btrans.svc_plan_id                 := NULL;
        btrans.brand                       := in_brand;
        btrans.benefit_trans2benefit       := NULL;
        btrans.agent_login_name            := NULL;
        --
        --CREATE BENEFIT REWARD RECORD
        benefit.objid             := 0;
        benefit.web_account_id    := in_web_account_id;
        benefit.subscriber_id     := NULL;
        benefit.MIN               := x_min;
        benefit.esn               := x_esn;
        benefit.benefit_owner     := 'ACCOUNT';
        benefit.created_date      := SYSDATE;
        benefit.status            := 'AVAILABLE';
        benefit.notes             := NULL;
        benefit.benefit_type_code := in_benefit_type;
        benefit.update_date       := NULL;
        benefit.expiry_date       := NULL;
        benefit.brand             := in_brand;
        benefit.quantity          := NULL;
        benefit.VALUE             := NULL;
        benefit.program_name      := in_program_name;
        benefit.account_status    := 'ENROLLED'; --Modified for 2269
        --
        p_compensate_reward_points( btrans => btrans, benefit => benefit, out_error_num => out_err_code, out_error_message => out_err_msg );
      ELSE
        -- Insert a Record for Auto refill Re-enrollment
        btrans.objid                       := 0;
        btrans.trans_date                  := SYSDATE;
        btrans.web_account_id              := in_web_account_id;
        btrans.subscriber_id               := x_subscriber_id;
        btrans.MIN                         := x_min;
        btrans.esn                         := x_esn;
        btrans.old_min                     := NULL;
        btrans.old_esn                     := NULL;
        btrans.trans_type                  := 'AUTO_REFILL';
        btrans.trans_desc                  := 'RE-ENROLLMENT IN AUTO-REFILL'; --Modified for 2175
        btrans.amount                      := 0;
        btrans.benefit_type_code           := in_benefit_type;
        btrans.action                      := 'NOTE';
        btrans.action_type                 := 'NOTE';
        btrans.action_reason               := 'RE-ENROLLMENT IN AUTO-REFILL';
        btrans.action_notes                := NULL;
        btrans.benefit_trans2benefit_trans := NULL;
        btrans.svc_plan_pin                := NULL;
        btrans.svc_plan_id                 := NULL;
        btrans.brand                       := in_brand;
        btrans.benefit_trans2benefit       := NULL;
        btrans.agent_login_name            := NULL;
        --
        p_create_benefit_trans( ben_trans => btrans,
                                reward_benefit_trans_objid => l_reward_benefit_trans_objid,
                                o_transaction_status => l_transaction_status);               -- CR41473 PMistry 08/03/2016 LRP2 added new output parameter to procedure to get the status of transaction the procedure have inserted.

        --
        bobjid := f_get_cust_benefit_id ('ACCOUNT', btrans.WEB_ACCOUNT_ID, 'LOYALTY_PROGRAM', 'LOYALTY_POINTS');
        --CR54443 changes start
        p_update_benefit(in_cust_key            =>  'OBJID',
                         in_cust_value          =>  bobjid,
                         in_program_name        =>  '',
                         in_benefit_type        =>  '',
                         in_brand               =>  '',
                         in_new_min             =>  '',
                         in_new_esn             =>  '',
                         in_new_status          =>  'AVAILABLE',
                         in_new_notes           =>  '',
                         in_new_expiry_date     =>  NULL,
                         in_change_quantity     =>  0,                  -- CR41473-LRP2
                         in_transaction_status  =>  l_transaction_status, -- CR41473-LRP2
                         in_value               =>  NULL,                 -- CR41473-LRP2
                         in_account_status      =>  NULL); --ARCURRENT --Modified for defect 2269
        --CR54443 changes end
        --
        UPDATE x_reward_benefit_transaction rbt
        SET rbt.benefit_trans2benefit = bobjid
        WHERE rbt.objid               = l_reward_benefit_trans_objid;
        --
      END IF;
    END IF;
    --
  END IF; -- IF NVL(l_exist,0) = 0
  -- check if customer is enrolled or not
  --
  --IF l_exists     = 'Y' THEN
  IF l_exist     > 0 THEN   -- CR41473 Modified the condition to use right variable
    out_err_code := -100;
    out_err_msg  := 'Customer Is Already Enrolled';
    RAISE input_validation_failed;
  END IF;
  --IF l_exists     = 'Y' THEN


EXCEPTION
WHEN input_validation_failed THEN
  out_err_msg := out_err_msg ;--|| ' - ' ||dbms_utility.format_error_backtrace ;
  RETURN;
-- CR42235 Changes Starts
WHEN DUP_VAL_ON_INDEX THEN
  out_err_code := -99;
  out_err_msg  := 'p_enroll_cust_in_program ='||SUBSTR(sqlerrm, 1, 2000)|| ' - ' ||dbms_utility.format_error_backtrace;
-- CR42235 Changes Ends
WHEN OTHERS THEN
  out_err_code := -99;
  out_err_msg  := 'P_ENROLL_CUSTOMER_IN_PROGRAM ='||SUBSTR(sqlerrm, 1, 2000)|| ' - ' ||dbms_utility.format_error_backtrace;
  ota_util_pkg.err_log (p_action => 'CALLING REWARDS_MGT_UTIL_PKG.P_ENROLL_CUST_IN_PROGRAM', p_error_date => SYSDATE, p_key => in_web_account_id, p_program_name => 'REWARDS_MGT_UTIL_PKG.P_ENROLL_CUST_IN_PROGRAM', p_error_text => out_err_msg);
END p_enroll_cust_in_program;
---****************************
PROCEDURE p_enroll_cust_in_program(
    in_brand           IN VARCHAR2 ,
    in_web_account_id  IN VARCHAR2 ,
    x_subscriber_id    IN VARCHAR2 ,
    x_min              IN VARCHAR2 ,
    x_esn              IN VARCHAR2 ,
    in_program_name    IN VARCHAR2 ,
    in_benefit_type    IN VARCHAR2 ,
    in_enrollment_type IN VARCHAR2 ,
    in_source_system   IN VARCHAR2 ,
    out_err_code OUT NUMBER ,
    out_err_msg OUT VARCHAR2)
IS
  --cst customer_type();
  l_err_code NUMBER;
  l_err_msg  VARCHAR2(1000);
  l_login_name table_web_user.login_name%type;
  l_last_name table_contact.last_name%type;
  l_first_name table_contact.first_name%type;
  l_email table_contact.e_mail%type;
  l_address_1 table_contact.address_1%type;
  l_address_2 table_contact.address_2%type;
  l_city table_contact.city%type;
  l_state table_contact.state%type;
  l_zipcode table_contact.zipcode%type;
  l_country table_contact.country%type;
  l_co_objid table_contact.objid%type;
  l_pymt_src_id NUMBER;
  in_rec sa.typ_pymt_src_dtls_rec :=sa.typ_pymt_src_dtls_rec();
BEGIN
  --
  out_err_code := 0;
  --
  IF in_source_system = 'TAS' THEN
    BEGIN
      SELECT wu.login_name ,
        cu.last_name ,
        cu.first_name ,
        wu.S_LOGIN_NAME ,
        cu.address_1 ,
        cu.address_2 ,
        cu.city ,
        cu.state ,
        cu.zipcode ,
        cu.country ,
        cu.objid
      INTO l_login_name ,
        l_last_name ,
        l_first_name ,
        l_email ,
        l_address_1 ,
        l_address_2 ,
        l_city ,
        l_state ,
        l_zipcode ,
        l_country ,
        l_co_objid
      FROM table_web_user wu,
        table_contact cu
      WHERE wu.objid         = in_web_account_id
      AND wu.web_user2contact=cu.objid;
    EXCEPTION
    WHEN OTHERS THEN
      out_err_code := 100;
      out_err_msg  := 'Failed while fetching the contact details';
      RETURN;
    END;
    --
    --ADD PAYMENT SOURCE
    --in_rec sa.typ_pymt_src_dtls_rec := sa.typ_pymt_src_dtls_rec ( NULL, 'APS', 'ACTIVE', NULL, l_login_name, NULL, l_first_name, l_last_name, , sa.address_type_rec (l_address_line1, l_address_line_2, l_city, l_state, l_country, l_zipcode),NULL, NULL, sa.typ_aps_info ('LOYALTY_PTS','TF_POINTS_PYMT_TYPE','LTPS_'||l_email));
    in_rec.payment_source_id:=NULL;
    in_rec.payment_type     := 'APS';
    in_rec.payment_status   := 'ACTIVE';
    in_rec.is_default       := NULL;
    in_rec.user_id          := l_login_name;
    in_rec.cc_info          := NULL;
    in_rec.first_name       := l_first_name;
    in_rec.last_name        := l_last_name;
    in_rec.email            := l_email;
    in_rec.address_info     := sa.address_type_rec (l_address_1, l_address_2, l_city, l_state, l_country, l_zipcode);
    in_rec.secure_date      := NULL;
    in_rec.ach_info         := NULL;
    in_rec.aps_info         := sa.typ_aps_info ('LOYALTY_PTS','TF_POINTS_PYMT_TYPE','LTPS_'||l_co_objid);
    -- CHANGED THE APPLICATION_KEY FROM EMAIL (l_email) TO WEB CONTACT OBJID (l_co_objid)
    -- TO AVOID AN ERROR ON NEW ACCOUNTS THAT USE AN EMAIL THAT A PREVIOUS ACCOUNT USED TO CREATE THE LRP ENROLLMENT
    -- THE EMAIL IS NOT UPDATED IN THIS TABLE AND REMAINS BOUND AS WELL AS PART OF THE UNIQUE KEY
    -- CHANGES IN THE CONTACT OR WEBACCOUNT,
    -- IT DOES NOT CHANGE HERE AND CAUSES ERRORS DURING THE ACCOUNT CREATION FOR ANYONE USING THE SAME EMAIL
    -- AFTER DISCUSSING W/SURESH M. THERE ARE NO EXTERNAL SOURCES USING THIS COLUMN.

    sa.payment_services_pkg.addpaymentsource ( p_login_name => l_login_name, p_bus_org => 'STRAIGHT_TALK', p_esn => x_esn, p_rec => in_rec, op_pymt_src_id => l_pymt_src_id, op_err_num => out_err_code, op_err_msg => out_err_msg );
    --
  END IF;
  --
  if out_err_code = '-3' then
    -- -3 is Customer Is Already Enrolled
    out_err_code := '0';
    dbms_output.put_line('p_enroll_cust_in_program start 2 ('||out_err_code||')');
  end if;
  p_enroll_cust_in_program ( in_brand             =>  in_brand ,
                             in_web_account_id    =>  in_web_account_id ,
                             x_subscriber_id      =>  x_subscriber_id ,
                             x_min                =>  x_min ,
                             x_esn                =>  x_esn ,
                             in_program_name      =>  in_program_name ,
                             in_benefit_type      =>  in_benefit_type ,
                             in_enrollment_type   =>  in_enrollment_type ,
                             in_enroll_channel    =>  in_source_system,  -- CR41665 added
                             in_enroll_min        =>  NULL,          -- CR41665 added
                             out_err_code         =>  l_err_code ,
                             out_err_msg          =>  l_err_msg );
  if l_err_code = '-100' then
  -- -100 is Customer Is Already Enrolled
    out_err_code := '0';
    out_err_msg := 'Success';
    dbms_output.put_line('p_enroll_cust_in_program start 3 ('||out_err_code||')');
  else
    out_err_code := l_err_code;
    out_err_msg  := l_err_msg;
  end if;


  if out_err_code = '0' then
    out_err_msg := 'Success';
  end if;
  --
  --
EXCEPTION
WHEN OTHERS THEN
  out_err_code := -99;
  out_err_msg  := 'P_ENROLL_CUSTOMER_IN_PROGRAM ='||SUBSTR(sqlerrm, 1, 2000)|| ' - ' ||dbms_utility.format_error_backtrace;
  ota_util_pkg.err_log (p_action => 'CALLING REWARDS_MGT_UTIL_PKG.P_ENROLL_CUST_IN_PROGRAM', p_error_date => SYSDATE, p_key => in_web_account_id, p_program_name => 'REWARDS_MGT_UTIL_PKG.P_ENROLL_CUST_IN_PROGRAM', p_error_text => out_err_msg);
END p_enroll_cust_in_program;
--
PROCEDURE p_get_corp_card_info(
    in_esn   IN VARCHAR2,
    in_brand IN VARCHAR2,
    o_corp_status OUT VARCHAR2,
    o_err_code OUT NUMBER,
    o_err_msg OUT VARCHAR2)
IS
  --------------------------------------------------------------------------------------------
  -- Author: Usha S
  -- Date: 2015/12/30
  -- <CR# 33098> Corporate Card
  --
  -- Revision 1.1  yyyy/mm/dd hh:mm:ss  <tf userid>
  -- <CR# Description>
  --
  --------------------------------------------------------------------------------------------
  validation_failed EXCEPTION;
  v_red_code        VARCHAR2(50);
BEGIN
  o_corp_status   :='N';
  o_err_code      := 0;
  o_err_msg       :='SUCCESS';
  IF in_esn       IS NULL THEN
    o_corp_status := '';
    o_err_code    := -321;
    o_err_msg     := 'Error. Invalid or null value received for Input ESN';
    raise validation_failed;
  elsif in_brand  IS NULL THEN
    o_corp_status := '';
    o_err_code    := -321;
    o_err_msg     := 'Error. Invalid or Null value received for Input Brand';
    raise validation_failed;
  END IF;
  BEGIN
    SELECT X_RED_CODE
    INTO v_red_code
    FROM sa.TABLE_X_CALL_TRANS CT,
      sa.TABLE_X_RED_CARD RC
    WHERE CT.OBJID    = RC.RED_CARD2CALL_TRANS
    AND X_SERVICE_ID  = in_esn
    AND X_ACTION_TYPE = 6;
  EXCEPTION
  WHEN OTHERS THEN
    v_red_code :=NULL;
    o_err_code :=-323;
    o_err_msg  :='Error. Invalid ESN or Brand provided';
    RAISE validation_failed;
  END;
  BEGIN
    SELECT 'Y'
    INTO o_corp_status
    FROM table_part_inst pi,
      table_mod_level ml ,
      table_part_num pn ,
      table_bus_org bo,
      TABLE_INV_BIN IB,
      TABLE_SITE TS
    WHERE pi.part_serial_no     = v_red_code
    AND pi.n_part_inst2part_mod = ml.objid
    AND ml.part_info2part_num   = pn.objid
    AND pn.part_num2bus_org     = bo.objid
    AND IB.OBJID                = PI.PART_INST2INV_BIN
    AND TS.SITE_ID              = IB.BIN_NAME
    AND TS.NAME LIKE 'CORP FREE%'
    AND PI.X_DOMAIN = 'REDEMPTION CARDS'
    AND PN.DOMAIN   = 'REDEMPTION CARDS'
    AND bo.NAME     = in_brand;
  EXCEPTION
  WHEN OTHERS THEN
    o_corp_status:='N';
  END;
  IF o_corp_status='N' THEN
    o_err_code   :=-320;
    o_err_msg    :='Error. This ESN is not associated with Corporate card';
    RAISE validation_failed;
    /*ELSIF o_corp_status='I' THEN
    o_corp_status:='N';
    o_err_code   :=-323;
    o_err_msg    :='Error. Invalid ESN or Brand provided';
    RAISE validation_failed;*/
  END IF;
EXCEPTION
WHEN VALIDATION_FAILED THEN
  RETURN;
WHEN OTHERS THEN
  o_corp_status:='N';
  o_err_code   :=-99;
  o_err_msg    :='Error in p_get_corp_card_info: '||sqlerrm||' - ' || dbms_utility.format_error_backtrace;
  --sa.ota_util_pkg.err_log ( p_action => 'OTHERS EXCEPTION', p_error_date => sysdate, p_key => 'LRP', p_program_name => 'p_get_corp_card_info', p_error_text => 'input params: ' || 'in_esn ='||in_esn || ', in_brand='|| in_brand||', o_err_code='||o_err_code || ', o_err_msg='|| o_err_msg );
END p_get_corp_card_info;
----Modified for 2269
PROCEDURE p_update_benefit_status(
    i_esn          IN VARCHAR2,
    i_new_status   IN VARCHAR2,
    i_brand        IN VARCHAR2,
    i_program_name IN VARCHAR2, -- 'LOYALTY_PROGRAM'
    i_benefit_type IN VARCHAR2, --'LOYALTY_POINTS'
    o_err_code OUT NUMBER,
    o_err_msg OUT VARCHAR2)
IS
  rc customer_type;
  cst customer_type;
  l_web_account_id  VARCHAR2(100);
  l_enrolled_status VARCHAR2(30) :='NOT ENROLLED';
  l_eligible_status VARCHAR2(20) :='N';
  l_enrollment_type VARCHAR2(100):='PROGRAM_ENROLLMENT';
  btrans typ_lrp_benefit_trans;
  l_risk_status                VARCHAR2(100);
  l_reward_benefit_trans_objid NUMBER;

  l_transaction_status     x_reward_benefit_transaction.transaction_status%type;     -- CR41473 PMistry 08/03/2016 LRP2

BEGIN
  rc := customer_type ( i_esn => i_esn );
  -- with the esn, this is getting all the information related to that esn
  cst              := rc.get_web_user_attributes;
  l_web_account_id := cst.web_user_objid;
  --
  sa.rewards_mgt_util_pkg.p_customer_is_enrolled (in_cust_key => 'ACCOUNT', in_cust_value => l_web_account_id, in_program_name => i_program_name, --'LOYALTY_PROGRAM',
  in_enrollment_type => l_enrollment_type,                                                                                                        --'PROGRAM_ENROLLMENT' ENROLLMENT,
  in_brand => i_brand, out_enrollment_status => l_enrolled_status, out_enrollment_elig_status => l_eligible_status, out_err_code => o_err_code, out_err_msg => o_err_msg );
  --
  --IF ENROLLED IN PROGRAM
  IF l_enrolled_status                  = 'ENROLLED' AND i_new_status = 'RISK ASSESSMENT' THEN
    btrans                             := typ_lrp_benefit_trans();
    btrans.objid                       := 0;
    btrans.trans_date                  := SYSDATE;
    btrans.web_account_id              := l_web_account_id;
    btrans.subscriber_id               := NULL;
    btrans.MIN                         := NULL;
    btrans.esn                         := NULL;
    btrans.old_min                     := NULL;
    btrans.old_esn                     := NULL;
    btrans.trans_type                  := l_enrollment_type;
    btrans.trans_desc                  := 'RISK ASSESSMENT';
    btrans.amount                      := 0;
    btrans.benefit_type_code           := i_benefit_type;
    btrans.action                      := 'NOTE';
    btrans.action_type                 := 'NOTE';
    btrans.action_reason               := 'RISK ASSESSMENT';
    btrans.action_notes                := NULL;
    btrans.benefit_trans2benefit_trans := NULL;
    btrans.svc_plan_pin                := NULL;
    btrans.svc_plan_id                 := NULL;
    btrans.brand                       := i_brand;
    btrans.benefit_trans2benefit       := NULL;
    btrans.agent_login_name            := NULL;
    --
    p_create_benefit_trans( ben_trans => btrans,
                            reward_benefit_trans_objid => l_reward_benefit_trans_objid,
                            o_transaction_status => l_transaction_status);               -- CR41473 PMistry 08/03/2016 LRP2 added new output parameter to procedure to get the status of transaction the procedure have inserted.

    UPDATE x_reward_benefit xrb
    SET xrb.account_status    = 'RISK ASSESSMENT',
      xrb.status              = 'HOLD'
    WHERE xrb.web_account_id  = l_web_account_id
    AND xrb.program_name      = i_program_name
    AND xrb.Benefit_Type_code = i_benefit_type;
    --
  ELSIF l_enrolled_status = 'RISK ASSESSMENT' AND i_new_status = 'USED' THEN
    l_risk_status        :='N';
    BEGIN
      SELECT 'Y'
      INTO l_risk_status
      FROM sa.table_web_user web,
        sa.table_x_contact_part_inst conpi,
        sa.table_part_inst pi_esn
      WHERE web.web_user2contact              = conpi.x_contact_part_inst2contact
      AND conpi.x_contact_part_inst2part_inst = pi_esn.objid
      AND web.objid                           = l_web_account_id
      AND PI_ESN.X_DOMAIN                     = 'PHONES'
      AND pi_esn.part_serial_no              <> i_esn
      AND pi_esn.x_part_inst_status           = '56';
    EXCEPTION
    WHEN no_data_found THEN
      l_risk_status:='N';
    WHEN too_many_rows THEN
      l_risk_status:='Y';
    WHEN OTHERS THEN
      l_risk_status:='N';
    END;
    --
    IF l_risk_status                      = 'N' THEN
      btrans                             := typ_lrp_benefit_trans();
      btrans.objid                       := 0;
      btrans.trans_date                  := SYSDATE;
      btrans.web_account_id              := l_web_account_id;
      btrans.subscriber_id               := NULL;
      btrans.MIN                         := NULL;
      btrans.esn                         := NULL;
      btrans.old_min                     := NULL;
      btrans.old_esn                     := NULL;
      btrans.trans_type                  := l_enrollment_type;
      btrans.trans_desc                  := 'ENROLLED';
      btrans.amount                      := 0;
      btrans.benefit_type_code           := i_benefit_type;
      btrans.action                      := 'NOTE';
      btrans.action_type                 := 'NOTE';
      btrans.action_reason               := 'ENROLLED';
      btrans.action_notes                := NULL;
      btrans.benefit_trans2benefit_trans := NULL;
      btrans.svc_plan_pin                := NULL;
      btrans.svc_plan_id                 := NULL;
      btrans.brand                       := i_brand;
      btrans.benefit_trans2benefit       := NULL;
      btrans.agent_login_name            := NULL;
      --
      p_create_benefit_trans( ben_trans => btrans,
                              reward_benefit_trans_objid => l_reward_benefit_trans_objid,
                              o_transaction_status => l_transaction_status);               -- CR41473 PMistry 08/03/2016 LRP2 added new output parameter to procedure to get the status of transaction the procedure have inserted.

      UPDATE x_reward_benefit xrb
      SET xrb.account_status    = 'ENROLLED',
        xrb.status              = 'AVAILABLE'
      WHERE xrb.web_account_id  = l_web_account_id
      AND xrb.program_name      = i_program_name
      AND xrb.Benefit_Type_code = i_benefit_type;
      --
    END IF;
  END IF;
  --
EXCEPTION
-- CR42235 Changes Starts
WHEN DUP_VAL_ON_INDEX THEN
  o_err_code := -99;
  o_err_msg  := 'p_update_benefit_status ='||SUBSTR(sqlerrm, 1, 2000)|| ' - ' ||dbms_utility.format_error_backtrace;
-- CR42235 Changes Ends
WHEN OTHERS THEN
  o_err_code :=-99;
  o_err_msg  :='Error in p_get_corp_card_info: '||sqlerrm||' - ' || dbms_utility.format_error_backtrace;
  --
END p_update_benefit_status;
----Modified for 2269
--
PROCEDURE p_event_processing(
    in_event IN OUT q_payload_t,
    out_err_code OUT NUMBER,
    out_err_msg OUT VARCHAR2 )
IS
  --
  l_rbt_count     NUMBER := 0; -- CR41341
  pts1            NUMBER;
  bobjid          NUMBER;
  svc_plan_points NUMBER;
  ln_reward_benefit_objid x_reward_benefit.objid%TYPE;
  ln_reward_benefit_trans_objid x_reward_benefit_transaction.objid%TYPE;
  lv_program_name             VARCHAR2(100) := 'LOYALTY_PROGRAM';
  lv_enrollment_type          VARCHAR2(100) := 'PROGRAM_ENROLLMENT';
  l_enrolled_flag             VARCHAR2(200) := 'N';
  lv_reward_benefit_calculate VARCHAR2(1)   := 'Y';
  --
  btrans typ_lrp_benefit_trans;
  benefit typ_lrp_reward_benefit;
  --
  rc customer_type;
  cstwb customer_type;
  cstsp customer_type;
  --
  l_action_type     VARCHAR2(20) ;
  l_action_text     VARCHAR2(20) ;
  l_reason          VARCHAR2(500);
  l_service_plan_id NUMBER ;
  payload_rec q_payload_t ;
  l_ildten_exists       VARCHAR2(1) := 'N';
  l_ild_service_plan_id NUMBER;
  l_amount              NUMBER      := 0;
  l_reward_objid        NUMBER      := 0;
  l_phone_upgrade_chk   VARCHAR2(1) := 'N';
  l_auto_refill_enroll  VARCHAR2(1) := 'N';
  l_is_pin              VARCHAR2(1) := 'N';
  l_port_in             VARCHAR2(1) := 'N';
  l_purchase_at         VARCHAR2(1) := 'N';
  l_with_pin            VARCHAR2(1) := 'N';
  l_ct_objid table_x_call_trans.objid%TYPE;
  l_ct_x_reason table_x_call_trans.X_REASON%TYPE;
  l_source_system table_x_call_trans.X_SOURCESYSTEM%TYPE;
  l_ild_pin VARCHAR2(200);
  l_min table_site_part.x_min%TYPE;
  l_awop_ref_pin    VARCHAR2(200);
  l_awop_ref_esn    VARCHAR2(200);
  l_replace_ref_pin VARCHAR2(200);-- For defect 2246
  l_replace_ref_esn VARCHAR2(200);-- For defect 2246
  l_reward_ben_trans_rec x_reward_benefit_transaction%ROWTYPE;
  l_reward_benefit_trans_objid x_reward_benefit_transaction.objid%TYPE;
  l_reserved_card   VARCHAR2(1) := 'N';
  l_enrolled_status VARCHAR2(30):='NOT ENROLLED'; --Modified for 2269
  l_eligible_status VARCHAR2(20):='N';
  l_autorefill_flag VARCHAR2(10):= 'N';
  ct  call_trans_type := call_trans_type();
  o_corp_status  VARCHAR2(1) := 'N'; -- CR49699 Tim 5/25/2017
  l_payment_type VARCHAR2(30);       -- C88132
  --
  -- CR41473 Start 08/03/2016 PMistry LRP2
    cursor cur_pin_detail (c_ct_objid   number) is
            select pn.part_type
            from table_x_red_card rc, table_part_num pn, table_mod_level ml
            where 1 = 1
            and   rc.RED_CARD2CALL_TRANS = c_ct_objid
            and   ml.objid = RC.X_RED_CARD2PART_MOD
            and   pn.objid = ml.part_info2part_num
            and   pn.part_type = 'FREE';

    rec_pin_detail  cur_pin_detail%rowtype;

  l_transaction_status      x_reward_benefit_transaction.transaction_status%type;     -- CR41473 PMistry 08/03/2016 LRP2
  l_action_notes            varchar2(300 char);
  -- CR41473 End

BEGIN

  --
  out_err_code := 0;
  out_err_msg  := 'SUCCESS';
  --
  rc := customer_type ( i_esn => in_event.esn );
  -- with the esn, this is getting all the information related to that esn
  cstwb := rc.get_web_user_attributes;
  cstsp := rc.get_service_plan_attributes;
  --
  payload_rec := IN_EVENT;
  --
  -- Initialize BENEFIT TRANSACTION
  btrans := typ_lrp_benefit_trans();
  -- Initialize BENEFIT REWARD RECORD
  benefit := typ_lrp_reward_benefit (); --Modified for defect 2269
  --
  sa.rewards_mgt_util_pkg.p_customer_is_enrolled(in_cust_key => 'ACCOUNT', in_cust_value => cstwb.web_user_objid,        --IN_EVENT.accound_id--CHANGE
  in_program_name => lv_program_name,                                                                                    --'LOYALTY_PROGRAM',
  in_enrollment_type => lv_enrollment_type,                                                                              --'PROGRAM_ENROLLMENT' ENROLLMENT,
  in_brand => in_event.brand, out_enrollment_status => l_enrolled_flag, out_enrollment_elig_status => l_eligible_status, --Modified for 2269
  out_err_code => out_err_code, out_err_msg => out_err_msg );
  --
  --IF ENROLLED IN PROGRAM
  IF l_enrolled_flag IN ('ENROLLED','SUSPENDED','RISK ASSESSMENT') THEN
    --
    BEGIN
      SELECT x_min
      INTO l_min
      FROM table_site_part
      WHERE x_service_id = in_event.esn
      AND part_status    = 'Active';
    EXCEPTION
    WHEN OTHERS THEN
      l_min := NULL;
    END;
    --
    BEGIN
      SELECT web.OBJID
      INTO cstwb.web_user_objid
      FROM sa.table_web_user web,
        sa.table_x_contact_part_inst conpi,
        sa.table_part_inst pi_esn
      WHERE web.web_user2contact              = conpi.x_contact_part_inst2contact
      AND conpi.x_contact_part_inst2part_inst = pi_esn.objid
      AND PI_ESN.X_DOMAIN                     = 'PHONES'
      AND pi_esn.part_serial_no               = in_event.esn;
    EXCEPTION
    WHEN OTHERS THEN
      NULL;
    END;
    --
    FOR i IN payload_rec.nameval.FIRST..payload_rec.nameval.LAST
    LOOP
      --
      IF payload_rec.nameval(i).fld = 'X_PIN' AND NVL(payload_rec.nameval(i).val,0) <> 0 THEN
        --
        l_reason := payload_rec.nameval(i).val;
        --
        BEGIN
          SELECT sa.get_service_plan_id ( f_esn      => in_event.esn ,
                                          f_red_code => l_reason     )
          INTO   l_service_plan_id
          FROM   DUAL;
        EXCEPTION
        WHEN OTHERS THEN
          NULL;
        END;
        --
        cstsp.service_plan_objid := l_service_plan_id ;
        EXIT;
        --
      ELSIF payload_rec.nameval(i).fld = 'CT_OBJID' THEN
        --
        l_ct_objid := payload_rec.nameval(i).val;
        --
        -- Fetch x_reason from call_trans
        BEGIN
          SELECT x_reason,
                 x_action_type,
                 x_action_text
          INTO   l_ct_x_reason,
                 ct.action_type,
                 ct.action_text
          FROM   table_x_call_trans
          WHERE  objid = l_ct_objid;
         EXCEPTION
           WHEN OTHERS THEN
             l_ct_x_reason := NULL;
        END;
        --
        -- if the call trans is a queued card transaction
        IF ct.action_type = '401' AND
           ct.action_text = 'QUEUED'
        THEN
          -- set pin
          l_reason := l_ct_x_reason;
        END IF;

        -- Commented logic for CR41232 (duplicate query)
        -- get the reason only if the call trans is a queued card
        --BEGIN
        --  SELECT x_reason
        --  INTO   l_reason
        --  FROM   table_x_call_trans
        --  WHERE  objid = l_ct_objid
        --  AND    x_action_type = '401'
        --  AND    x_action_text = 'QUEUED';
        -- EXCEPTION
        --   WHEN OTHERS THEN
        --     NULL;
        --END;
        --
        IF l_reason IS NOT NULL -- PIN Queued scenario
          THEN
          --
          BEGIN
            SELECT sa.get_service_plan_id ( f_esn      => in_event.esn ,
                                            f_red_code => l_reason     )
            INTO   l_service_plan_id
            FROM   DUAL;
          EXCEPTION
          WHEN OTHERS THEN
            NULL;
          END;
          --
          cstsp.service_plan_objid := l_service_plan_id ;
          --
          EXIT;
        ELSE -- NON Queued Scenario
          --
          BEGIN -- Assign pin to l_reason
            SELECT x_red_code
            INTO   l_reason
            FROM   table_x_red_card rc
            WHERE  red_card2call_trans = l_ct_objid;
            --
            l_is_pin :=  'Y'; -- CR42105
            --
          EXCEPTION
             WHEN OTHERS THEN
               l_reason := payload_rec.nameval(i).val;
          END;
          --
          -- Block Reserved cards
          BEGIN -- check whether that pin is reserved already
            SELECT 'Y'
            INTO   l_reserved_card
            FROM   table_x_call_trans
            WHERE  x_action_type = '401'
            AND    x_action_text = 'QUEUED'
            AND    x_reason = l_reason
            AND    ( x_service_id = in_event.esn OR
                     x_service_id = ( SELECT esn
                                      FROM   ( SELECT cd.x_value esn
                                               FROM   table_case tc,
                                                      table_x_case_detail cd
                                               WHERE  UPPER(tc.X_CASE_TYPE) IN ( 'PORT IN')
                                               AND    cd.detail2case = tc.objid
                                               AND    cd.x_name = 'CURRENT_ESN'
                                               AND    tc.x_esn = in_event.esn
                                               UNION
                                               SELECT tc.x_esn esn
                                               FROM   table_case tc,
                                                      table_x_case_detail cd
                                               WHERE  UPPER(tc.X_CASE_TYPE) = 'PHONE UPGRADE'
                                               AND    cd.detail2case = tc.objid
                                               AND    cd.x_name = 'NEW_ESN'
                                               AND    cd.X_VALUE = in_event.esn
                                             )
                                      WHERE ROWNUM = 1
                                    )
                   );
            --
            --RETURN; -- Commented logic for CR41232
            --
           EXCEPTION
             WHEN OTHERS THEN
               NULL;
          END;
          --
          --
          l_ildten_exists := 'N';
          --
          IF cstwb.esn IS NOT NULL THEN
            BEGIN
              SELECT 'Y'
              INTO l_ildten_exists
              FROM table_x_ild_transaction
              WHERE x_esn                  = cstwb.esn
              AND x_ild_trans2call_trans+0 = payload_rec.nameval(i).val
              AND x_product_id             = 'ST_ILD_10'
              AND rownum                   = 1;
            EXCEPTION
            WHEN OTHERS THEN
              BEGIN -- Check whether it is ILD CARD
                SELECT 'Y'
                INTO l_ildten_exists
                FROM table_x_red_card rc,
                  sa.TABLE_MOD_LEVEL ml,
                  sa.table_part_num pn,
                  sa.table_part_class pc
                WHERE rc.RED_CARD2CALL_TRANS = payload_rec.nameval(i).val
                AND rc.x_red_card2part_mod   = ml.objid
                AND ml.PART_INFO2PART_NUM    = pn.objid
                AND pn.PART_NUM2PART_CLASS   = pc.objid
                AND rc.x_result              = 'Completed'
                AND pc.name                  = 'STILDCARD';
              EXCEPTION
              WHEN OTHERS THEN
                l_ildten_exists := 'N';
              END;
            END;
          END IF;
          --
          IF l_ildten_exists = 'Y' THEN
            BEGIN
              SELECT vas_service_id
              INTO l_ild_service_plan_id
              FROM vas_programs_view
              WHERE vas_bus_org = 'STRAIGHT_TALK'
              AND product_id    = 'ST_ILD_10';
            EXCEPTION
            WHEN OTHERS THEN
              NULL;
            END ;
            cstsp.service_plan_objid := l_ild_service_plan_id ;
            --l_reason := payload_rec.nameval(i).val;
            /*BEGIN
            SELECT x_red_code
            INTO   l_ild_pin
            FROM   table_x_red_card rc
            WHERE  red_card2call_trans = payload_rec.nameval(i).val;
            EXCEPTION
            WHEN OTHERS THEN
            l_ild_pin := Null;
            END;*/
            l_ild_pin := l_reason;
            --
            IF l_ild_service_plan_id IS NOT NULL AND l_ild_pin IS NOT NULL THEN
              FOR each_rec IN
              (SELECT objid,
                amount,
                transaction_status -- CR41473 - LRP2 - sethiraj
              FROM x_reward_benefit_transaction
              WHERE esn          = in_event.esn
              AND svc_plan_pin   = l_ild_pin
              AND web_account_id = TO_CHAR(cstwb.web_user_objid)
              AND ACTION_TYPE not in ( 'SETTLEMENT', 'CHARGE') --Modified for CR43820     -- CR41473 LRP2 Point redemption is process with CHARGE from new flow.
              )
              LOOP
                IF (NVL(each_rec.objid,0) <> 0 AND each_rec.amount IS NOT NULL) THEN
                  --
                  DELETE FROM x_reward_benefit_transaction WHERE objid = each_rec.objid AND ACTION_TYPE not in ( 'SETTLEMENT', 'CHARGE');  -- CR41473 LRP2 Point redemption is process with CHARGE from new flow.
                  --
                  IF SQL%ROWCOUNT > 0 THEN --Modified for CR43820
                    -- CR41473 - LRP2
                    /*
                    p_update_benefit(in_cust_key            =>  'OBJID',
                                     in_cust_value          =>  cstwb.web_user_objid,
                                     in_program_name        =>  '',
                                     in_benefit_type        =>  '',
                                     in_brand               =>  '',
                                     in_new_min             =>  '',
                                     in_new_esn             =>  '',
                                     in_new_status          =>  '',
                                     in_new_notes           =>  '',
                                     in_new_expiry_date     =>  NULL,
                                     in_change_quantity     =>  each_rec.amount,             -- CR41473-LRP2
                                     in_transaction_status  =>  each_rec.transaction_status, -- CR41473-LRP2
                                     in_value               =>  NULL,                 -- CR41473-LRP2
                                     in_account_status      =>  NULL); --ARCURRENT --Modified for defect 2269
                    */
                    -- CR48643 changes starts..
                    UPDATE  x_reward_benefit
                    SET     quantity         = (CASE WHEN nvl(each_rec.transaction_status,'COMPLETE') = 'COMPLETE' THEN
                                                      nvl(quantity,0) - nvl(each_rec.amount,0)
                                                 ELSE quantity
                                                END),                                                                 -- CR41473 - LRP2 - sethriaj
                            pending_quantity = (CASE WHEN nvl(each_rec.transaction_status,'COMPLETE') = 'PENDING' THEN
                                                      nvl(pending_quantity,0) - nvl(each_rec.amount,0)
                                                 ELSE pending_quantity                                            -- CR41473 - LRP2 - sethriaj
                                                END),
                            total_quantity   = nvl(pending_quantity,0) + nvl(quantity,0) - nvl(each_rec.amount,0)
                    WHERE   web_account_id   = TO_CHAR(cstwb.web_user_objid);
                    -- CR48643 changes ends.
                  END IF; --Modified for CR43820
                  --
                END IF;
              END LOOP;
            END IF;
            --
            EXIT;
            --
          END IF;
          /*ILD 10 logic ends */
          --
          BEGIN
            SELECT x_red_code
            INTO l_reason
            FROM table_x_red_card rc
            WHERE red_card2call_trans = payload_rec.nameval(i).val;
          EXCEPTION
          WHEN OTHERS THEN
            l_reason := payload_rec.nameval(i).val;
          END;
          --
        END IF; -- IF l_reason IS NOT NULL ...

      END IF; -- IF payload_rec.nameval(i).fld = 'X_PIN' AND NVL(payload_rec.nameval(i).val,0) <> 0 THEN ...
      --
    END LOOP;
    --
  -- CR41473 Start 08/03/2016 PMistry LRP2
    open cur_pin_detail(l_ct_objid);
    fetch cur_pin_detail into rec_pin_detail;

    if cur_pin_detail%found  then
      close cur_pin_detail;
      out_err_code := -1;
      out_err_msg  := 'Transaction with Corporate pin.';
      return;
    end if;
    close cur_pin_detail;
  -- CR41473 End

    -- Start CR49699 Tim 5/25/2017
    o_corp_status := 'N';

    BEGIN
     SELECT 'Y'
      INTO o_corp_status
      FROM sa.table_x_red_card rc,
           sa.table_x_call_trans ct,
           sa.table_inv_bin inv,
           sa.table_site ts
     WHERE 1 = 1
       AND ct.objid = RC.RED_CARD2CALL_TRANS
       AND X_RED_CARD2INV_BIN = inv.objid
       AND inv.bin_name = ts.site_id
       AND (ts.name like 'CORP FREE%' or ts.name = 'TRACFONE WIRELESS - AUTOMATED STORES (ZOOM SYSTEMS)')
       AND rc.x_red_code        = l_reason
       AND ct.x_service_id = in_event.esn;

    EXCEPTION WHEN OTHERS THEN
    o_corp_status := 'N';

    END;

    IF o_corp_status = 'Y' THEN
      --
      -- No rewards for Corp cards.
      --
      out_err_code := -1;
      out_err_msg  := 'Transaction with Corporate pin. 2';
      return;
    END IF;
    -- End CR49699 Tim 5/25/2017
    --
    --CR55200 Add Logic to get service_plan by call_trans red_code
    --For 30Day lookback service_plan may not be the current base plan returned by customer_type
    l_service_plan_id := NULL;
    IF l_ct_objid IS NOT NULL AND l_ildten_exists = 'N'
    THEN
      BEGIN
        SELECT sa.get_service_plan_id ( f_esn      => in_event.esn ,
                                        f_red_code => l_reason     )
          INTO l_service_plan_id
        FROM   dual;
      EXCEPTION
      WHEN OTHERS THEN
        NULL;
      END;
      --If NULL try and retrieve the plan_id from the call_trans ext
      IF l_service_plan_id IS NULL
      THEN
        BEGIN
          SELECT service_plan_id
            INTO l_service_plan_id
          FROM   table_x_call_trans_ext
          WHERE  call_trans_ext2call_trans = l_ct_objid;
        EXCEPTION
        WHEN OTHERS THEN
          NULL;
        END;
      END IF;
    ELSIF l_ct_objid IS NOT NULL
    THEN
      BEGIN
        SELECT service_plan_id
          INTO l_service_plan_id
        FROM   x_account_group_benefit
        WHERE  call_trans_id = l_ct_objid;
      EXCEPTION
      WHEN OTHERS THEN
        NULL;
      END;--CR49890 END
    END IF;

    IF l_service_plan_id IS NOT NULL
    THEN
      cstsp.service_plan_objid := l_service_plan_id;
    END IF;

    --   call below proc to setup benefit transaction defaults
    --
    btrans := f_create_btrans_from_event(in_event);
    --
    btrans.web_account_id := cstwb.web_user_objid;
    btrans.svc_plan_id    := cstsp.service_plan_objid;
    btrans.svc_plan_pin   := l_reason;
    --

    --C88132 Move logic for SETTLEMENT/CHARGE from REDEMPTION
    BEGIN--{
      -- CR41341
      -- check for settlement record for PIN l_ct_objid
      SELECT COUNT(1)
        INTO l_rbt_count
      FROM  x_reward_benefit_transaction rbt
      WHERE 1 = 1
        AND rbt.trans_type IN ( 'SETTLEMENT', 'CHARGE') -- CR41473 PMistry 09/14/2016 Added Charge as with LRP2 the settlement replaced with Charge.
        AND EXISTS
            (SELECT 'x'
             FROM   table_x_call_trans ct
             WHERE  EXISTS (SELECT 'x'
                            FROM   table_x_red_card rc
                            WHERE  ct.objid      = rc.red_card2call_trans
                              AND  rc.x_red_code = rbt.svc_plan_pin)
                              AND  ct.objid      = l_ct_objid);
    END;--}
    --C88132 END

    IF in_event.event_name = 'ACTIVATION' THEN
      --
      -- Check whether the Activation is due to Phone upgrade
      BEGIN
        SELECT 'Y'
        INTO l_phone_upgrade_chk
        FROM table_case tc,
          table_x_case_detail cd
        WHERE UPPER(tc.X_CASE_TYPE) IN( 'PHONE UPGRADE','WARRANTY','TECHNOLOGY EXCHANGE')
        AND cd.detail2case           = tc.objid
        AND cd.x_name                = 'NEW_ESN'
        AND cd.X_VALUE               = btrans.esn;
      EXCEPTION
      WHEN OTHERS THEN
        l_phone_upgrade_chk := 'N';
      END;
      -- Check if the new ESN Upgrade is along with PIN
      BEGIN
        SELECT 'Y'
        INTO l_with_pin
        FROM table_x_call_trans ct,
          table_x_red_card rc
        WHERE ct.objid      = rc.red_card2call_trans
        AND ct.objid        = l_ct_objid
        AND ct.x_service_id = btrans.esn;
      EXCEPTION
      WHEN OTHERS THEN
        l_with_pin := 'N';
      END;
      --
      btrans.trans_type            := 'ACTIVATION';
      btrans.benefit_type_code     := 'LOYALTY_POINTS';
      btrans.action                := 'ADD';
      btrans.action_type           := 'ADD';
      btrans.action_reason         := 'Activation';
      btrans.trans_desc            := 'Activation'; --Modified for 2175
      btrans.benefit_trans2benefit := NULL;
      -- If it is phone upgrade with out pin do not award points, return
      IF l_phone_upgrade_chk = 'Y' AND l_with_pin = 'N' THEN
        RETURN;
      END IF;
      --
      IF l_phone_upgrade_chk  = 'Y' AND l_with_pin = 'Y' THEN
        btrans.trans_type    := 'ESN_CHANGE';
        btrans.action_reason := 'Upgrade';
        btrans.trans_desc    := 'Upgrade'; --Modified for 2175
      END IF;
      --
      BEGIN
        SELECT 'Y'
        INTO l_port_in
        FROM table_case tc,
          table_x_case_detail cd
        WHERE UPPER(tc.X_CASE_TYPE) IN ( 'PORT IN')
        AND cd.detail2case           = tc.objid
        AND cd.x_name                = 'CURRENT_ESN'
        AND NVL(cd.x_value,0)       <> btrans.esn
        AND tc.x_esn                 = btrans.esn;
      EXCEPTION
      WHEN OTHERS THEN
        l_port_in := 'N';
      END;
      --
      IF l_port_in            = 'Y' AND l_with_pin = 'Y' THEN
        btrans.trans_type    := 'PORT_IN';
        btrans.action_reason := 'Port In';
        btrans.trans_desc    := 'Port In'; --Modified for 2175
      END IF;
      --
      IF l_port_in = 'Y' AND l_with_pin = 'N' THEN
        RETURN;
      END IF;
      --
      IF NVL(l_ct_x_reason,'X') = 'AWOP' THEN
        BEGIN -- AWOP through REFERENCE_PIN
          SELECT cd.X_VALUE
          INTO l_awop_ref_pin
          FROM table_case tc,
            table_x_case_detail cd
          WHERE tc.objid = cd.detail2case
          AND cd.x_name  = 'REFERENCE_PIN'
          AND tc.x_esn   = btrans.esn;
        EXCEPTION
        WHEN NO_DATA_FOUND THEN
          BEGIN -- AWOP through REFERENCE_ESN
            SELECT cd.X_VALUE
            INTO l_awop_ref_esn
            FROM table_case tc,
              table_x_case_detail cd
            WHERE tc.objid = cd.detail2case
            AND cd.x_name  = 'REFERENCE_ESN'
            AND tc.x_esn   = btrans.esn;
          EXCEPTION
          WHEN OTHERS THEN
            l_awop_ref_esn := NULL;
            l_awop_ref_pin := NULL;
          END;
        WHEN OTHERS THEN
          l_awop_ref_esn := NULL;
          l_awop_ref_pin := NULL;
        END;
      END IF;
      --
      IF l_awop_ref_pin IS NOT NULL THEN
        BEGIN
          SELECT *
          INTO l_reward_ben_trans_rec
          FROM x_reward_benefit_transaction rbt
          WHERE rbt.SVC_PLAN_PIN = l_awop_ref_pin
          AND rbt.AMOUNT         > 0
          AND rbt.objid          =
            (SELECT MAX(OBJID)
            FROM x_reward_benefit_transaction rbt1
            WHERE rbt1.SVC_PLAN_PIN = rbt.SVC_PLAN_PIN
            AND rbt1.AMOUNT         > 0
            );
        EXCEPTION
        WHEN OTHERS THEN
          NULL;
        END;
      END IF;
      --
      IF l_awop_ref_esn IS NOT NULL THEN
        BEGIN
          SELECT *
          INTO l_reward_ben_trans_rec
          FROM x_reward_benefit_transaction rbt
          WHERE rbt.esn = l_awop_ref_esn
          AND rbt.objid =
            (SELECT MAX(OBJID)
            FROM x_reward_benefit_transaction rbt1
            WHERE rbt1.AMOUNT > 0
              --Fix for 2246 begin
            AND rbt1.esn = rbt.esn
              --Fix for 2246 end
            );
        EXCEPTION
        WHEN OTHERS THEN
          NULL;
        END;
      END IF;
      --
      --Fix for 2246 begin
      --  IF l_awop_ref_pin IS NOT NULL OR l_awop_ref_esn  IS NOT NULL
      --THEN
      IF NVL(l_ct_x_reason,'X') = 'AWOP' --  supervisor approval scenario
        THEN
        --Fix for 2246 end
        --
        IF l_awop_ref_pin IS NOT NULL THEN
          BEGIN
            SELECT sa.get_service_plan_id(in_event.esn,l_awop_ref_pin)
            INTO cstsp.service_plan_objid
            FROM DUAL;
          EXCEPTION
          WHEN OTHERS THEN
            NULL;
          END;
          --
          btrans.svc_plan_id  := cstsp.service_plan_objid;
          btrans.svc_plan_pin := l_awop_ref_pin;
        END IF;
        --Fix for 2246 begin
        IF l_awop_ref_pin IS NULL THEN
          rc              := sa.customer_type ( i_esn => btrans.esn );
          cstsp           := rc.retrieve;
          --
          btrans.svc_plan_id  := cstsp.service_plan_objid;
          btrans.svc_plan_pin := l_awop_ref_pin;
        END IF;
        -- Fix for 2246 end
        --
        btrans.trans_type    := 'AWOP';
        btrans.action        := 'ADD';
        btrans.action_type   := 'REPL';
        btrans.action_reason := 'AWOP';
        btrans.trans_desc    := 'AWOP'; --Modified for 2175
      END IF;
      --
    ELSIF in_event.event_name       = 'DEACTIVATION' THEN
      btrans.trans_type            := 'DEACTIVATION';
      btrans.benefit_type_code     := 'LOYALTY_POINTS';
      btrans.action                := 'NOTE';
      btrans.action_type           := 'NOTE';
      btrans.action_reason         := 'No Points for Deactivation';
      btrans.trans_desc            := 'No Points for Deactivation'; --Modified for 2175
      btrans.benefit_trans2benefit := NULL;
      --
    ELSIF in_event.event_name       = 'REACTIVATION' THEN
      --C88132
      --Do not provide Rewards pts when a reactivation is done with pin purchased w/pts
      IF l_rbt_count <> 0
      THEN
        RETURN;
      END IF;
      --
      btrans.trans_type            := 'REACTIVATION';
      btrans.benefit_type_code     := 'LOYALTY_POINTS';
      btrans.action                := 'ADD';
      btrans.action_type           := 'ADD';
      btrans.action_reason         := 'Reactivation';
      btrans.benefit_trans2benefit := NULL;
      btrans.trans_desc            := 'Reactivation'; --Modified for 2175
      --
    ELSIF in_event.event_name       = 'REDEMPTION' THEN
      --
      -- Settlement record exists for the PIN l_ct_objid abort further processing
      IF l_rbt_count <> 0
      THEN
        RETURN;
      END IF;
      --
      btrans.trans_type            := 'REDEMPTION';
      btrans.benefit_type_code     := 'LOYALTY_POINTS';
      btrans.action                := 'ADD';
      btrans.action_type           := 'ADD';
      btrans.action_reason         := 'Refill with PIN';
      btrans.trans_desc            := 'Refill with PIN';  --Modified for 2175
      btrans.benefit_trans2benefit := NULL;
      --
      -- check whether AT Card is purchased
      BEGIN
        SELECT 'Y'
        INTO l_purchase_at
        FROM sa.table_x_purch_hdr ph,
          sa.TABLE_X_PURCH_DTL pd
        WHERE pd.X_PURCH_DTL2X_PURCH_HDR = ph.objid
        AND ph.X_ESN                     = btrans.esn
        AND pd.X_RED_CARD_NUMBER         = btrans.svc_plan_pin;
      EXCEPTION
      WHEN NO_DATA_FOUND THEN
        BEGIN
          SELECT 'Y'
          INTO l_purchase_at
          FROM sa.x_biz_purch_hdr ph,
            sa.x_biz_purch_DTL pd
          WHERE pd.BIZ_PURCH_DTL2BIZ_PURCH_HDR = ph.objid
          AND ph.X_ESN                         = btrans.esn
          AND pd.SMP                           =
            (SELECT rc.X_SMP
            FROM TABLE_X_RED_CARD rc
            WHERE rc.X_RED_CODE = btrans.svc_plan_pin
            AND rc.x_result     = 'Completed'
            );
        EXCEPTION
        WHEN OTHERS THEN
          l_purchase_at := 'N';
        END;
      WHEN OTHERS THEN
        l_purchase_at := 'N';
      END;
      --
      IF l_purchase_at        = 'Y' THEN
        btrans.action_reason := 'Purchase of AT Card';
        btrans.trans_desc    := 'Purchase of AT Card';
      END IF;
      --
      BEGIN
        SELECT X_SOURCESYSTEM
        INTO l_source_system
        FROM table_x_call_trans
        WHERE objid = l_ct_objid;
      EXCEPTION
      WHEN OTHERS THEN
        l_source_system := NULL;
      END;
      --
      -- Set the auto refil flag to get the autorefil points
      IF NVL(l_source_system,'XX') = 'BATCH' AND l_reserved_card <> 'Y' -- CR41232
      THEN
        --
        --C88132 determine if this is really a RECURRING payment
        BEGIN--{
          SELECT x_payment_type
            INTO l_payment_type
          FROM  (SELECT hdr.objid,hdr.x_payment_type
                 FROM   x_program_gencode gen, x_program_purch_hdr hdr
                 WHERE  gencode2prog_purch_hdr = hdr.objid
                   AND  gen.x_esn              = btrans.esn
                   AND gen.x_insert_date BETWEEN TRUNC(SYSDATE)- 2 AND SYSDATE
                 ORDER BY hdr.objid DESC)
          WHERE ROWNUM = 1;
        --
        EXCEPTION
        WHEN OTHERS
        THEN
          l_payment_type := NULL;
        END;--}
        -- If the payment type is not RECURRING this is an ENROLLMENT record and this
        -- call trans is only delivering the benefits, no pts should be delivered (ignore)
        IF NVL(l_payment_type,'RECURRING') <> 'RECURRING'
        THEN
          RETURN;
        END IF;
        -- C88132 end
        --
        btrans.action_reason      := 'Auto-refill recurrent payment';
        btrans.trans_desc         := 'Auto-refill recurrent payment';
        l_autorefill_flag         := 'Y';
      END IF;
      --
      -- Fix for 2246 begin
      IF NVL(l_ct_x_reason,'X') = 'REPLACEMENT' THEN
        BEGIN -- Replacement through REFERENCE_PIN
          SELECT cd.X_VALUE
          INTO l_replace_ref_pin
          FROM table_case tc,
            table_x_case_detail cd
          WHERE tc.objid = cd.detail2case
          AND cd.x_name  = 'REFERENCE_PIN'
          AND tc.x_esn   = btrans.esn;
        EXCEPTION
        WHEN NO_DATA_FOUND THEN
          BEGIN -- Replacement through REFERENCE_ESN
            SELECT cd.X_VALUE
            INTO l_replace_ref_esn
            FROM table_case tc,
              table_x_case_detail cd
            WHERE tc.objid       = cd.detail2case
            AND cd.x_name        = 'REFERENCE_ESN'
            AND tc.x_esn         = btrans.esn;
            IF l_replace_ref_esn = btrans.esn THEN -- FOR SUPERVISOR SCENARIO WHERE REF ESN HAS SAME ESN
              l_replace_ref_esn := NULL;
            END IF;
          EXCEPTION
          WHEN OTHERS THEN
            l_replace_ref_pin := NULL;
            l_replace_ref_esn := NULL;
          END;
        WHEN OTHERS THEN
          l_replace_ref_pin := NULL;
          l_replace_ref_esn := NULL;
        END;
      END IF;
      IF l_replace_ref_pin IS NOT NULL THEN
        BEGIN
          SELECT *
          INTO l_reward_ben_trans_rec
          FROM x_reward_benefit_transaction rbt
          WHERE rbt.SVC_PLAN_PIN = l_replace_ref_pin
          AND rbt.AMOUNT         > 0
          AND rbt.objid          =
            (SELECT MAX(OBJID)
            FROM x_reward_benefit_transaction rbt1
            WHERE rbt1.SVC_PLAN_PIN = rbt.SVC_PLAN_PIN
            AND rbt1.AMOUNT         > 0
            );
        EXCEPTION
        WHEN OTHERS THEN
          NULL;
        END;
      END IF;
      --
      IF l_replace_ref_esn IS NOT NULL THEN
        BEGIN
          SELECT *
          INTO l_reward_ben_trans_rec
          FROM x_reward_benefit_transaction rbt
          WHERE rbt.esn = l_replace_ref_esn
          AND rbt.objid =
            (SELECT MAX(OBJID)
            FROM x_reward_benefit_transaction rbt1
            WHERE rbt1.AMOUNT > 0
            AND rbt1.esn      = rbt.esn
            );
        EXCEPTION
        WHEN OTHERS THEN
          NULL;
        END;
      END IF;
      IF NVL(l_ct_x_reason,'X') = 'REPLACEMENT' --  supervisor approval scenario
        THEN
        IF l_replace_ref_pin IS NOT NULL OR l_replace_ref_esn IS NOT NULL THEN
          BEGIN
            SELECT sa.get_service_plan_id(in_event.esn, l_replace_ref_pin)
            INTO cstsp.service_plan_objid
            FROM DUAL;
          EXCEPTION
          WHEN OTHERS THEN
            NULL;
          END;
          --
          btrans.svc_plan_id  := cstsp.service_plan_objid;
          btrans.svc_plan_pin := l_replace_ref_pin;
        END IF;
        --
        IF l_replace_ref_pin  IS NULL THEN
          rc                  := sa.customer_type ( i_esn => btrans.esn );
          cstsp               := rc.retrieve;

          btrans.svc_plan_id  := cstsp.service_plan_objid;
          -- Fix for Defect 476 begin
          --btrans.svc_plan_pin := l_replace_ref_pin;
           btrans.svc_plan_pin := l_reward_ben_trans_rec.svc_plan_pin;
           -- Fix for Defect 476 end
        END IF;
        btrans.trans_type    := 'REPLACEMENT';
        btrans.action        := 'ADD';
        btrans.action_type   := 'REPL';
        btrans.action_reason := 'REPLACEMENT';
        btrans.trans_desc    := 'REPLACEMENT'; --Modified for 2175
      END IF;
      -- Fix for 2246 end
    ELSIF in_event.event_name       = 'ENROLLED' THEN
      btrans.trans_type            := 'ENROLLMENT';
      btrans.benefit_type_code     := 'LOYALTY_POINTS';
      btrans.action                := 'ADD';
      btrans.action_type           := 'FREE';
      btrans.action_reason         := 'POINTS FOR ENROLLMENT';
      btrans.trans_desc            := 'POINTS FOR ENROLLMENT'; --Modified for 2175
      btrans.benefit_trans2benefit := NULL;
    END IF;
    --
    --get the points available for service_plan
    svc_plan_points := f_get_svc_plan_benefits( cstsp.service_plan_objid,
                                                lv_program_name,
                                                btrans.benefit_type_code,
                                                in_event.brand,
            l_autorefill_flag);  --Modified for CR41661
    --
    --If svc_plan_points are greater then 0
    IF (NVL(svc_plan_points,0) > 0) THEN
      pts1                    := 0;
      --Check if points was already awarded
      IF f_benefits_prev_awarded( cstwb.web_user_objid,
                                  in_event.esn,
                                  lv_program_name,
                                  btrans.trans_type,
                                  btrans.benefit_type_code,
                                  in_event.brand,
                                  cstsp.service_plan_objid,
                                  --Fix for 2246 begin
                                  -- l_reason
                                  CASE
                                  WHEN l_awop_ref_pin IS NOT NULL THEN
                                    l_awop_ref_pin
                                  WHEN l_replace_ref_pin IS NOT NULL THEN
                                    l_replace_ref_pin
                                    -- Fix for defect 476 begin
                                  WHEN  l_reward_ben_trans_rec.svc_plan_pin IS NOT NULL THEN
                                    l_reward_ben_trans_rec.svc_plan_pin
                                    -- Fix for defect 476 end
                                  ELSE
                                    l_reason
                                  END
                                  --Fix for 2246 End
        ) THEN --Defect 2409
        --
        btrans.trans_desc  := 'Points already given for this PIN';
        btrans.amount      := 0; -- default values
        btrans.action      := 'NOTE';
        btrans.action_type := 'NOTE';
        --
        /*IF in_event.event_name       = 'REDEMPTION'
        THEN
        BEGIN
        SELECT  'Y'
        INTO    l_is_pin
        FROM    table_x_red_card rc
        WHERE   rc.X_RED_CODE = l_reason;
        EXCEPTION
        WHEN OTHERS THEN
        l_is_pin := 'N';
        END;
        --
        IF l_is_pin = 'Y'
        THEN
        p_create_benefit_trans (btrans,
        ln_reward_benefit_trans_objid);
        END IF;
        ELSE
        p_create_benefit_trans (btrans,
        ln_reward_benefit_trans_objid);
        END IF; */
      ELSE
          -- CR41473 - LRP2 - Condition included to check if the Rererence ESN belongs to same account dont add/deduct any points for AWOP/REPLACEMENT.
          --
          IF (l_awop_ref_esn IS NOT NULL OR l_replace_ref_esn IS NOT NULL) AND
             (cstwb.web_user_objid = NVL(l_reward_ben_trans_rec.WEB_ACCOUNT_ID, 0)) THEN
             --
            NULL; -- Dont add/deduct any points when Rererence ESN belongs to same account for AWOP/REPLACEMENT
            --
          ELSE
            --
            -- add points if PIN did not already receive benefits
            pts1 := svc_plan_points;
            --
            IF in_event.event_name = 'DEACTIVATION'
            THEN
              btrans.amount       := 0;
            -- C88132 Do not deliver pts if its a Reactivation due to MinChanges, Reactivation without pin should deliver
            ELSIF in_event.event_name = 'REACTIVATION' AND l_ct_x_reason = 'MINCHANGE' --l_is_pin = 'N'
            THEN --CR42105
              btrans.amount                := 0;
              btrans.action                := 'NOTE';
              btrans.action_type           := 'NOTE';
              btrans.action_reason         := 'No Points for Reactivation due to MinChange';
              btrans.benefit_trans2benefit := NULL;
              btrans.trans_desc            := 'No Points for Reactivation due to MinChange';
            ELSE
              btrans.amount := pts1;
            END IF;
            --
            p_create_benefit_trans( ben_trans => btrans,
                                    reward_benefit_trans_objid => ln_reward_benefit_trans_objid,
                                    o_transaction_status => l_transaction_status);               -- CR41473 PMistry 08/03/2016 LRP2 added new output parameter to procedure to get the status of transaction the procedure have inserted.

            --
            IF (pts1                         > 0) THEN
              IF btrans.action               = 'ADD' THEN
                pts1                        := pts1;      --'+'||pts1; -- CR41473-LRP2
              ELSIF btrans.action            = 'DEDUCT' THEN
                pts1                        := pts1 * -1; --'-'||pts1; -- CR41473-LRP2
              ELSIF btrans.action            = 'NOTE' THEN
                lv_reward_benefit_calculate := 'N';
              END IF;
              --IF btrans.action               = 'ADD' THEN
              --
              IF lv_reward_benefit_calculate = 'Y' THEN
                bobjid                      := f_get_cust_benefit_id ( 'ACCOUNT', cstwb.web_user_objid, 'LOYALTY_PROGRAM', 'LOYALTY_POINTS');
                --
                IF (bobjid <> 0 ) THEN
                  --
                  IF deduct_benefit_points(i_benefit_objid      => bobjid,
                                           i_transaction_status => l_transaction_status,
                                           i_points_to_deduct   => pts1
                                           )  = 'N' THEN
                    --
                    l_transaction_status := 'FAILED';
                    l_action_notes       := 'Not enough qty to deduct';
                    --
                  ELSE
                    -- update x_reward_benefit table
                    p_update_benefit( in_cust_key            =>'OBJID',
                                      in_cust_value          => bobjid,
                                      in_program_name        => '',
                                      in_benefit_type        => '',
                                      in_brand               => '',
                                      in_new_min             => '',
                                      in_new_esn             => '',
                                      in_new_status          => '',
                                      in_new_notes           => '',
                                      in_new_expiry_date     => NULL,
                                      in_change_quantity     => pts1,                 -- CR41473-LRP2
                                      in_transaction_status  => l_transaction_status, -- CR41473-LRP2
                                      in_value               => NULL,                -- CR41473-LRP2
                                      in_account_status      => NULL); --Modified for defect 2269;                 --
                  END IF;
                ELSE
                  benefit := f_create_ben_from_event(in_event);
                  --
                  benefit.notes             := 'New benefit created';
                  benefit.benefit_type_code := 'LOYALTY_POINTS';
                  benefit.quantity          := (CASE WHEN nvl(l_transaction_status,'COMPLETE') = 'COMPLETE' THEN pts1
                                                     WHEN nvl(l_transaction_status,'COMPLETE') = 'PENDING' THEN 0
                                                END); -- CR41473-LRP2
                  benefit.pending_quantity  := (CASE WHEN nvl(l_transaction_status,'COMPLETE') = 'COMPLETE' THEN 0
                                                     WHEN nvl(l_transaction_status,'COMPLETE') = 'PENDING' THEN pts1
                                                END); -- CR41473-LRP2
                  benefit.program_name      := 'LOYALTY_PROGRAM';
                  benefit.benefit_owner     := 'ACCOUNT';
                  benefit.web_account_id    := cstwb.web_user_objid;
                  --
                  --insert into x_reward_benefit table
                  p_create_benefit( benefit, bobjid);
                  --
                END IF;
                --IF (bobjid <> 0 ) THEN
                --
                UPDATE x_reward_benefit_transaction rbt
                SET rbt.benefit_trans2benefit = bobjid
                WHERE rbt.objid               = ln_reward_benefit_trans_objid;
                --
              END IF;
              --
              -- Fix for 2246 Begin
              --IF in_event.event_name  = 'ACTIVATION' AND (l_awop_ref_pin IS NOT NULL OR l_awop_ref_esn  IS NOT NULL)
              -- THEN
              IF in_event.event_name = 'ACTIVATION' AND (l_awop_ref_pin IS NOT NULL OR l_awop_ref_esn IS NOT NULL) AND NVL(l_reward_ben_trans_rec.WEB_ACCOUNT_ID, 0) > 0 THEN
                -- Fix for 2246 End
                --
                --CREATE BENEFIT TRANSACTION RECORD
                btrans.objid          := 0;
                btrans.trans_date     := SYSDATE;
                btrans.web_account_id := l_reward_ben_trans_rec.web_account_id;
                btrans.subscriber_id  := l_reward_ben_trans_rec.subscriber_id;
                btrans.MIN            := l_reward_ben_trans_rec.min;
                btrans.esn            := l_reward_ben_trans_rec.esn;
                btrans.old_min        := NULL;
                btrans.old_esn        := NULL;
                btrans.trans_type     := 'AWOP';
                btrans.trans_desc     := 'AWOP'; --Modified for 2175
                -- Fix for 2246 Begin
                -- btrans.amount                      := l_reward_ben_trans_rec.amount * -1;
                btrans.amount :=
                CASE
                WHEN l_awop_ref_pin IS NOT NULL THEN
                  l_reward_ben_trans_rec.amount * -1
                ELSE
                  pts1 * -1
                END;
                -- Fix for 2246 End
                btrans.benefit_type_code           := l_reward_ben_trans_rec.BENEFIT_TYPE_CODE;
                btrans.action                      := 'DEDUCT';
                btrans.action_type                 := 'REPL';
                btrans.action_reason               := 'AWOP';
                btrans.action_notes                := NULL;
                btrans.benefit_trans2benefit_trans := NULL;
                btrans.svc_plan_pin                := l_reward_ben_trans_rec.svc_plan_pin;
                btrans.svc_plan_id                 := NULL;
                btrans.brand                       := l_reward_ben_trans_rec.brand;
                btrans.benefit_trans2benefit       := NULL;
                btrans.agent_login_name            := NULL;
                --
                --CREATE BENEFIT REWARD RECORD
                --
                benefit.objid             := 0;
                benefit.web_account_id    := l_reward_ben_trans_rec.web_account_id;
                benefit.subscriber_id     := l_reward_ben_trans_rec.subscriber_id;
                benefit.MIN               := NULL;
                benefit.esn               := NULL;
                benefit.benefit_owner     := 'ACCOUNT';
                benefit.created_date      := SYSDATE;
                benefit.status            := 'AVAILABLE';
                benefit.notes             := NULL;
                benefit.benefit_type_code := l_reward_ben_trans_rec.BENEFIT_TYPE_CODE;
                benefit.update_date       := NULL;
                benefit.expiry_date       := NULL;
                benefit.brand             := l_reward_ben_trans_rec.brand;
                benefit.quantity          := NULL;
                benefit.VALUE             := NULL;
                benefit.program_name      := 'LOYALTY_PROGRAM';
                benefit.account_status    := 'ENROLLED'; --Modified for defect 2269
                --
                p_create_benefit_trans( ben_trans => btrans,
                                        reward_benefit_trans_objid => l_reward_benefit_trans_objid,
                                        o_transaction_status => l_transaction_status);               -- CR41473 PMistry 08/03/2016 LRP2 added new output parameter to procedure to get the status of transaction the procedure have inserted.

                --
                bobjid := f_get_cust_benefit_id ( 'ACCOUNT', l_reward_ben_trans_rec.WEB_ACCOUNT_ID, 'LOYALTY_PROGRAM', 'LOYALTY_POINTS');
                --
                -- Fix for 2246 Begin
                IF (bobjid <> 0 ) THEN
                  --
                  IF deduct_benefit_points(i_benefit_objid      => bobjid,
                                           i_transaction_status => l_transaction_status,
                                           i_points_to_deduct   => btrans.amount
                                           )  = 'N' THEN

                    --
                    l_transaction_status := 'FAILED';
                    l_action_notes       := 'Not enough qty to deduct';
                  ELSE
                    -- update x_reward_benefit table
                    p_update_benefit(in_cust_key            => 'OBJID',
                                     in_cust_value          => bobjid,
                                     in_program_name        => '',
                                     in_benefit_type        => '',
                                     in_brand               => '',
                                     in_new_min             => '',
                                     in_new_esn             => '',
                                     in_new_status          => '',
                                     in_new_notes           => '',
                                     in_new_expiry_date     => NULL,
                                     in_change_quantity     => btrans.amount,        -- CR41473-LRP2
                                     in_transaction_status  => l_transaction_status, -- CR41473-LRP2
                                     in_value               =>  NULL,                -- CR41473-LRP2
                                     in_account_status      => NULL);
                  END IF;
                ELSE
                  benefit                   := sa.rewards_mgt_util_pkg.f_create_ben_from_event(in_event);
                  benefit.notes             := 'New benefit created';
                  benefit.benefit_type_code := 'LOYALTY_POINTS';
                  benefit.quantity          := (CASE WHEN nvl(l_transaction_status,'COMPLETE') = 'COMPLETE' THEN btrans.amount
                                                     WHEN nvl(l_transaction_status,'COMPLETE') = 'PENDING' THEN 0
                                                END); -- CR41473-LRP2
                  benefit.pending_quantity  := (CASE WHEN nvl(l_transaction_status,'COMPLETE') = 'COMPLETE' THEN 0
                                                     WHEN nvl(l_transaction_status,'COMPLETE') = 'PENDING' THEN btrans.amount
                                                END); -- CR41473-LRP2
                  benefit.program_name      := 'LOYALTY_PROGRAM';
                  benefit.benefit_owner     := 'ACCOUNT';
                  benefit.web_account_id    := cstwb.web_user_objid;
                  --insert into x_reward_benefit table
                  sa.rewards_mgt_util_pkg.p_create_benefit( benefit, bobjid);
                END IF;
                -- Fix for 2246 End
                UPDATE x_reward_benefit_transaction rbt
                SET rbt.benefit_trans2benefit = bobjid
                WHERE rbt.objid               = l_reward_benefit_trans_objid;
                --
              END IF;
              --IF lv_reward_benefit_calculate = 'Y' THEN
              -- Add points for Redemption if the esn is enrolled for Auto Refill
              IF in_event.event_name = 'REDEMPTION' THEN
                -- check whether esn is enrolled for Auto refill
                BEGIN
                  SELECT 'Y'
                  INTO l_auto_refill_enroll
                  FROM x_reward_program_enrollment txpe
                  WHERE txpe.brand           = in_event.brand
                  AND txpe.program_name      = 'LOYALTY_PROGRAM'
                  AND txpe.benefit_type_code = 'LOYALTY_POINTS'
                  AND txpe.enrollment_type   = 'AUTO_REFILL'
                  AND txpe.esn               = in_event.esn
                  AND txpe.enrollment_flag   = 'Y'
                  AND txpe.web_account_id    = TO_CHAR(cstwb.web_user_objid)
                  AND txpe.enroll_date      IS NOT NULL
                  AND txpe.deenroll_date    IS NULL;
                EXCEPTION
                WHEN OTHERS THEN
                  l_auto_refill_enroll := 'N';
                END;
                --
                BEGIN
                  SELECT X_SOURCESYSTEM
                  INTO l_source_system
                  FROM table_x_call_trans
                  WHERE objid = l_ct_objid;
                EXCEPTION
                WHEN OTHERS THEN
                  l_source_system := NULL;
                END;
                --
                IF NVL(l_source_system,'XX') = 'BATCH' THEN
                  l_auto_refill_enroll      := 'Y';
                ELSE
                  l_auto_refill_enroll := 'N';
                END IF;
                --
                /*IF l_auto_refill_enroll = 'Y' THEN
                  --CREATE BENEFIT TRANSACTION RECORD
                  btrans.objid                       := 0;
                  btrans.trans_date                  := SYSDATE;
                  btrans.web_account_id              := cstwb.web_user_objid;
                  btrans.subscriber_id               := NULL;
                  btrans.MIN                         := l_min;
                  btrans.esn                         := in_event.esn;
                  btrans.old_min                     := NULL;
                  btrans.old_esn                     := NULL;
                  btrans.trans_type                  := 'AUTO_REFILL_PAYMENT';
                  btrans.trans_desc                  := 'Bonus: Auto-Refill Batch'; --Modified for 2175
                  btrans.amount                      := NULL;
                  btrans.benefit_type_code           := 'LOYALTY_POINTS';
                  btrans.action                      := 'ADD';
                  btrans.action_type                 := 'FREE';
                  btrans.action_reason               := 'Bonus: Auto-Refill Batch';
                  btrans.benefit_trans2benefit_trans := NULL;
                  btrans.svc_plan_pin                := NULL;
                  btrans.svc_plan_id                 := NULL;
                  btrans.brand                       := in_event.brand;
                  btrans.benefit_trans2benefit       := NULL;
                  btrans.agent_login_name            := NULL;
                  --
                  --CREATE BENEFIT REWARD RECORD
                  benefit.objid             := 0;
                  benefit.web_account_id    := cstwb.web_user_objid;
                  benefit.subscriber_id     := NULL;
                  benefit.MIN               := NULL;
                  benefit.esn               := in_event.esn;
                  benefit.benefit_owner     := 'ACCOUNT';
                  benefit.created_date      := SYSDATE;
                  benefit.status            := 'AVAILABLE';
                  benefit.notes             := NULL;
                  benefit.benefit_type_code := 'LOYALTY_POINTS';
                  benefit.update_date       := NULL;
                  benefit.expiry_date       := NULL;
                  benefit.brand             := in_event.brand;
                  benefit.quantity          := NULL;
                  benefit.VALUE             := NULL;
                  benefit.program_name      := 'LOYALTY_PROGRAM';
                  benefit.account_status    := 'ENROLLED'; --Modified for defect 2269
                  --
                  p_compensate_reward_points( btrans => btrans, benefit => benefit, out_error_num => out_err_code, out_error_message => out_err_msg );
                END IF;*/
              END IF;
              -- fix for 2246 begin
              IF in_event.event_name = 'REDEMPTION' AND (l_replace_ref_pin IS NOT NULL OR l_replace_ref_esn IS NOT NULL) AND NVL(l_reward_ben_trans_rec.WEB_ACCOUNT_ID, 0) > 0 THEN
                --CREATE BENEFIT TRANSACTION RECORD
                btrans.objid          := 0;
                btrans.trans_date     := SYSDATE;
                btrans.web_account_id := l_reward_ben_trans_rec.web_account_id;
                btrans.subscriber_id  := l_reward_ben_trans_rec.subscriber_id;
                btrans.MIN            := l_reward_ben_trans_rec.min;
                btrans.esn            := l_reward_ben_trans_rec.esn;
                btrans.old_min        := NULL;
                btrans.old_esn        := NULL;
                btrans.trans_type     := 'REPLACEMENT';
                btrans.trans_desc     := 'REPLACEMENT';
                btrans.amount         :=
                CASE
                WHEN l_replace_ref_pin IS NOT NULL THEN
                  l_reward_ben_trans_rec.amount * -1
                ELSE
                  pts1 * -1
                END;
                btrans.benefit_type_code           := l_reward_ben_trans_rec.BENEFIT_TYPE_CODE;
                btrans.action                      := 'DEDUCT';
                btrans.action_type                 := 'REPL';
                btrans.action_reason               := 'REPLACEMENT';
                btrans.action_notes                := NULL;
                btrans.benefit_trans2benefit_trans := NULL;
                btrans.svc_plan_pin                := l_reward_ben_trans_rec.svc_plan_pin;
                btrans.svc_plan_id                 := NULL;
                btrans.brand                       := l_reward_ben_trans_rec.brand;
                btrans.benefit_trans2benefit       := NULL;
                btrans.agent_login_name            := NULL;
                --
                --CREATE BENEFIT REWARD RECORD
                --
                benefit.objid             := 0;
                benefit.web_account_id    := l_reward_ben_trans_rec.web_account_id;
                benefit.subscriber_id     := l_reward_ben_trans_rec.subscriber_id;
                benefit.MIN               := NULL;
                benefit.esn               := NULL;
                benefit.benefit_owner     := 'ACCOUNT';
                benefit.created_date      := SYSDATE;
                benefit.status            := 'AVAILABLE';
                benefit.notes             := NULL;
                benefit.benefit_type_code := l_reward_ben_trans_rec.BENEFIT_TYPE_CODE;
                benefit.update_date       := NULL;
                benefit.expiry_date       := NULL;
                benefit.brand             := l_reward_ben_trans_rec.brand;
                benefit.quantity          := NULL;
                benefit.VALUE             := NULL;
                benefit.program_name      := 'LOYALTY_PROGRAM';
                --
                p_create_benefit_trans( ben_trans => btrans,
                                        reward_benefit_trans_objid => l_reward_benefit_trans_objid,
                                        o_transaction_status => l_transaction_status);               -- CR41473 PMistry 08/03/2016 LRP2 added new output parameter to procedure to get the status of transaction the procedure have inserted.

                --
                bobjid     := sa.rewards_mgt_util_pkg.f_get_cust_benefit_id ( 'ACCOUNT', l_reward_ben_trans_rec.WEB_ACCOUNT_ID, 'LOYALTY_PROGRAM', 'LOYALTY_POINTS');
                --
                IF (bobjid <> 0 ) THEN
                  --
                  IF deduct_benefit_points(i_benefit_objid      => bobjid,
                                           i_transaction_status => l_transaction_status,
                                           i_points_to_deduct   => btrans.amount
                                           )  = 'N' THEN
                    --
                    l_transaction_status := 'FAILED';
                    l_action_notes       := 'Not enough qty to deduct';
                    --
                  ELSE
                    -- update x_reward_benefit table
                    p_update_benefit(in_cust_key            =>  'OBJID',
                                     in_cust_value          =>  bobjid,
                                     in_program_name        =>  '',
                                     in_benefit_type        =>  '',
                                     in_brand               =>  '',
                                     in_new_min             =>  '',
                                     in_new_esn             =>  '',
                                     in_new_status          =>  '',
                                     in_new_notes           =>  '',
                                     in_new_expiry_date     =>  NULL,
                                     in_change_quantity     =>  btrans.amount,        -- CR41473-LRP2
                                     in_transaction_status  =>  l_transaction_status, -- CR41473-LRP2
                                     in_value               =>  NULL,                 -- CR41473-LRP2
                                     in_account_status      =>  NULL);
                    END IF;
                  ELSE
                    benefit                   := sa.rewards_mgt_util_pkg.f_create_ben_from_event(in_event);
                    benefit.notes             := 'New benefit created';
                    benefit.benefit_type_code := 'LOYALTY_POINTS';
                    benefit.quantity          := (CASE WHEN nvl(l_transaction_status,'COMPLETE') = 'COMPLETE' THEN btrans.amount
                                                       WHEN nvl(l_transaction_status,'COMPLETE') = 'PENDING' THEN 0
                                                  END); -- CR41473-LRP2
                    benefit.pending_quantity  := (CASE WHEN nvl(l_transaction_status,'COMPLETE') = 'COMPLETE' THEN 0
                                                       WHEN nvl(l_transaction_status,'COMPLETE') = 'PENDING' THEN btrans.amount
                                                  END); -- CR41473-LRP2
                    benefit.program_name      := 'LOYALTY_PROGRAM';
                    benefit.benefit_owner     := 'ACCOUNT';
                    benefit.web_account_id    := cstwb.web_user_objid;
                    --insert into x_reward_benefit table
                    sa.rewards_mgt_util_pkg.p_create_benefit( benefit, bobjid);
                  --END IF;
                  --
                  UPDATE x_reward_benefit_transaction rbt
                  SET rbt.benefit_trans2benefit = bobjid
                  WHERE rbt.objid               = l_reward_benefit_trans_objid;
                  --
                END IF;
              END IF;
              -- fix for 2246 end
            END IF;
            --IF (pts1 > 0) THEN
          END IF;
          -- IF (l_awop_ref_esn IS NOT NULL OR l_replace_ref_esn IS NOT NULL) AND (cstwb.web_user_objid = cstwb.web_user_objid) THEN
        END IF;
      --Check if points was already awarded
    END IF;
    --If svc_plan_points are greater then 0
  ELSIF out_err_code <> 0 THEN --IF ENROLLED IN PROGRAM
    out_err_code     := -200;
    out_err_msg      := 'error while calling P_CUSTOMER_IS_ENROLLED';
  ELSE --IF ENROLLED IN PROGRAM
    --do nothing
    RETURN;
  END IF;
  COMMIT;
  --IF ENROLLED IN PROGRAM
  --

EXCEPTION
-- CR42235 Changes Starts
WHEN DUP_VAL_ON_INDEX THEN
  out_err_code := -99;
  out_err_msg  := 'p_event_processing ='||SUBSTR(sqlerrm, 1, 2000)|| ' - ' ||dbms_utility.format_error_backtrace;
-- CR42235 Changes Ends
WHEN OTHERS THEN
  out_err_code := -99;
  out_err_msg  := 'Error_code: '||out_err_code||' Error_msg: '||sqlerrm || ' - ' ||dbms_utility.format_error_backtrace ;
  ota_util_pkg.err_log (p_action => 'CALLING REWARDS_MGT_UTIL_PKG.p_event_processing', p_error_date => SYSDATE, p_key => in_event.esn, p_program_name => 'REWARDS_MGT_UTIL_PKG.p_event_processing', p_error_text => out_err_msg);
END p_event_processing;
--
-- CR41473 -- LRP2 -- sethiraj
PROCEDURE p_set_rewards_request ( io_objid                      IN OUT NUMBER,
                                  in_notification_id            IN VARCHAR2,
                                  in_notification_type          IN VARCHAR2,
                                  in_notification_date          IN DATE,
                                  in_source_name                IN VARCHAR2,
                                  in_web_user_objid             IN NUMBER,
                                  in_Benefit_Earning_Objid      IN NUMBER,
                                  in_event_name                 IN VARCHAR2,
                                  in_event_type                 IN VARCHAR2,
                                  in_event_date                 IN DATE,
                                  in_event_id                   IN VARCHAR2,
                                  in_event_status               IN VARCHAR2,
                                  in_description                IN VARCHAR2,
                                  in_amount                     IN NUMBER,
                                  in_denomination               IN VARCHAR2,
                                  in_request_received_date      IN DATE,
                                  in_ben_earn_transaction_type  IN VARCHAR2,
                                  out_err_code                  OUT NUMBER,
                                  out_err_msg                   OUT VARCHAR2
                               ) IS

  --
  reward_request          typ_reward_request_obj;
  l_error_code            NUMBER(5);
  l_error_msg             VARCHAR2(500);
  --

  -- Queue variables.
  enqueue_options         dbms_aq.enqueue_options_t;
  op_msg                  VARCHAR2(4000);
  pl                      q_payload_t;
  ctr                     NUMBER := 0;
  v_event                 VARCHAR2(20);
  nv                      q_nameval_tab := q_nameval_tab();
  v_delay                 number := 0;

  CURSOR cur_customer_detail (c_web_user_objid NUMBER) IS
    SELECT bo.org_id, wu.objid web_user_objid, web_user2contact contact_objid
      FROM table_web_user wu, table_bus_org bo
     WHERE wu.objid = c_web_user_objid
       AND bo.objid = wu.web_user2bus_org;

  rec_customer_detail     cur_customer_detail%rowtype;

BEGIN
  out_err_code := 0;
  out_err_msg  := 'SUCCESS';

  -- Initialize REWARD REQUEST
  reward_request := TYP_REWARD_REQUEST_OBJ();

  reward_request.objid := io_objid;
  reward_request.notification_id := in_notification_id;
  reward_request.notification_type := in_notification_type;
  reward_request.notification_date := in_notification_date;
  reward_request.source_name := in_source_name;
  reward_request.web_user_objid := in_web_user_objid;
  reward_request.Benefit_Earning_Objid := in_Benefit_Earning_Objid;
  reward_request.event_name := in_event_name;
  reward_request.event_type := in_event_type;
  reward_request.event_date := in_event_date;
  reward_request.event_id := in_event_id;
  reward_request.event_status := in_event_status;
  reward_request.Request_process_status := null;
  reward_request.description := in_description;
  reward_request.Process_Status_Reason := null;
  reward_request.amount := in_amount;
  reward_request.denomination := in_denomination;
  reward_request.Request_received_date := in_Request_received_date;
  reward_request.ben_earn_transaction_type := in_ben_earn_transaction_type;


  --
  -- If obj_id is passed then Update x_reqward_request or Insert into x_reqward_request
  IF io_objid IS NULL THEN
    --
    --
    -- Get the new objid from the sequence
    SELECT seq_reward_request.NEXTVAL INTO io_objid FROM DUAL;
    --
    -- Insert into x_reward_request
    INSERT INTO x_reward_request
      ( objid
        ,notification_id
        ,notification_type
        ,notification_date
        ,source_name
        ,web_user_objid
        ,Benefit_Earning_Objid
        ,event_name
        ,event_type
        ,event_date
        ,event_id
        ,event_status
        ,request_process_status
        ,description
        ,Process_Status_Reason
        ,amount
        ,denomination
        ,request_received_date
      )
    VALUES
  ( io_objid
        ,in_notification_id
        ,in_notification_type
        ,in_notification_date
        ,in_source_name
        ,in_web_user_objid
        ,in_Benefit_Earning_Objid
        ,in_event_name
        ,in_event_type
        ,in_event_date
        ,in_event_id
        ,in_event_status
        ,CASE WHEN l_error_code <> 0 THEN 'FAILED' ELSE 'PENDING' END     --in_request_process_status
        ,in_description
        ,CASE WHEN l_error_code <> 0 THEN l_error_msg ELSE NULL END       --in_Process_Status_Reason
        ,in_amount
        ,in_denomination
        ,in_request_received_date
      );

  ELSIF io_objid IS NOT NULL THEN
    -- Update x_reqward_request
    UPDATE x_reward_request
    SET notification_id      = NVL(in_notification_id,notification_id),
      notification_type      = NVL(in_notification_type,notification_type),
      notification_date      = NVL(in_notification_date,notification_date),
      source_name            = NVL(in_source_name,source_name),
      web_user_objid         = NVL(in_web_user_objid,web_user_objid),
      Benefit_Earning_Objid  = NVL(in_Benefit_Earning_Objid,Benefit_Earning_Objid),
      event_name             = NVL(in_event_name,event_name),
      event_type             = NVL(in_event_type,event_type),
      event_date             = NVL(in_event_date,event_date),
      event_id               = NVL(in_event_id,event_id),
      event_status           = NVL(in_event_status,event_status),
      request_process_status = CASE WHEN l_error_code <> 0 THEN 'FAILED' ELSE request_process_status END,
      description            = NVL(in_description,description),
      Process_Status_Reason  = CASE WHEN l_error_code <> 0 THEN l_error_msg ELSE Process_Status_Reason END,
      amount                 = NVL(in_amount,amount),
      denomination           = NVL(in_denomination,denomination),
      request_received_date  = NVL(in_request_received_date,request_received_date)
    WHERE objid              = io_objid;
    --
  END IF;
  --
    --
    -- Validate the inputs
    p_validate_reward_request(io_reward_request   => reward_request,
                              out_err_code        => out_err_code,
                              out_err_msg         => out_err_msg);

    -- Get Customer detail for the web user id received in reward request.
    OPEN cur_customer_detail(in_web_user_objid);
    FETCH cur_customer_detail INTO rec_customer_detail;
    close cur_customer_detail;
    --
    if out_err_code = 3001 then
      out_err_code := 0;
      out_err_msg  := 'SUCCESS';

      UPDATE x_reward_request
      SET   request_process_status = 'ACKNOWLEDGED'
      WHERE objid              = io_objid;

      if in_ben_earn_transaction_type in ( 'NOTIFY_EMAIL_OPTIN','NOTIFY_EMAIL_OPTOUT','NOTIFY_SMS_OPTIN','NOTIFY_SMS_OPTOUT' ) then
        update table_x_contact_add_info
        set   x_do_not_loyalty_email = ( case  when in_ben_earn_transaction_type = 'NOTIFY_EMAIL_OPTIN' then
                                                    1
                                               when in_ben_earn_transaction_type = 'NOTIFY_EMAIL_OPTOUT' then
                                                    0
                                               else x_do_not_loyalty_email
                                         end ),
              x_do_not_loyalty_sms  = ( case  when in_ben_earn_transaction_type = 'NOTIFY_SMS_OPTIN' then
                                                    1
                                               when in_ben_earn_transaction_type = 'NOTIFY_SMS_OPTOUT' then
                                                    0
                                               else x_do_not_loyalty_email
                                         end )
        where add_info2contact =  rec_customer_detail.contact_objid;
      end if;
    elsif out_err_code <> 0 then
        UPDATE x_reward_request
           set request_process_status = 'FAILED',
                Process_Status_Reason = out_err_msg
        WHERE objid              = io_objid;
    else
      -- Raise Queue message.
      sa.queue_pkg.add_nameval_elmt('REWARD_REQUEST_OBJID', to_char(io_objid), nv);

      if rec_customer_detail.org_id is not null then
        pl := q_payload_t('ENROLLMENTS',                -- source_type
                          'X_REWARD_REQUEST',           --source_tbl
                          'COMPLETE',                   --source_status
                          NULL,                         -- esn
                          NULL,                         -- min
                          rec_customer_detail.org_id,   -- brand
                          NULL,                         --event_name
                          nv,                           -- varray
                          'INIT' );                     -- step_complete

        BEGIN
          IF not (sa.queue_pkg.enq(i_q_name => 'SA.CLFY_MAIN_Q',
                           io_q_payload =>  pl,
                           o_op_msg     => op_msg,
                           ip_delay     => v_delay )) THEN

               util_pkg.insert_error_tab('Writing queue: CLFY_MAIN_Q',
                                          pl.esn,
                                         'REWARDS_MGT_UTIL_PKG.p_set_rewards_request',
                                         op_msg );
          END IF;

        EXCEPTION

        WHEN OTHERS THEN
               util_pkg.insert_error_tab('Writing queue: CLFY_MAIN_Q',
                                          pl.esn,
                                         'REWARDS_MGT_UTIL_PKG.p_set_rewards_request',
                                         sqlerrm );
        END;
      END IF;
    end if;

EXCEPTION
  WHEN OTHERS THEN
    l_error_code      := -99;
    l_error_msg       :='Error_code: '||l_error_code||' Error_msg: '||sqlerrm ||' - '||dbms_utility.format_error_backtrace;
    --
    ota_util_pkg.err_log (p_action      => 'Calling REWARDS_MGT_UTIL_PKG.p_set_rewards_request',
                       p_error_date     => SYSDATE,
                       p_key            => 'in_notification_id: '|| in_notification_id || ', in_notification_type' || in_notification_type || ', in_notification_date: ' || in_notification_date ||
                                            ', in_source_name: ' || in_source_name || ', in_web_user_objid: ' || in_web_user_objid|| ', in_Benefit_Earning_Objid: ' || in_Benefit_Earning_Objid||
                                            ', in_event_id: ' || in_event_id|| ', in_amount: ' || in_amount || ', in_denomination: ' || in_denomination,
                       p_program_name   => 'REWARDS_MGT_UTIL_PKG.p_set_rewards_request',
                       p_error_text     => l_error_msg);
END p_set_rewards_request;
--
-- CR41473 -- LRP2 -- sethiraj
PROCEDURE p_validate_reward_request ( io_reward_request IN OUT typ_reward_request_obj,
                                      out_err_code      OUT NUMBER,
                                      out_err_msg       OUT VARCHAR2
                                     ) IS
  --
  c_entity_id           VARCHAR2(50);
  c_validation_flag     VARCHAR2(1);
  l_total_request_count NUMBER;
  l_bobjid              NUMBER;
  l_error_code          NUMBER;
  l_error_msg           VARCHAR2(500);

  CURSOR cur_customer_detail (c_web_user_objid NUMBER) IS
    SELECT bo.org_id, wu.objid web_user_objid
      FROM table_web_user wu, table_bus_org bo
     WHERE wu.objid = c_web_user_objid
       AND bo.objid = wu.web_user2bus_org;

  rec_customer_detail  cur_customer_detail%rowtype;

  --
  CURSOR cur_reward_benefit_earning (c_ben_earning_objid          number,
                                     c_ben_earn_transaction_type   varchar2) is
      SELECT *
        FROM x_reward_benefit_earning
       WHERE (objid = c_ben_earning_objid or
                ( transaction_type = c_ben_earn_transaction_type and c_ben_earning_objid is null )
             )
         AND end_date >= sysdate;
  --
  rec_reward_benefit_earning    x_reward_benefit_earning%rowtype;
  --
BEGIN
    out_err_code := 0;
    out_err_msg  := 'Success';

    -- 1.
    -- Validate if the given entity_id (web user obj_id) exists
    open cur_customer_detail(io_reward_request.web_user_objid);
    fetch cur_customer_detail into rec_customer_detail;
    if cur_customer_detail%notfound then
      close cur_customer_detail;
      out_err_code := 3000;
      out_err_msg  := 'Invalid Account ID.';
      RETURN;
    end if;
    close cur_customer_detail;

    -- 2.
    -- Validation for Loyalty Reward enrollemtn
    l_bobjid     := sa.rewards_mgt_util_pkg.f_get_cust_benefit_id ( 'ACCOUNT', io_reward_request.web_user_objid, 'LOYALTY_PROGRAM', 'LOYALTY_POINTS', rec_customer_detail.org_id);
    if l_bobjid = 0 then
      out_err_code := 3005;
      out_err_msg  := 'Invalid Loyalty Customer ID.';
      RETURN;
    end if;

    --
    OPEN cur_reward_benefit_earning(io_reward_request.Benefit_Earning_Objid,
                                    io_reward_request.ben_earn_transaction_type  );
    FETCH cur_reward_benefit_earning INTO rec_reward_benefit_earning;

    -- 3.
    -- Validate if the given Benefit_Earning_Objid exists
    IF cur_reward_benefit_earning%notfound THEN
      out_err_code := 3002;
      out_err_msg  := 'Invalid Event Config id or not active';
      CLOSE cur_reward_benefit_earning;
      RETURN;
    END IF;


    -- 4.
    -- Validate if the amount matches for the given Benefit_Earning_Objid
    IF rec_reward_benefit_earning.benefits_earned <> io_reward_request.amount THEN
      out_err_code := 3003;
      out_err_msg  := 'The amount/benefit earned does not match for the given Event Config id';
      CLOSE cur_reward_benefit_earning;
      RETURN;
    END IF;

    -- 5.
    -- Validate the amount value.
    IF io_reward_request.amount = 0 then
      out_err_code := 3001;
      out_err_msg  := 'Acknowledged';
      CLOSE cur_reward_benefit_earning;
      RETURN;
    END IF;

    -- 6.
    -- Validate Revenue direction for the event config id received from third party.
    IF rec_reward_benefit_earning.transaction_revenue_direction <> 'CREDIT' then
      out_err_code := 3006;
      out_err_msg  := 'Invalid Event Config id.';
      CLOSE cur_reward_benefit_earning;
      RETURN;
    END IF;
    CLOSE cur_reward_benefit_earning;

    -- 7.
    -- Validate the transation if the max usage falls with in max usage frequence days
    BEGIN
      -- validate if the transaction falls with in max_usage
      SELECT COUNT(1)
        INTO l_total_request_count
        FROM x_reward_request
       WHERE web_user_objid = io_reward_request.web_user_objid
         AND benefit_earning_objid = rec_reward_benefit_earning.objid
         AND insert_timestamp >= TRUNC(SYSDATE - rec_reward_benefit_earning.max_usage_freq_days)
         AND request_process_status <> 'FAILED';

      IF l_total_request_count > rec_reward_benefit_earning.max_usage THEN
        out_err_code := 3004;
        out_err_msg  := 'The customer has exceeded the max usage of: ' || rec_reward_benefit_earning.max_usage || ' within the max usage frequece days of ' || rec_reward_benefit_earning.max_usage_freq_days;
        RETURN;
      END IF;
      --

    EXCEPTION
      WHEN OTHERS THEN
        null;
        --c_validation_flag := 'N';
        out_err_code := -1;
        out_err_msg  := sqlerrm;
        --CLOSE cur_reward_benefit_earning;
        ota_util_pkg.err_log (p_action      => 'Calling REWARDS_MGT_UTIL_PKG.p_validate_reward_request',
                           p_error_date     => SYSDATE,
                           p_key            => 'io_reward_request: ',
                           p_program_name   => 'REWARDS_MGT_UTIL_PKG.p_validate_reward_request',
                           p_error_text     => l_error_msg);

        RETURN;
    END;

EXCEPTION
  WHEN OTHERS THEN
    out_err_code      := -99;
    out_err_msg       :='Error_code: '||out_err_code||' Error_msg: '||sqlerrm ||' - '||dbms_utility.format_error_backtrace;
    --
    ota_util_pkg.err_log (p_action      => 'Calling REWARDS_MGT_UTIL_PKG.p_validate_reward_request',
                       p_error_date     => SYSDATE,
                       p_key            => 'io_reward_request: ',
                       p_program_name   => 'REWARDS_MGT_UTIL_PKG.p_validate_reward_request',
                       p_error_text     => l_error_msg);
END p_validate_reward_request;
--
-- CR41473 -- Added for LRP2 -- sethiraj
PROCEDURE p_process_reward_request(   IN_EVENT    IN OUT q_payload_t,
                                      out_err_code      OUT NUMBER,
                                      out_err_msg       OUT VARCHAR2
                                     ) IS
  --
  CURSOR cur_reward_request (c_reward_request_objid NUMBER) is
    select *
    from x_reward_request
    where objid = c_reward_request_objid;

  rec_reward_request cur_reward_request%rowtype;

  CURSOR cur_customer_detail (c_web_user_objid NUMBER) IS
    SELECT bo.org_id, wu.objid web_user_objid
      FROM table_web_user wu, table_bus_org bo
     WHERE wu.objid = c_web_user_objid
       AND bo.objid = wu.web_user2bus_org;

  cursor cur_ben_earning_detail (c_ben_earning_objid number ) is
      select *
      from  X_REWARD_BENEFIT_EARNING
      where objid = c_ben_earning_objid;
  --
  rec_ben_earning_detail        cur_ben_earning_detail%rowtype;
  rec_customer_detail           cur_customer_detail%rowtype;
  --
  btrans                        typ_lrp_benefit_trans ;
  benefit                       typ_lrp_reward_benefit;
  --
  n_reward_benefit_trans_objid  x_reward_benefit_transaction.objid%TYPE;
  n_reward_benefit_objid        x_reward_benefit.objid%TYPE;
  --
  l_bobjid                      NUMBER;
  l_transaction_status          x_reward_benefit_transaction.transaction_status%type;     -- CR41473 PMistry 08/03/2016 LRP2
  l_error_code                  NUMBER(5);
  l_error_msg                   VARCHAR2(500);

  payload_rec                   q_payload_t ;
  reward_request                typ_reward_request_tab;
  --

BEGIN
  -- Get Reward Request Id from payload.
  payload_rec := IN_EVENT;

  FOR i IN payload_rec.nameval.FIRST..payload_rec.nameval.LAST
  LOOP
    IF payload_rec.nameval(i).fld = 'REWARD_REQUEST_OBJID' then
      open cur_reward_request(payload_rec.nameval(i).val);
      fetch cur_reward_request into rec_reward_request;
      close cur_reward_request;
    end if;
  END LOOP;
  --
  IF rec_reward_request.request_process_status = 'PENDING' then
      -- Initialize BENEFIT TRANSACTION
      btrans := typ_lrp_benefit_trans();
      -- Initialize BENEFIT REWARD RECORD
      benefit := typ_lrp_reward_benefit();


      -- Get Customer detail for the web user id received in reward request.
      OPEN cur_customer_detail(rec_reward_request.web_user_objid);
      FETCH cur_customer_detail INTO rec_customer_detail;
      CLOSE cur_customer_detail;

      -- Get Benefit Earning (Catalog) information for the benefit earning objid (event config id) received in reward request.
      OPEN cur_ben_earning_detail ( rec_reward_request.Benefit_Earning_Objid);
      FETCH cur_ben_earning_detail INTO rec_ben_earning_detail;
      CLOSE cur_ben_earning_detail;

      -- Find Benefit objid from rewards.
      l_bobjid     := sa.rewards_mgt_util_pkg.f_get_cust_benefit_id ( 'ACCOUNT', rec_customer_detail.web_user_objid, 'LOYALTY_PROGRAM', 'LOYALTY_POINTS', rec_customer_detail.org_id);
      --
      --
      --
      IF (l_bobjid <> 0 ) THEN

        -- Assign values to create benefit trans
        btrans.trans_date         := SYSDATE;
        btrans.web_account_id     := rec_customer_detail.web_user_objid;
        btrans.subscriber_id      := NULL;
        btrans.min                := NULL;
        btrans.esn                := NULL;
        btrans.old_min            := NULL;
        btrans.old_esn            := NULL;
        btrans.trans_type         := rec_ben_earning_detail.transaction_type;
        btrans.trans_desc         := rec_ben_earning_detail.transaction_description;
        btrans.amount             :=  Case when  rec_ben_earning_detail.transaction_revenue_direction = 'CREDIT' then
                            rec_reward_request.amount
                            when  rec_ben_earning_detail.transaction_revenue_direction = 'DEBIT' then
                            abs(rec_reward_request.amount) * -1
                       end;
        btrans.benefit_type_code  := 'LOYALTY_POINTS';
        btrans.action             := Case when  rec_ben_earning_detail.transaction_revenue_direction = 'CREDIT' then
                            'ADD'
                            when  rec_ben_earning_detail.transaction_revenue_direction = 'DEBIT' then
                            'DEDUCT'
                       end;
        btrans.action_type        := Case when  rec_ben_earning_detail.transaction_revenue_direction = 'CREDIT' then
                            'FREE'
                            when  rec_ben_earning_detail.transaction_revenue_direction = 'DEBIT' then
                            'SETTLEMENT'
                       end;
        btrans.action_reason      := rec_ben_earning_detail.transaction_description;
        btrans.action_notes       := null;
        btrans.benefit_trans2benefit_trans := NULL;
        btrans.svc_plan_pin       := NULL;
        btrans.svc_plan_id        := NULL;
        btrans.brand              := rec_customer_detail.org_id;
        btrans.benefit_trans2benefit := l_bobjid;
        btrans.agent_login_name   := NULL;
        btrans.transaction_status := CASE when rec_ben_earning_detail.point_cooldown_days <> 0 then
                                              'PENDING'
                                            else 'COMPLETE'
                                     END;
        btrans.MATURITY_DATE      := sysdate + rec_ben_earning_detail.point_cooldown_days;
        btrans.SOURCE             := rec_reward_request.source_name;
        btrans.SOURCE_TRANS_ID    := rec_reward_request.notification_id;
        --
        -- Create benefit transaction
        p_create_benefit_trans( ben_trans => btrans,
                    reward_benefit_trans_objid => n_reward_benefit_trans_objid,
                    o_transaction_status => l_transaction_status);               -- CR41473 PMistry 08/03/2016 LRP2 added new output parameter to procedure to get the status of transaction the procedure have inserted.

      --

        -- update x_reward_benefit table
        --SA.rewards_mgt_util_pkg.p_update_benefit( 'OBJID', l_bobjid, '', '', '', '', '', '', '', NULL, 0, rec_reward_request.amount, NULL);
        p_update_benefit( in_cust_key           => 'OBJID',
                          in_cust_value         => l_bobjid,
                          in_program_name       => NULL,
                          in_benefit_type       => NULL,
                          in_brand              => NULL,
                          in_new_min            => NULL,
                          in_new_esn            => NULL,
                          in_new_status         => NULL,
                          in_new_notes          => NULL,
                          in_new_expiry_date    => NULL,
                          in_change_quantity    => rec_reward_request.amount,
                          in_transaction_status => l_transaction_status,
                          in_value              =>  NULL,
                          in_account_status     => NULL
        );

        update x_reward_request
        set    REQUEST_PROCESS_STATUS = 'COMPLETE'
        where objid = rec_reward_request.objid;
      ELSE
        update x_reward_request
        set    REQUEST_PROCESS_STATUS = 'FAILED',
           PROCESS_STATUS_REASON = 'Account is not enrolled in rewards benefit.'
        where objid = rec_reward_request.objid;

      END IF;
  END IF;

  out_err_code := 0;
  out_err_msg  := 'SUCCESS';
  --
EXCEPTION
  WHEN OTHERS THEN
    l_error_code      := -99;
    l_error_msg       :='Error_code: '||l_error_code||' Error_msg: '||sqlerrm ||' - '||dbms_utility.format_error_backtrace;
    --
    ota_util_pkg.err_log (p_action      => 'Calling REWARDS_MGT_UTIL_PKG.p_process_reward_request',
                       p_error_date     => SYSDATE,
                       p_key            => 'test',
                       p_program_name   => 'REWARDS_MGT_UTIL_PKG.p_process_reward_request',
                       p_error_text     => l_error_msg);
END p_process_reward_request;

FUNCTION deduct_benefit_points(i_benefit_objid IN number,
                         i_transaction_status IN varchar2,
                         i_points_to_deduct   IN number
                         ) return varchar2
as
--
--
CURSOR cur_reward_benefit IS
 SELECT *
   FROM x_reward_benefit
  WHERE objid = i_benefit_objid;
--
reward_benefit_rec cur_reward_benefit%ROWTYPE;
--
BEGIN
  --
  OPEN cur_reward_benefit;
  FETCH cur_reward_benefit INTO reward_benefit_rec;
  CLOSE cur_reward_benefit;
  --
  IF i_points_to_deduct < 0 AND
    ( ( nvl(i_transaction_status,'COMPLETE') = 'COMPLETE' AND reward_benefit_rec.quantity < i_points_to_deduct * -1 ) OR
      ( nvl(i_transaction_status,'COMPLETE') = 'PENDING' AND reward_benefit_rec.pending_quantity < i_points_to_deduct * -1 )
    ) THEN
    RETURN 'N';
  ELSE
    RETURN 'Y';
  END IF;
--
EXCEPTION
  WHEN OTHERS THEN
    RETURN 'N';
END deduct_benefit_points;
--
--CR48643 Added new function to get service plan eligibility to be redeemed through LRP and points required
PROCEDURE check_serv_plan_lrp_elig ( i_service_plan_objid IN  NUMBER,
                                     o_lrp_details        OUT sys_refcursor,
                                     o_err_msg            OUT VARCHAR2,
                                     i_channel            IN VARCHAR2 DEFAULT 'APP' )
IS
  c_billing_partnum    VARCHAR2(100);
  n_billing_price      NUMBER;
  c_brand              VARCHAR2(100);
  n_conversion_factor  NUMBER;
  lrp                 lrp_detail_type;
BEGIN
  lrp := lrp_detail_type();
  lrp := lrp.retrieve( i_service_plan_objid  => i_service_plan_objid,
                       i_vas_program_flag    => 'N',
                       i_channel             => i_channel);
   OPEN o_lrp_details FOR
      SELECT lrp.service_plan_objid           service_plan_objid,
             lrp.available_for_lrp_flag       purchase_by_lrp,
             lrp.points_required_to_redeem    reward_point,
             lrp.points_accrued_by_purchase   points_accrued_by_purchase,
             lrp.points_accrued_by_autorefill points_accrued_by_autorefill
      FROM DUAL;
    o_err_msg := lrp.status;
EXCEPTION
  WHEN OTHERS
  THEN
   o_err_msg := 'FAILURE - '||SQLERRM;
    OPEN   o_lrp_details FOR
    SELECT i_service_plan_objid  service_plan_objid,
           NULL                  purchase_by_lrp,
           NULL                  reward_point,
           NULL                  points_accrued_by_purchase,
           NULL                  points_accrued_by_autorefill,
           o_err_msg             status_message
    FROM dual ;
END check_serv_plan_lrp_elig;
END rewards_mgt_util_pkg;
/