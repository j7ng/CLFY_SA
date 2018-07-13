CREATE OR REPLACE PACKAGE BODY sa."BRAND_X_PKG" AS
 --------------------------------------------------------------------------------------------
 --$RCSfile: BRAND_X_PKG.sql,v $
 --$ Revision 1.176  2018/01/25 22:42:54  skambhammettu
 --$ New procedure get_discount_amount
 --$
 --$ Revision 1.175  2018/01/19 21:37:06  skambhammettu
 --$ Change in error code in update_account_group
 --$
 --$ Revision 1.174  2018/01/16 22:39:59  skambhammettu
 --$ Change in update_account_group
 --$
 --$ Revision 1.172  2018/01/11 21:42:56  skambhammettu
 --$ Added new procedures get_group_mins,deactivate_member
 --$
 --$ Revision 1.170  2018/01/09 15:45:21  skambhammettu
 --$ Add new procedures delete_stage,get_member_min_by_group
 --$
 --$ Revision 1.164  2017/12/18 15:36:34  sinturi
 --$ EMV changes added
 --$
 --$ Revision 1.163  2017/10/24 21:01:10  smacha
 --$ CR 50295 changes Merged to prod version.
 --$
 --$ Revision 1.162  2017/10/12 18:47:20  oimana
 --$ CR49786 - Package Body - Merged with production - Includes chnage in CR52537 (MShah)
 --$
 --$ Revision 1.158  2017/10/05 16:22:49  tbaney
 --$ CR50270 Merged with production version.
 --$
 --$ Revision 1.145  2017/08/25 20:43:39  tbaney
 --$ Added next refill date
 --$
 --$ Revision 1.143  2017/08/25 15:41:47  tbaney
 --$ Merged with production version.
 --$
 --$ Revision 1.140  2017/08/23 13:01:05  tbaney
 --$ Added service end date to SA. BRAND_X_PKG. READ_ACCOUNT_GROUP CR50270
 --$
 --$ Revision 1.139  2017/08/22 18:54:52  tbaney
 --$ Added service end date to SA. BRAND_X_PKG. READ_ACCOUNT_GROUP CR50270
 --$
 --$ Revision 1.138  2017/08/21 22:12:42  nsurapaneni
 --$ Added New Proc get_esn_details
 --$
 --$ Revision 1.126  2017/06/21 19:16:06  smeganathan
 --$ Merged Amazon code with latest production version
 --$
 --$ Revision 1.123  2017/05/02 15:59:34  smeganathan
 --$ Added overloaded procedure create_service_order_stage with discount code list
 --$
 --$ Revision 1.122  2017/04/18 19:03:22  mshah
 --$ CR48716 - Pin required for TW IVR reactivation with master esn with past expire date
 --$
 --$ Revision 1.120  2017/04/14 17:51:39  nsurapaneni
 --$ Added ADD_ON_DATA
 --$
 --$ Revision 1.114  2017/01/05 17:28:28  sraman
 --$ CR46581 - Merged with Production code released as part of Safelink Unl
 --$
 --$ Revision 1.113  2016/12/30 17:22:59  sraman
 --$ CR44729 - Added  logic to return error message applicable to Go_smart if PIN is not valid
 --$
 --$ Revision 1.111  2016/12/22 18:59:48  sraman
 --$ CR44729 - Added  logic to behave Add on ILD card like add_on_data card
 --$
 --$ Revision 1.110  2016/12/21 21:13:43  sraman
 --$ CR44729- Fixed a runtime error
 --$
 --$ Revision 1.109  2016/12/21 20:26:54  sraman
 --$ CR44729 - Added below piece of code to block activation of GO_SMART ESN with Add on ILD card
 --$
 --$ Revision 1.106  2016/11/21 16:13:35  smeganathan
 --$ CR44729 Go smart Migration Merged changes with 11/21 prod release
 --$
 --$ Revision 1.105  2016/11/15 21:33:13  smeganathan
 --$ CR44729 Go smart Migration changes for ADD_ON_ILD in GET_RED_CARD_DETAIL
 --$
 --$ Revision 1.103  2016/11/10 23:14:05  mshah
 --$ CR46213 Changes in FUNCTION valid_number_of_lines
 --$
 --$ Revision 1.102  2016/11/10 16:05:28  sraman
 --$ CR46213 Changes in FUNCTION valid_number_of_lines
 --$
 --$ Revision 1.101  2016/11/09 14:58:55  sraman
 --$ CR46213 Changes in FUNCTION valid_number_of_lines
 --$
 --$ Revision 1.100  2016/11/01 16:21:21  mshah
 --$ CR46213 a?? Changes in FUNCTION valid_number_of_lines
 --$
 --$ Revision 1.99  2016/10/31 20:07:28  mshah
 --$ CR46213 - Changes in FUNCTION valid_number_of_lines
 --$
 --$ Revision 1.98  2016/10/21 20:45:45  mshah
 --$ CR41658 - On behalf of Rahul P.
 --$
 --$ Revision 1.96  2016/10/05 21:29:08  rpednekar
 --$ CR41658
 --$
 --$ Revision 1.95  2016/10/05 20:41:59  rpednekar
 --$ CR41658
 --$
 --$ Revision 1.94  2016/10/05 14:20:05  rpednekar
 --$ CR41658 - Fixed capacity issue for validate_red_card_sp procedure.
 --$
 --$ Revision 1.93  2016/10/05 13:59:06  rpednekar
 --$ CR41658 - Fixed capacity issue for validate_red_card_sp procedure.
 --$
 --$ Revision 1.92  2016/10/03 19:16:33  rpednekar
 --$ CR41658
 --$
 --$ Revision 1.91  2016/10/03 16:27:02  rpednekar
 --$ CR41658
 --$
 --$ Revision 1.88  2016/09/09 22:11:22  pamistry
 --$ CR45203 - Fixes for incompatible enrollments for Simple Mobile.Modified the overloaded procedure with same change
 --$
 --$ Revision 1.87  2016/09/01 22:45:32  jpena
 --$ Fixes for incompatible enrollments for Simple Mobile.
 --$
 --$ Revision 1.86  2016/06/27 15:53:19  pamistry
 --$ CR43726 CRM: Enrollment mismatch in Program enrolled and Group enrollment  TW  - SM brands. Modify the check in comment
 --$
 --$ Revision 1.85  2016/06/27 15:46:06  pamistry
 --$ CR43726 CRM: Enrollment mismatch in Program enrolled and Group enrollment  TW  - SM brands.
 --$
 --$ Revision 1.84  2016/06/13 11:01:57  sethiraj
 --$ CR37756 - Fix for ITQ Defect.
 --$
 --$ Revision 1.83  2016/05/20 12:58:28  pamistry
 --$ CR37756 - Modify Select_next_master_esn and get_shared_group_flag procedure based on review comment.
 --$
 --$ Revision 1.82  2016/05/16 18:17:29  pamistry
 --$ CR37756 - Modify Delete_Member proc to skip exists check from Account group member table while updating x_service_order_stage table as the expired member moves history table
 --$
 --$ Revision 1.81  2016/04/28 21:17:25  pamistry
 --$ CR37756 - Modify validate_red_card_sp procedure
 --$
 --$ Revision 1.80  2016/04/21 23:47:08  pamistry
 --$ CR37756 - Deployment fix
 --$
 --$ Revision 1.79  2016/04/21 22:33:59  pamistry
 --$ CR37756 - Deployment fix
 --$
 --$ Revision 1.78  2016/04/19 22:01:05  pamistry
 --$ CR37756 - Modify get_shared_group_flag, GetMasterESN, validate_esn_sp_rules, Validate_red_card_sp procedures for Simple Mobile
 --$
 --$ Revision 1.77  2016/03/24 21:43:14  sraman
 --$ CR41974 - Fix activation issue
 --$
 --$ Revision 1.75  2016/03/16 15:19:13  sraman
 --$ CR39391 - Fixing defects found in testing
 --$
 --$ Revision 1.74  2016/03/15 22:15:22  sraman
 --$ CR39391 - Fixing Testing defects
 --$
 --$ Revision 1.73  2016/03/15 21:36:18  sraman
 --$ CR39391 - Fixing testing Defects
 --$
 --$ Revision 1.72  2016/03/08 23:53:29  sraman
 --$ CR39391- Bug Fix- found during testing
 --$
 --$ Revision 1.71  2016/03/08 19:58:09  sraman
 --$ CR39391 - Testing Bug Fixing
 --$
 --$ Revision 1.70  2016/03/08 17:06:06  sraman
 --$ CR39391 - Testing defect fixing
 --$
 --$ Revision 1.69  2016/03/07 17:21:31  sraman
 --$ CR39391 - Added a new procedure named update_so_stage_status_by_esn to this package to update x_service_order_stage table based on ESN
 --$
 --$ Revision 1.68  2016/03/04 17:59:15  sraman
 --$ CR39391 - Added a new procedure named update_so_stage_status_by_esn to this package to update x_service_order_stage table based on ESN
 --$
 --$ Revision 1.67  2016/03/01 21:04:03  sraman
 --$ CR39391-Testing Bug fix
 --$
 --$ Revision 1.66  2016/02/17 21:51:28  sraman
 --$ CR39391-Unit Testing Bug fix
 --$
 --$ Revision 1.64  2016/02/09 20:37:11  sraman
 --$ CR39391 - Fix few bugs found in testing
 --$
 --$ Revision 1.62  2016/02/08 21:23:13  sraman
 --$ CR39391 - Incorporated review comments
 --$
 --$ Revision 1.61  2016/02/01 17:54:54  sraman
 --$ CR39391 - Added a new procedure named update_so_stage_status_by_esn to this package to update x_service_order_stage table based on ESN
 --$
 --$ Revision 1.59  2016/01/27 19:05:12  sraman
 --$ CR39391 - Merged with production code
 --$
 --$ Revision 1.50  2016/01/15 15:07:19  smeganathan
 --$ CR39389 changes in validate_red_card_sp
 --$
 --$ Revision 1.45  2016/01/07 22:24:46  smeganathan
 --$ CR39389 Total wireless plus changes
 --$
 --$ Revision 1.35  2015/09/29 18:54:44  jarza
 --$ CR35695 - Allow to change the Plan after ESN validation
 --$
 --$ Revision 1.34  2015/09/16 15:00:32  vyegnamurthy
 --$ CR36105
 --$
 --$ Revision 1.33  2015/09/10 18:35:59  jarza
 --$ CR36105 - Transfered promotion from old master ESN to new master ESN record.
 --$ Checking in on behalf of Rahul P
 --$
 --$ Revision 1.31  2015/09/08 22:34:31  jpena
 --$ eme fix cr37870
 --$
 --$ Revision 1.25  2015/07/28 13:11:17  ddevaraj
 --$ For cr35694
 --$
 --$ Revision 1.24  2015/07/27 20:14:47  ddevaraj
 --$ For CR35694
 --$
 --$ Revision 1.23  2015/07/14 20:46:01  rpednekar
 --$ Added union in cursor of procedure get_red_card_esn_sp.
 --$
 --$ Revision 1.22  2015/07/09 18:51:11  jpena
 --$ CR36347. Performance improvements on read_account_group and fix ESN parameter datatype.
 --$
 --$ Revision 1.19  2015/06/22 20:07:44  jpena
 --$ Changes on DELETE_MEMBER to bypass delete restrictions for TAS (CR34029)
 --$
 --$ Revision 1.18  2015/04/24 19:27:58  jpena
 --$ Changes to fix reactivations from TAS
 --$
 --$ Revision 1.17  2015/03/24 18:24:14  jpena
 --$ Changes for Brand x close case resolution code
 --$
 --$ Revision 1.16  2015/03/24 15:59:45  oarbab
 --$ CR33453 added commit and rollback
 --$
 --$ Revision 1.15  2015/03/23 21:42:32  oarbab
 --$ CR33453
 --$
 --$ Revision 1.60  2015/02/09 22:33:53  jpena
 --$ CR32463 - Brand X Changes
 --$
 --------------------------------------------------------------------------------------------
--
--
-- CR55465 - TW update account group name to default when moving ESN to dummy account
PROCEDURE update_acct_group_name (i_account_group_id IN  NUMBER,
                                  i_esn              IN  VARCHAR2,
                                  i_new_group_name   IN  VARCHAR2 DEFAULT NULL,
                                  o_error_code       OUT NUMBER,
                                  o_error_msg        OUT VARCHAR2)
AS

  l_count NUMBER := 0;
  PRAGMA  AUTONOMOUS_TRANSACTION;

BEGIN

  SELECT COUNT(1)
    INTO l_count
    FROM sa.x_account_group xgp,
         sa.x_account_group_member xgm
   WHERE xgp.status||'' <> 'EXPIRED'
     AND xgm.status||'' <> 'EXPIRED'
     AND xgm.esn = i_esn
     AND xgm.account_group_id = xgp.objid
     AND xgp.objid = i_account_group_id;

  IF l_count <> 0 THEN

    UPDATE sa.x_account_group
       SET account_group_name = NVL(TRIM(i_new_group_name), account_group_name)
     WHERE objid  = i_account_group_id;

    COMMIT;

  END IF;

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    o_error_code := -1;
    o_error_msg  := 'ERROR - Failed in calling update_acct_group_name: '||SQLERRM;
    dbms_output.put_line(o_error_msg);
END update_acct_group_name;
--
--
FUNCTION is_single_member (ip_account_group_uid IN VARCHAR2) RETURN BOOLEAN
IS
BEGIN
  /*
  SELECT COUNT(1)
  FROM   x_account_group_member
  WHERE  account_group_id = (SELECT account_group_id
  FROM   x_account_group
  WHERE  account_group_uid = ip_account_group_uid
  );
  */
  RETURN(TRUE);
END is_single_member;
--
--
-- Added on 10/28/2014 by Juda Pena to set the account group master esn
PROCEDURE change_master (ip_account_group_id IN  NUMBER,
                         ip_esn              IN  VARCHAR2,
                         op_err_code         OUT NUMBER,
                         op_err_msg          OUT VARCHAR2,
                         ip_switch_pin_flag  IN  VARCHAR2 DEFAULT 'Y')
AS
  -- Search for an esn in a group
  CURSOR c_validate_esn
  IS
    SELECT 1
    FROM x_account_group_member
    WHERE account_group_id = ip_account_group_id
    AND esn                = ip_esn;
  -- Get the program enrolled id
  CURSOR c_get_program_enrolled (p_esn VARCHAR2)
  IS
    SELECT pe.objid program_enrolled_id
    FROM x_program_enrolled pe,
      x_service_plan_site_part spsp,
      table_site_part tsp,
      x_program_parameters pp,
      mtm_sp_x_program_param mtm,
      x_service_plan sp
    WHERE 1                         = 1
    AND pe.x_esn                    = p_esn
    AND pe.pgm_enroll2site_part     = spsp.table_site_part_id
    AND spsp.table_site_part_id     = tsp.objid
    AND pe.pgm_enroll2pgm_parameter = pp.objid
    AND pp.objid                    = mtm.x_sp2program_param
    AND mtm.program_para2x_sp       = spsp.x_service_plan_id
    AND sp.objid                    = mtm.program_para2x_sp;
  -- Get the master esn of the group
  CURSOR c_get_master_esn
  IS
    SELECT esn
    FROM x_account_group_member
    WHERE account_group_id = ip_account_group_id
    AND master_flag        = 'Y';
  validate_esn_rec c_validate_esn%ROWTYPE;
  program_enrolled_rec c_get_program_enrolled%ROWTYPE;
  old_master_esn_rec c_get_master_esn%ROWTYPE;
  grp_rec x_account_group%ROWTYPE;
BEGIN
  DBMS_OUTPUT.PUT_LINE('Entered change master');
  -- Validate if esn is blank
  IF ip_esn IS NULL THEN
    -- Set error code
    op_err_code := 2;
    op_err_msg  := 'ESN cannot be blank';
    --
    -- Exit the program whenever an error occured
    RETURN;
  END IF;
  DBMS_OUTPUT.PUT_LINE('Search for the new esn in the acccount group');
  -- Search for the new esn in the acccount group
  OPEN c_validate_esn;
  FETCH c_validate_esn INTO validate_esn_rec;
  IF c_validate_esn%NOTFOUND THEN
    -- Close the cursor and continue
    CLOSE c_validate_esn;
    -- Set error code
    op_err_code := 3;
    op_err_msg  := 'ESN does not belong to the account group';
    --
    -- Exit the program whenever an error occured
    RETURN;
  ELSE
    -- Close the cursor and continue
    CLOSE c_validate_esn;
  END IF;
  DBMS_OUTPUT.PUT_LINE('Get the old master esn');
  -- Get the old master esn
  OPEN c_get_master_esn;
  FETCH c_get_master_esn
  INTO old_master_esn_rec;
  CLOSE c_get_master_esn;
  -- Replace the previous master esn + account_group_member_id from service order stage and use the new one (only for PAYMENT_PENDING)
  /*UPDATE x_service_order_stage
  SET    esn               = ip_esn,
  account_group_member_id = ( SELECT account_group_member_id
  FROM   x_account_group_member
  WHERE  account_group_id = ip_account_group_id
  AND    esn = ip_esn
  ),
  update_timestamp  = SYSDATE
  WHERE  account_group_member_id = ( SELECT account_group_member_id
  FROM   x_account_group_member
  WHERE  account_group_id = ip_account_group_id
  AND    esn = old_master_esn_rec.esn
  )
  AND    status = 'PAYMENT_PENDING'; */
  --
  DBMS_OUTPUT.PUT_LINE('ip_switch_pin_flag => ' || ip_switch_pin_flag);
  IF NVL(ip_switch_pin_flag,'Y') = 'Y' THEN
    -- Flip flop the pin, service plan when a master of the account is changed
    MERGE INTO x_service_order_stage NEW USING
    (SELECT sos.objid,
      sos.account_group_member_id,
      sos.esn,
      sos.service_plan_id,
      child_data.child_type,
      child_data.child_service_plan_id,
      sos.smp,
      sos.case_id,
      sos.type,
      master_data.master_smp,
      master_data.master_program_param_id,
      master_data.master_pmt_source_id,
      master_data.master_case_id,
      master_data.master_type,
      NVL(
      (SELECT 'Y'
      FROM x_account_group_member agm
      WHERE agm.account_group_id = ip_account_group_id
      AND agm.esn                = sos.esn
      AND esn                    = ip_esn
      AND ROWNUM                 = 1
      ), 'N') new_master_flag -- new master esn
    FROM x_service_order_stage sos,
      (SELECT objid,
        case_id master_case_id,
        type master_type,
        program_param_id master_program_param_id,
        pmt_source_id master_pmt_source_id,
        smp master_smp
      FROM x_service_order_stage
      WHERE account_group_member_id IN
        (SELECT objid
        FROM x_account_group_member
        WHERE account_group_id = ip_account_group_id
        AND master_flag        = 'Y'
        )
      AND esn IN
        (SELECT esn -- previous master ESN
        FROM x_account_group_member
        WHERE account_group_id = ip_account_group_id
        AND master_flag        = 'Y'
        )
      ) master_data,
      (SELECT type child_type,
        service_plan_id child_service_plan_id
      FROM x_service_order_stage
      WHERE account_group_member_id IN
        (SELECT objid
        FROM x_account_group_member
        WHERE account_group_id = ip_account_group_id
        AND master_flag        = 'N'
        )
      AND esn <>
        (SELECT esn -- Previous master esn
        FROM x_account_group_member
        WHERE account_group_id = ip_account_group_id
        AND master_flag        = 'Y'
        AND ROWNUM             = 1
        )
      AND ROWNUM = 1
      ) child_data
    WHERE sos.account_group_member_id IN
      (SELECT objid
      FROM x_account_group_member
      WHERE account_group_id = ip_account_group_id
      )
--CR39391 - Aded SIM_PENDING and CASE_PENDING to below IN clause and also added below OR condition
    AND ( UPPER(sos.status) IN ('PAYMENT_PENDING','SIM_PENDING','CASE_PENDING')
--       OR
--          ( UPPER(sos.status)='COMPLETED'
--            AND EXISTS (SELECT 1 FROM x_account_group_member agm
--                      WHERE agm.objid = sos.account_group_member_id
--                        AND upper(agm.status) <>'ACTIVE'
--                        AND account_group_id = ip_account_group_id
--                      )
 --         )
        )
    ) data ON (data.objid = new.objid)
  WHEN MATCHED THEN
    UPDATE
    SET new.smp = (
      CASE
        WHEN data.new_master_flag = 'Y'
        THEN data.master_smp
        ELSE NULL
      END),
      new.program_param_id = (
      CASE
        WHEN data.new_master_flag = 'Y'
        THEN data.master_program_param_id
        ELSE NULL
      END),
      new.pmt_source_id = (
      CASE
        WHEN data.new_master_flag = 'Y'
        THEN data.master_pmt_source_id
        ELSE NULL
      END),
      new.service_plan_id = (
      CASE
        WHEN data.new_master_flag = 'N'
        THEN data.child_service_plan_id
        ELSE NULL
      END);
  END IF;
  DBMS_OUTPUT.PUT_LINE('Removing previous master');
  -- Set the previous master ESN as a child
  UPDATE x_account_group_member
  SET master_flag        = 'N',
    update_timestamp     = SYSDATE
  WHERE account_group_id = ip_account_group_id
  AND master_flag        = 'Y';
  DBMS_OUTPUT.PUT_LINE('Setting new master');
  -- Set the new master ESN
  UPDATE x_account_group_member
  SET master_flag        = 'Y',
    update_timestamp     = SYSDATE
  WHERE account_group_id = ip_account_group_id
  AND esn                = ip_esn
  AND UPPER(status)     <> 'EXPIRED';
  -- Validate if master esn was set correctly
  IF SQL%ROWCOUNT <> 1 THEN
    -- Set error code
    op_err_code := 4;
    op_err_msg  := 'Master ESN was not changed properly';
    --
    -- Exit the program whenever an error occurs
    RETURN;
  END IF;
  DBMS_OUTPUT.PUT_LINE('Get program_enrolled_id');
  -- Get the account group (header) data
  grp_rec := get_group_rec (ip_esn);
  -- If the group is enrolled in auto refill
  IF grp_rec.program_enrolled_id IS NOT NULL THEN
    -- Creating x_program_trans history for enrollment
    create_program_trans ( ip_program_enrolled_id => grp_rec.program_enrolled_id , ip_enrollment_status => 'ENROLLED' , ip_enroll_status_reason => 'Change Account Group Enrollment to ESN => ' ||ip_esn , ip_float_given => NULL , ip_cooling_given => NULL , ip_grace_period_given => NULL , ip_trans_date => SYSDATE , ip_action_text => 'Enrollment Attempt' , ip_action_type => 'ENROLLMENT' , ip_reason => NULL , ip_sourcesystem => NULL , ip_esn => ip_esn , ip_exp_date => NULL , ip_cooling_exp_date => NULL , ip_update_status => NULL , ip_update_user => 'web2' , ip_tran2pgm_entrolled => grp_rec.program_enrolled_id , ip_trans2site_part => NULL );
    -- Updating the new master esn program_enrolled_id
    UPDATE x_program_enrolled
    SET x_esn                                      = ip_esn,
      (pgm_enroll2part_inst, pgm_enroll2site_part) =
      (SELECT objid,
        x_part_inst2site_part
      FROM table_part_inst
      WHERE part_serial_no = ip_esn
      AND x_domain         = 'PHONES'
      AND ROWNUM           = 1
      ),
      pgm_enroll2contact =
      (SELECT pi.x_part_inst2contact
      FROM table_x_contact_part_inst conpi,
        table_part_inst pi
      WHERE 1               = 1
      AND pi.part_serial_no = ip_esn
      AND pi.x_domain       = 'PHONES'
      AND pi.objid          = conpi.x_contact_part_inst2part_inst
      AND ROWNUM            = 1
      )
    WHERE objid = grp_rec.program_enrolled_id;
  END IF;
  DBMS_OUTPUT.PUT_LINE('Updating queued pins');
  -- Update new esn part inst objids for the queued redemption cards
  UPDATE table_part_inst pi_pin
  SET pi_pin.part_to_esn2part_inst =
    (SELECT objid
    FROM table_part_inst
    WHERE part_serial_no = ip_esn -- New Master ESN
    AND x_domain         = 'PHONES'
    AND ROWNUM           = 1
    )
  WHERE pi_pin.part_to_esn2part_inst IN
    (SELECT objid
    FROM table_part_inst
    WHERE part_serial_no IN
      (SELECT esn -- All active children of the account group
      FROM x_account_group_member
      WHERE account_group_id = ip_account_group_id
      AND esn                = old_master_esn_rec.esn -- old master esn
      )
    )
  AND x_domain = 'REDEMPTION CARDS'
  AND pi_pin.x_part_inst_status
    ||'' IN ( '400'); -- Queued Redemption Cards
  -- CR36105 START
  FOR rec_esn_promo IN
  ( SELECT DISTINCT promo_objid,
    program_enrolled_objid
  FROM x_enroll_promo_grp2esn
  WHERE x_esn      = old_master_esn_rec.esn
  AND ((x_end_date > SYSDATE)
  OR (x_end_date  IS NULL))
  )
  LOOP
    IF rec_esn_promo.promo_objid IS NOT NULL THEN
      UPDATE x_enroll_promo_grp2esn
      SET x_end_date             = SYSDATE
      WHERE x_esn                = old_master_esn_rec.esn
      AND ((x_end_date           > SYSDATE)
      OR (x_end_date            IS NULL))
      AND promo_objid            = rec_esn_promo.promo_objid
      AND program_enrolled_objid = rec_esn_promo.program_enrolled_objid ;
      IF ip_esn                 IS NOT NULL THEN
        sa.enroll_promo_pkg.sp_register_esn_promo(ip_esn ,rec_esn_promo.promo_objid ,rec_esn_promo.program_enrolled_objid ,op_err_code ,op_err_msg);
      END IF;
    END IF;
  END LOOP;
  -- CR36105 END
  DBMS_OUTPUT.PUT_LINE('End');
  --
  op_err_code := 0;
  op_err_msg  := 'Success';
EXCEPTION
WHEN OTHERS THEN
 DBMS_OUTPUT.PUT_LINE('change master => ' || SQLERRM);
 -- Log error message
 log_error( ip_error_text => 'SQLERRM: ' || SQLERRM, ip_error_date => SYSDATE, ip_action => 'exception when others clause for account_group_id = ' || ip_account_group_id || ', esn = ' || ip_esn, ip_key => ip_esn, ip_program_name => 'SA.brand_x_pkg.change_master');
 op_err_code := 1;
 op_err_msg := 'Unhandled exception : ' || SQLERRM;
 RAISE;
END change_master;
--
--
-- Added logic by Juda Pena to create a history row for x_program_trans
PROCEDURE create_program_trans (ip_program_enrolled_id      IN NUMBER,
                                ip_enrollment_status        IN VARCHAR2,
                                ip_enroll_status_reason     IN VARCHAR2,
                                ip_float_given              IN NUMBER,
                                ip_cooling_given            IN NUMBER,
                                ip_grace_period_given       IN NUMBER,
                                ip_trans_date               IN DATE,
                                ip_action_text              IN VARCHAR2,
                                ip_action_type              IN VARCHAR2,
                                ip_reason                   IN VARCHAR2,
                                ip_sourcesystem             IN VARCHAR2,
                                ip_esn                      IN VARCHAR2,
                                ip_exp_date                 IN DATE,
                                ip_cooling_exp_date         IN DATE,
                                ip_update_status            IN VARCHAR2,
                                ip_update_user              IN VARCHAR2,
                                ip_tran2pgm_entrolled       IN NUMBER,
                                ip_trans2site_part          IN NUMBER)
IS

BEGIN

  INSERT
  INTO x_program_trans
    (
      objid,
      x_enrollment_status,
      x_enroll_status_reason,
      x_float_given,
      x_cooling_given,
      x_grace_period_given,
      x_trans_date,
      x_action_text,
      x_action_type,
      x_reason,
      x_sourcesystem,
      x_esn,
      x_exp_date,
      x_cooling_exp_date,
      x_update_status,
      x_update_user,
      pgm_tran2pgm_entrolled,
      pgm_trans2web_user,
      pgm_trans2site_part
    )
  SELECT seq_x_program_trans.NEXTVAL,
    ip_enrollment_status ,
    ip_enroll_status_reason ,
    ip_float_given ,
    ip_cooling_given ,
    ip_grace_period_given ,
    ip_trans_date ,
    ip_action_text ,
    ip_action_type ,
    ip_reason ,
    ip_sourcesystem ,
    ip_esn ,
    ip_exp_date ,
    ip_cooling_exp_date ,
    ip_update_status ,
    ip_update_user ,
    ip_program_enrolled_id , -- tran2pgm_enrolled  ,
    pgm_enroll2web_user ,    -- ip_trans2web_user  ,
    NULL ip_trans2site_part
  FROM x_program_enrolled
  WHERE objid = ip_program_enrolled_id;
  --VALUES
  --(  seq_x_program_trans.NEXTVAL,                              --  objid,
  --  'ENROLLED',                                                --  x_enrollment_status,
  --  'Change Account Group Enrollment',                         --  x_enroll_status_reason,
  --  null,                                                      --  x_float_given,
  --  null,                                                      --  x_cooling_given,
  --  null,                                                      --  x_grace_period_given,
  --  to_date('21-JAN-2015 17:04:53','DD-MON-RRRR HH24:MI:SS'),  --  x_trans_date,
  --  'Enrollment Attempt',                                      --  x_action_text,
  --  'ENROLLMENT',                                              --  x_action_type,
  --  'TW Unlimited  $35.00',                                    --  x_reason,
  -- 'TAS',                                                      --  x_sourcesystem,
  -- '100000000013490241',                                       --  x_esn,
  --  null,                                                      --  x_exp_date,
  --  null,                                                      --  x_cooling_exp_date,
  --  null,                                                      --  x_update_status,
  --  'web2',                                                    --  x_update_user,
  --  38288509,                                                  --  pgm_tran2pgm_entrolled,
  --  581007095,                                                 --  pgm_trans2web_user,
  --  1609909179                                                 --  pgm_trans2site_part)
  --);
EXCEPTION
  WHEN OTHERS THEN
    -- Log error message
    log_error( ip_error_text => 'SQLERRM: ' || SQLERRM, ip_error_date => SYSDATE, ip_action => 'exception when others clause for ip_program_enrolled_id = ' || ip_program_enrolled_id, ip_key => ip_program_enrolled_id, ip_program_name => 'brand_x_pkg.create_program_trans');
    RAISE;
END create_program_trans;
--
--
-- Added on 12/18/2014 by Juda Pena to retrieve the smp number
FUNCTION convert_pin_to_smp (ip_red_code IN VARCHAR2) RETURN VARCHAR2
IS
  -- Get the SMP from the part inst table (if it has NOT been burned)
  CURSOR c_get_part_inst_smp
  IS
    SELECT part_serial_no smp
    FROM table_part_inst
    WHERE 1        = 1
    AND x_red_code = ip_red_code
    AND x_domain   = 'REDEMPTION CARDS';
  -- Get the SMP from the red card (if it has been burned)
  CURSOR c_get_red_card_smp
  IS
    SELECT x_smp FROM table_x_red_card WHERE x_red_code = ip_red_code;
  --
  l_smp VARCHAR2(30);
BEGIN

  -- FIRST: Get the SMP from the red card (if it has been burnt)
  OPEN c_get_part_inst_smp;
  FETCH c_get_part_inst_smp INTO l_smp;
  IF c_get_part_inst_smp%NOTFOUND OR l_smp IS NULL THEN
    -- SECOND: When applicable get the SMP from the red card (if it has been burnt)
    OPEN c_get_red_card_smp;
    FETCH c_get_red_card_smp INTO l_smp;
    CLOSE c_get_red_card_smp;
  END IF;
  CLOSE c_get_part_inst_smp;
  -- Return output
  RETURN(l_smp);

EXCEPTION
  WHEN OTHERS THEN
    RETURN(NULL);
END convert_pin_to_smp;
--
--
-- Added on 12/18/2014 by Juda Pena to retrieve the pin number
FUNCTION convert_smp_to_pin (ip_smp IN VARCHAR2) RETURN VARCHAR2
IS
  -- Get the PIN from the part inst table (if it has NOT been burnt)
  CURSOR c_get_part_inst_pin
  IS
    SELECT x_red_code pin
    FROM table_part_inst
    WHERE 1            = 1
    AND part_serial_no = ip_smp
    AND x_domain       = 'REDEMPTION CARDS';
  -- Get the PIN from the red card (if it has been burnt)
  CURSOR c_get_red_card_pin
  IS
    SELECT x_red_code pin FROM table_x_red_card WHERE x_smp = ip_smp;
  --
  l_pin VARCHAR2(30);
BEGIN
  -- FIRST: Get the SMP from the red card (if it has been burnt)
  OPEN c_get_part_inst_pin;
  FETCH c_get_part_inst_pin INTO l_pin;
  IF c_get_part_inst_pin%NOTFOUND OR l_pin IS NULL THEN
    -- SECOND: When applicable get the SMP from the red card (if it has been burnt)
    OPEN c_get_red_card_pin;
    FETCH c_get_red_card_pin INTO l_pin;
    CLOSE c_get_red_card_pin;
  END IF;
  CLOSE c_get_part_inst_pin;
  -- Return output
  RETURN(l_pin);

EXCEPTION
  WHEN OTHERS THEN
    RETURN(NULL);
END convert_smp_to_pin;
--
--
-- Added on 11/06/2014 by Juda Pena to create a new account group
PROCEDURE create_account_group (ip_account_group_name         IN  VARCHAR2,
                                ip_service_plan_id            IN  NUMBER,
                                ip_service_plan_feature_date  IN  DATE,
                                ip_program_enrolled_id        IN  NUMBER,
                                ip_status                     IN  VARCHAR2,
                                ip_bus_org_id                 IN  VARCHAR2,
                                op_account_group_id           OUT NUMBER,
                                op_err_code                   OUT NUMBER,
                                op_err_msg                    OUT VARCHAR2)
IS
  -- Get the bus org objid
  CURSOR c_get_bus_org_objid IS
    SELECT objid FROM table_bus_org WHERE org_id = ip_bus_org_id;
  bus_org_rec c_get_bus_org_objid%ROWTYPE;
BEGIN
  -- Find the bus org objid
  OPEN c_get_bus_org_objid;
  FETCH c_get_bus_org_objid INTO bus_org_rec;
  IF c_get_bus_org_objid%NOTFOUND THEN
    -- Close the cursor and continue
    CLOSE c_get_bus_org_objid;
    -- Set the error message
    op_err_code := 6;
    op_err_msg  := 'BUS ORG record was not found';
    -- Exit the program whenever an error occured
    RETURN;
  ELSE
    -- Close the cursor and continue
    CLOSE c_get_bus_org_objid;
  END IF;
  -- INSERT A RECORD IN THE X_ACCOUNT_GROUP TABLE.
  INSERT
  INTO x_account_group
    (
      objid ,
      account_group_name ,
      service_plan_id ,
      service_plan_feature_date ,
      program_enrolled_id ,
      status ,
      insert_timestamp ,
      update_timestamp ,
      bus_org_objid ,
      account_group_uid
    )
    VALUES
    (
      sa.sequ_account_group.NEXTVAL ,
      ip_account_group_name ,
      ip_service_plan_id ,
      ip_service_plan_feature_date ,
      ip_program_enrolled_id ,
      UPPER(ip_status) ,
      SYSDATE ,
      SYSDATE ,
      bus_org_rec.objid ,
      RandomUUID
    )
  RETURNING objid
  INTO op_account_group_id;
  op_err_code := 0;
  op_err_msg  := 'Success';

EXCEPTION
  WHEN OTHERS THEN
    -- Log error message
    log_error( ip_error_text => 'SQLERRM: ' || SQLERRM, ip_error_date => SYSDATE, ip_action => 'exception when others clause for op_account_group_id = ' || op_account_group_id, ip_key => op_account_group_id, ip_program_name => 'brand_x_pkg.create_account_group');
    op_err_code := 1;
    op_err_msg  := 'Unhandled exception : ' || SQLERRM;
    RAISE;
END create_account_group;
--
--
PROCEDURE close_all_open_stage_cases (ip_esn      IN VARCHAR2,
                                      op_err_code OUT NUMBER,
                                      op_err_msg  OUT VARCHAR2)
IS

  -- Get all opened cases for an esn
  CURSOR c_get_opened_cases (c_esn IN VARCHAR2)
  IS
    SELECT so.esn,
           TO_CHAR(so.case_id) case_id,
           so.sourcesystem
    FROM   sa.x_service_order_stage so
    WHERE  1 = 1
    AND    so.esn = c_esn
    AND    EXISTS (SELECT 1
                     FROM sa.table_case c
                    WHERE c.id_number = TO_CHAR(so.case_id)
                      AND NOT EXISTS (SELECT 1
                                        FROM sa.table_condition
                                       WHERE objid = c.case_state2condition
                                         AND s_title||'' = 'CLOSED'));

    l_case_status VARCHAR2(10);
    l_case_msg    VARCHAR2(2400);

BEGIN
    --
    FOR i IN c_get_opened_cases (ip_esn) LOOP

      l_case_status := NULL;
      l_case_msg    := NULL;
      --
      igate.sp_close_case (p_case_id         => i.case_id,
                           p_user_login_name => 'sa',
                           p_source          => i.sourcesystem,
                           p_resolution_code => 'Resolution Given',
                           p_status          => l_case_status,
                           p_msg             => l_case_msg);
      --
      IF l_case_status <> 'S' THEN
        --
        op_err_code    := 10;
        op_err_msg     := 'Error closing open case_id = ' || i.case_id || '. ' || l_case_msg;
        --
        RETURN;
        --
      END IF;

    END LOOP;

    op_err_code := 0;
    op_err_msg  := 'Success';

EXCEPTION
  WHEN OTHERS THEN
    -- Log error message
    log_error (ip_error_text => 'SQLERRM: ' || SQLERRM,
               ip_error_date => SYSDATE,
               ip_action => 'exception when others clause for esn = ' || ip_esn,
               ip_key => ip_esn,
               ip_program_name => 'brand_x_pkg.close_all_open_stage_cases');
    op_err_code := 99;
    op_err_msg  := 'Unhandled exception : ' || SQLERRM;
    RAISE;
END close_all_open_stage_cases;
--
--
-- Added on 12/06/2014 by Juda Pena to update member information
PROCEDURE delete_member (ip_account_group_id        IN     NUMBER,
                         iop_esn                    IN OUT VARCHAR2,
                         ip_account_group_member_id IN     NUMBER,
                         op_err_code                OUT    NUMBER,
                         op_err_msg                 OUT    VARCHAR2,
                         ip_bypass_last_mbr_flag    IN     VARCHAR2 DEFAULT 'N')
IS

  -- Get the esn based on a member id
  CURSOR c_get_esn IS
    SELECT esn
    FROM   sa.x_account_group_member
    WHERE  objid = ip_account_group_member_id
    AND    UPPER(status||'') <> 'EXPIRED';

  l_new_master_esn              VARCHAR2(30);
  group_rec                     x_account_group%ROWTYPE;
  mbr_rec                       x_account_group_member%ROWTYPE;
  l_number_of_lines             NUMBER;
  l_current_master_esn          VARCHAR2(30);
  l_payment_pending_stage_count NUMBER;
  l_new_member_flag             VARCHAR2(1) := 'N';

  -- instantiate initial values
  rc                            sa.customer_type  := customer_type();
  -- type to hold retrieved attributes
  cst                           sa.customer_type;
  lease_status_rec              sa.x_lease_status%ROWTYPE;

BEGIN

  -- Get the esn when it was not passed
  IF iop_esn IS NULL AND ip_account_group_member_id IS NULL THEN
    --
    op_err_code := 2;
    op_err_msg  := 'Cannot find the member esn';
    -- Exit the program esn and member id were not passed
    RETURN;
    --
  END IF;

  -- Get the esn when it was not passed
  IF iop_esn IS NULL THEN
    BEGIN
      SELECT esn
      INTO   iop_esn
      FROM   sa.x_account_group_member
      WHERE  objid = ip_account_group_member_id
      AND    UPPER(status||'') <> 'EXPIRED';
    EXCEPTION
      WHEN others THEN
        op_err_code := 3;
        op_err_msg  := 'Cannot find the member esn';
        -- Exit the program whenever an error occured
        RETURN;
    END;
  END IF;

  DBMS_OUTPUT.PUT_LINE('esn => ' ||iop_esn);

  -- instantiate esn
  rc := customer_type (i_esn => iop_esn);

  -- call the retrieve method
  cst := rc.retrieve;

  -- Get the account group (header) information
  group_rec := get_group_rec (ip_esn => iop_esn);

  -- Get the account group member (child) information
  mbr_rec := get_member_rec (ip_esn => iop_esn);

  -- Get the current master esn before expiring the member
  l_current_master_esn := get_master_esn (ip_account_group_id => ip_account_group_id);

  -- Count the number of records with payment pending
  SELECT COUNT(1)
  INTO   l_payment_pending_stage_count
  FROM   sa.x_service_order_stage so
  WHERE  EXISTS (SELECT 1
                 FROM   sa.x_account_group_member
                 WHERE  account_group_id = ip_account_group_id
                 AND    esn = iop_esn
                 AND    objid = so.account_group_member_id
                 AND    esn = so.esn)
  AND    UPPER(status) = 'PAYMENT_PENDING';

  -- Validate if the member to be deleted has all the new member conditions
  IF UPPER(group_rec.status) = 'NEW' AND UPPER(mbr_rec.status) = 'PENDING_ENROLLMENT' AND l_payment_pending_stage_count > 0 THEN
    -- Set this flag to true when all the new member conditions are met
    l_new_member_flag := 'Y';
  ELSE
    -- Set to false
    l_new_member_flag := 'N';
  END IF;

  -- Get the group number of lines
  l_number_of_lines := get_feature_value (ip_service_plan_id => group_rec.service_plan_id,
                                          ip_fea_name        => 'NUMBER_OF_LINES');

  -- When there is only one ESN remaining in the group (CR34029)
  IF cst.group_total_lines = 1 AND NVL(ip_bypass_last_mbr_flag,'N') = 'Y' THEN
    -- Set the group to EXPIRED
    UPDATE sa.x_account_group
    SET    status = 'EXPIRED'
    WHERE  objid  = ip_account_group_id;
    --
  ELSIF cst.group_total_lines = 1 AND NOT (NVL(ip_bypass_last_mbr_flag,'N') = 'Y' AND NVL(l_number_of_lines,0) = 1) THEN

    -- Validation for TAS, when it's a 1 line service plan allow the member to be removed
    IF NVL(l_new_member_flag,'N') = 'N' THEN
      --
      op_err_code := 4;
      op_err_msg  := 'Cannot remove the last active ESN of the group';
      -- Exit the program whenever an error occured
      RETURN;
      --
    ELSE
      -- Set the group to EXPIRED
      UPDATE sa.x_account_group
      SET    status = 'EXPIRED'
      WHERE  objid  = ip_account_group_id;
      --
    END IF;

  END IF;

  DBMS_OUTPUT.PUT_LINE('cst.member_status => ' || cst.member_status);

  IF NVL(UPPER(cst.member_status),'NULL') NOT IN('ACTIVE','PENDING_ENROLLMENT') THEN
    op_err_code := 5;
    op_err_msg  := 'Cannot delete a member when it is not active or pending enrollment';
    -- Exit the program whenever an error occured
    RETURN;
  END IF;

  -- Added logic for TW+ (Leasing)
  -- Get the lease status flags
  IF cst.lease_status IS NOT NULL THEN
    BEGIN
      SELECT *
      INTO   lease_status_rec
      FROM   sa.x_lease_status
      WHERE  lease_status = cst.lease_status;
    EXCEPTION
      WHEN others THEN
        NULL;
    END;
  END IF;

  -- Do not allow leased devices to be removed from an account group
  IF lease_status_rec.block_group_transfer_flag = 'Y' THEN
    op_err_code := 20;
    op_err_msg  := 'LEASED DEVICE IS NOT ALLOWED TO BE REMOVED FROM THE GROUP';
    -- Exit the program
    RETURN;
  END IF;

  -- End logic for TW+ (Leasing)

  -- Updating the account group member details.
  UPDATE sa.x_account_group_member
  SET    status             = 'EXPIRED',
         end_date           = SYSDATE,
         update_timestamp   = SYSDATE
  WHERE  esn              = iop_esn
  AND    account_group_id = ip_account_group_id
  AND    UPPER(status) <> 'EXPIRED';

  -- If the member was not updated
  IF SQL%ROWCOUNT = 0 THEN
    --
    op_err_code := 6;
    op_err_msg  := 'Member was not found to be updated to EXPIRED';
    -- Exit the program whenever an error occured
    RETURN;
    --
  END IF;

  DBMS_OUTPUT.PUT_LINE('current master esn => ' || l_current_master_esn);

  -- Check if the member to be deleted is the current master of the group
  -- Change the master only when there is more than 1 active member
  IF (l_current_master_esn = iop_esn) AND (NVL(l_number_of_lines,0) <> 1) AND (cst.group_total_lines > 1) THEN

    DBMS_OUTPUT.PUT_LINE('count active members => ' || cst.group_total_lines);

    -- Get a new master esn using the member order
    l_new_master_esn := select_next_master_esn (ip_account_group_id => ip_account_group_id,
                                                ip_old_master_esn   => iop_esn);

    DBMS_OUTPUT.PUT_LINE('new master esn => ' || l_new_master_esn);

    -- When a new master was not found
    IF l_new_master_esn IS NULL THEN
      --
      op_err_code := 7;
      op_err_msg  := 'Could not find the new master ESN for account group id => ' || ip_account_group_id;
      -- Exit the program whenever an error occured
      RETURN;
      --
    END IF;

    -- Set the next esn as the master of the group
    change_master (ip_account_group_id => ip_account_group_id,
                   ip_esn              => l_new_master_esn,
                   op_err_code         => op_err_code,
                   op_err_msg          => op_err_msg,
                   ip_switch_pin_flag  => 'Y');

    -- When an error occurs
    IF op_err_code <> '0' THEN
      -- Exit the program whenever an error occured in change master
      RETURN;
    END IF;

  END IF;

  --CR55236
  DELETE FROM sa.x_service_order_stage
  WHERE esn = iop_esn
  AND UPPER(status) IN('PAYMENT_PENDING','PROCESSING','QUEUED','TO_QUEUE','COMPLETED');

  -- Close all opened staged cases (when applicable)
  close_all_open_stage_cases (ip_esn      => iop_esn,
                              op_err_code => op_err_code,
                              op_err_msg  => op_err_msg);

  IF op_err_code <> 0 THEN
    RETURN;
  END IF;
  --
  op_err_code := 0;
  op_err_msg  := 'Success';
  --
EXCEPTION
  WHEN OTHERS THEN
    -- Log error message
    log_error (ip_error_text => 'SQLERRM: ' || SQLERRM,
               ip_error_date => SYSDATE,
               ip_action => 'exception when others clause for ip_account_group_id = ' ||
                            ip_account_group_id ||' , iop_esn = ' ||
                            iop_esn || ' , ip_account_group_member_id = ' ||
                            ip_account_group_member_id || ' , ip_bypass_last_mbr_flag = ' ||
                            ip_bypass_last_mbr_flag,
                ip_key => ip_account_group_id,
                ip_program_name => 'brand_x_pkg.delete_member');
    op_err_code := 1;
    op_err_msg  := 'Unhandled exception : ' || SQLERRM;
    RAISE;
END delete_member;
--
--
-- Added by Juda Pena on 01/13/2015 to expire a member from the deactivation process (service_deactivation_code.deactservice)
PROCEDURE expire_account_group (ip_esn       IN  VARCHAR2,
                                op_err_code  OUT NUMBER,
                                op_err_msg   OUT VARCHAR2)
IS
  group_rec x_account_group%ROWTYPE;
  l_err_code NUMBER;
  l_err_msg  VARCHAR2(1000);
  l_esn      VARCHAR2(30) := ip_esn;
  l_expired number;
BEGIN

  -- Only perform the action when the esn is available
  IF l_esn IS NOT NULL THEN
    --Added for TW Web Common Standards,to ignore if already expired.

         SELECT
            COUNT(*) into l_expired
         FROM
            x_account_group_member_hist
         WHERE
            esn = ip_esn;

            IF l_expired>0 then
              op_err_code := 0;
              op_err_msg  := 'Success';
              RETURN;
            END IF;

    -- TW Web Common Standards,to ignore if already expired.--END
    -- Retrieve the account group (header) information
    group_rec := get_group_rec(l_esn);

    -- If the provided esn is a member of any account groups then expire the member
    IF group_rec.objid IS NOT NULL THEN
      brand_x_pkg.delete_member (ip_account_group_id        => group_rec.objid,
                                 iop_esn                    => l_esn,    -- optional
                                 ip_account_group_member_id => NULL,     -- optional
                                 op_err_code                => l_err_code,
                                 op_err_msg                 => l_err_msg,
                                 ip_bypass_last_mbr_flag    => 'Y');     -- to bypass the last member of the group rules
    END IF;

  END IF;
  --
  op_err_code := 0;
  op_err_msg  := 'Success';

EXCEPTION
  WHEN OTHERS THEN
    -- Log error message
    log_error (ip_error_text => 'SQLERRM: ' || SQLERRM, ip_error_date => SYSDATE,
               ip_action => 'exception when others clause for ip_esn = ' || ip_esn, ip_key => ip_esn,
               ip_program_name => 'brand_x_pkg.expire_account_group');
    op_err_code := 1;
    op_err_msg  := 'Unhandled exception : ' || SQLERRM;
    RAISE;
END expire_account_group;
--
--
-- Added on 11/19/2014 by Juda Pena to get a valid esn for a given red card code
FUNCTION get_dummy_esn (ip_red_card_code IN VARCHAR2) RETURN VARCHAR2
IS
  -- Get the part classes related to the given pin
  CURSOR c_get_part_class_id
  IS
    SELECT d.part_class_id
    FROM sa.x_serviceplanfeaturevalue_def a,
      sa.mtm_partclass_x_spf_value_def b,
      sa.x_serviceplanfeaturevalue_def c,
      sa.mtm_partclass_x_spf_value_def d,
      sa.x_serviceplanfeature_value spfv,
      sa.x_service_plan_feature spf,
      sa.x_service_plan sp
    WHERE a.objid        = b.spfeaturevalue_def_id
    AND b.part_class_id IN
      (SELECT pn.part_num2part_class
      FROM table_part_inst rc,
        table_mod_level ml,
        table_part_num pn
      WHERE 1           = 1
      AND rc.x_red_code = ip_red_card_code
      AND ml.objid      = rc.n_part_inst2part_mod
      AND pn.objid      = ml.part_info2part_num
      )
  AND c.objid        = d.spfeaturevalue_def_id
  AND a.value_name   = c.value_name
  AND spfv.value_ref = a.objid
  AND spf.objid      = spfv.spf_value2spf
  AND sp.objid       = spf.sp_feature2service_plan;
  -- Get the available ESNs based on a given part class
  CURSOR c_get_esn (p_part_class IN NUMBER)
  IS
    SELECT pi.part_serial_no,
      pi.x_red_code,
      pi.x_domain,
      pn.part_num2part_class,
      pi.x_part_inst_status
    FROM table_part_num pn,
      table_mod_level ml,
      table_part_inst pi
    WHERE 1                    = 1
    AND pn.part_num2part_class = p_part_class
    AND pn.domain LIKE 'PHO%'
    AND ml.part_info2part_num   = pn.objid
    AND pi.n_part_inst2part_mod = ml.objid
    AND pi.x_part_inst_status   = '50';

BEGIN

  -- Loop through the part classes related to the provided pin
  FOR i IN c_get_part_class_id
  LOOP
    -- Loop through ALL the available ESNs based on a given part class
    FOR j IN c_get_esn (i.part_class_id)
    LOOP
      -- Return the first dummy ESN found to the calling program
      RETURN(j.part_serial_no);
    END LOOP; -- j
  END LOOP;   -- i
  -- Return a blank ESN, when none are available.
  RETURN(NULL);

EXCEPTION
  WHEN OTHERS THEN
    -- Return a blank ESN if any errors occurred
    RETURN(NULL);
END get_dummy_esn;
--
--
-- Added on 12/17/2014 by Juda Pena to get the group id that has a payment pending record based on a pin
FUNCTION get_pmt_pending_acc_grp_id (ip_red_card_code IN VARCHAR2) RETURN NUMBER
IS
  -- Determine if the pin has a PAYMENT_PENDING transaction in the stage table
  CURSOR c_find_pmt_pending
  IS
    SELECT account_group_id
    FROM sa.x_account_group_member
    WHERE objid IN
      (SELECT account_group_member_id
      FROM x_service_order_stage
      WHERE smp         = brand_x_pkg.convert_pin_to_smp(ip_red_card_code)
      AND UPPER(status) = 'PAYMENT_PENDING'
      );
  -- Hold cursor data
  pmt_pending_rec c_find_pmt_pending%ROWTYPE;

BEGIN

  IF ip_red_card_code IS NOT NULL THEN
    -- Find payment pending record in SOS
    OPEN c_find_pmt_pending;
    FETCH c_find_pmt_pending INTO pmt_pending_rec;
    CLOSE c_find_pmt_pending;
  END IF;
  --
  RETURN(NVL(pmt_pending_rec.account_group_id,NULL));

EXCEPTION
  WHEN OTHERS THEN
    RETURN(NULL);
END get_pmt_pending_acc_grp_id;
--
--
-- Added function by Juda Pena to find the account group id for an esn in the stage record (with PAYMENT_PENDING status)
FUNCTION get_esn_pmt_pending_acc_grp_id (ip_esn IN VARCHAR2) RETURN NUMBER
IS
  -- Determine if the esn has a PAYMENT_PENDING transaction in SOS
  CURSOR c_find_pmt_pending
  IS
    SELECT account_group_id
    FROM x_account_group_member
    WHERE objid IN
      (SELECT account_group_member_id
      FROM x_service_order_stage
      WHERE esn         = ip_esn
      AND UPPER(status) = 'PAYMENT_PENDING'
      );
  -- Hold cursor data
  pmt_pending_rec c_find_pmt_pending%ROWTYPE;

BEGIN

  IF ip_esn IS NOT NULL THEN
    -- Find payment pending record in SOS
    OPEN c_find_pmt_pending;
    FETCH c_find_pmt_pending INTO pmt_pending_rec;
    CLOSE c_find_pmt_pending;
  END IF;
  --
  RETURN(NVL(pmt_pending_rec.account_group_id,NULL));

EXCEPTION
  WHEN OTHERS THEN
    RETURN(NULL);
END get_esn_pmt_pending_acc_grp_id;
--
--
-- Added on 12/17/2014 by Juda Pena to get the rowtype for the account group based on a provided esn (member of an account group)
FUNCTION get_group_rec (ip_esn IN VARCHAR2) RETURN x_account_group%ROWTYPE
IS

  -- Get all members (not expired) in a group that provided esn belongs to
  CURSOR c_get_group
  IS
    SELECT *
    FROM sa.x_account_group
    WHERE objid IN (SELECT account_group_id
                      FROM sa.x_account_group_member
                     WHERE esn = ip_esn
                       AND UPPER(status) <> 'EXPIRED')
    AND UPPER(status) <> 'EXPIRED';

  group_rec c_get_group%ROWTYPE;

BEGIN

  -- Only call the cursor when the proper parameters were passed correctly
  IF ip_esn IS NOT NULL THEN
    -- Retrieve account group data
    OPEN c_get_group;
    FETCH c_get_group INTO group_rec;
    CLOSE c_get_group;
  END IF;

  -- Return rowtype results
  RETURN(group_rec);

EXCEPTION
  WHEN OTHERS THEN
    RETURN(NULL);
END get_group_rec;
--
--
-- Added function by Juda Pena on 01/08/2015 to return the account group member record based on an ESN
FUNCTION get_member_rec (ip_esn IN VARCHAR2) RETURN x_account_group_member%ROWTYPE
IS
  -- Get all members part of the group the provided esn belongs to
  CURSOR c_get_group_member
  IS
    SELECT *
    FROM x_account_group_member
    WHERE esn          = ip_esn
    AND UPPER(status) <> 'EXPIRED'
    ORDER BY objid DESC;

  group_member_rec c_get_group_member%rowtype;

BEGIN

  -- Only call the cursor when the proper parameters were passed correctly
  IF ip_esn IS NOT NULL THEN
    -- Retrieve account group data
    OPEN c_get_group_member;
    FETCH c_get_group_member INTO group_member_rec;
    CLOSE c_get_group_member;
  END IF;
  -- Return results
  RETURN(group_member_rec);

EXCEPTION
  WHEN OTHERS THEN
    RETURN(NULL);
END get_member_rec;
--
--
-- Added by Juda Pena on 2/3/2015 to overload (locally in the BRAND_X_PKG) the service_plan.get_sp_retention_action
PROCEDURE get_retention_action (ip_esn               IN  VARCHAR2,
                                ip_flow_name         IN  VARCHAR2,
                                ip_service_plan_id   IN  NUMBER,
                                ip_red_card_pin      IN  VARCHAR2,
                                op_dest_plan_act_tbl OUT retention_action_typ_tbl,
                                op_err_code          OUT NUMBER,
                                op_err_msg           OUT VARCHAR2)
IS
  -- Declare and initialize nested table
  --CR47024 - Object structure changed to add Warning Script id.
  l_dest_plan_act_tbl sa.retention_action_typ_tbl := retention_action_typ_tbl( NULL, NULL, NULL,NULL);

BEGIN

  op_dest_plan_act_tbl := retention_action_typ_tbl();
  -- Pass input parameters
  IF ip_service_plan_id    IS NOT NULL AND ip_red_card_pin IS NOT NULL THEN
    l_dest_plan_act_tbl(1) := retention_action_typ_obj( NULL, ip_red_card_pin, NULL,NULL);  --CR47024 - Object structure changed to add Warning Script id.
  ELSE
    l_dest_plan_act_tbl(1) := retention_action_typ_obj( ip_service_plan_id, ip_red_card_pin, NULL,NULL);  --CR47024 - Object structure changed to add Warning Script id.);
  END IF;
  -- Call original stored procedure
  service_plan.get_sp_retention_action( in_esn => ip_esn, in_flow_name => ip_flow_name, io_dest_plan_act_tbl => l_dest_plan_act_tbl, out_err_num => op_err_code, out_err_string => op_err_msg );
  IF op_err_code <> 0 THEN
    RETURN;
  END IF;
  -- Reassign values to output parameter
  op_dest_plan_act_tbl := l_dest_plan_act_tbl;
  -- Display output messages
  DBMS_OUTPUT.PUT_LINE('op_dest_plan_act_tbl COUNT => ' || op_dest_plan_act_tbl.COUNT);
  DBMS_OUTPUT.PUT_LINE('OUT_ERR_NUM = ' || op_err_code);
  DBMS_OUTPUT.PUT_LINE('OUT_ERR_STRING = ' || op_err_msg);
  op_err_code := 0;
  op_err_msg  := 'Success';

EXCEPTION
  WHEN OTHERS THEN
    op_err_code := 1;
    op_err_msg  := 'Unhandled exception : ' || SQLERRM;
    RAISE;
END get_retention_action;
--
--
-- Added table function logic to join web user objid data to account groups (by Web OBJID)
FUNCTION get_web_acct_group_info (ip_web_objid IN NUMBER) RETURN t_web_acc_grp_tab PIPELINED
AS
  -- Get related groups and members based on a provided web_objid
  CURSOR c_get_grp_data
  IS
    SELECT web.s_login_name login_name,
      pi.x_part_inst_status part_inst_status,
      ag.objid account_group_id,
      ag.account_group_name,
      agm.esn,
      web.objid web_objid,
      ag.status account_group_status,
      agm.status account_group_member_status
    FROM table_web_user web,
      table_x_contact_part_inst conpi,
      table_part_inst pi,
      x_account_group ag,
      x_account_group_member agm
    WHERE 1                               = 1
    AND web.objid                         = ip_web_objid
    AND pi.objid                          = conpi.x_contact_part_inst2part_inst
    AND conpi.x_contact_part_inst2contact = web.web_user2contact
    AND agm.esn                           = pi.part_serial_no
    AND agm.account_group_id              = ag.objid
    AND UPPER(agm.status)                <> 'EXPIRED';

BEGIN

  -- Loop through all records
  FOR i IN c_get_grp_data LOOP
    -- Push rows out of the function as soon as they are created
    PIPE ROW ( t_web_acc_grp_row ( i.login_name , i.part_inst_status , i.account_group_id , i.account_group_name , i.esn , i.web_objid , i.account_group_status , i.account_group_member_status ) );
  END LOOP;
  -- Exit the program when all rows have been retrieved
  RETURN;

END get_web_acct_group_info;
--
--
-- Added table function logic to join web user objid data to account groups (by ESN)
FUNCTION get_web_acct_group_by_esn (ip_esn IN VARCHAR2) RETURN t_web_acc_grp_tab PIPELINED
AS
  -- Get related groups and members based on a provided web_objid
  CURSOR c_get_grp_data
  IS
    SELECT web.s_login_name login_name,
      pi.x_part_inst_status part_inst_status,
      ag.objid account_group_id,
      ag.account_group_name,
      agm.esn,
      web.objid web_objid,
      ag.status account_group_status,
      agm.status account_group_member_status
    FROM table_web_user web,
      table_x_contact_part_inst conpi,
      table_part_inst pi,
      x_account_group ag,
      x_account_group_member agm
    WHERE 1                               = 1
    AND agm.esn                           = ip_esn
    AND pi.objid                          = conpi.x_contact_part_inst2part_inst
    AND conpi.x_contact_part_inst2contact = web.web_user2contact
    AND agm.esn                           = pi.part_serial_no
    AND agm.account_group_id              = ag.objid
    AND UPPER(agm.status)                <> 'EXPIRED';

BEGIN

  -- Loop through all records
  FOR i IN c_get_grp_data
  LOOP
    -- Push rows out of the function as soon as they are created
    PIPE ROW ( t_web_acc_grp_row ( i.login_name , i.part_inst_status , i.account_group_id , i.account_group_name , i.esn , i.web_objid , i.account_group_status , i.account_group_member_status ) );
  END LOOP;
  -- Exit the program when all rows have been retrieved
  RETURN;

END get_web_acct_group_by_esn;
--
--
-- Added on 12/26/2014 by Juda Pena to determine if a pin has been burnt
FUNCTION is_pin_burned (ip_red_code IN VARCHAR2) RETURN VARCHAR2
IS
  -- Get the SMP from the part inst table (if it has NOT been burned)
  CURSOR c_get_part_inst_smp
  IS
    SELECT 1
    FROM table_part_inst
    WHERE 1        = 1
    AND x_red_code = ip_red_code
    AND x_domain   = 'REDEMPTION CARDS';
  -- Get the red card (if it has been burned)
  CURSOR c_get_red_card
  IS
    SELECT 'Y' FROM table_x_red_card WHERE x_red_code = ip_red_code;
  --
  l_is_burned_flag VARCHAR2(1);

BEGIN
  --
  OPEN c_get_red_card;
  FETCH c_get_red_card INTO l_is_burned_flag;
  IF c_get_red_card%NOTFOUND THEN
    l_is_burned_flag := 'N';
  END IF;
  CLOSE c_get_red_card;
  -- Return output
  RETURN(l_is_burned_flag);
  --
EXCEPTION
  WHEN OTHERS THEN
    RETURN('N');
END is_pin_burned;
--
--
-- Added on 10/17/2014 by Juda Pena to log procedure calls and parameters on ERROR_TABLE
PROCEDURE log_error (ip_error_text   IN VARCHAR2,
                     ip_error_date   IN DATE,
                     ip_action       IN VARCHAR2,
                     ip_key          IN VARCHAR2,
                     ip_program_name IN VARCHAR2)
AS
  PRAGMA AUTONOMOUS_TRANSACTION; -- Declare block as an autonomous transaction
BEGIN

  -- Insert log message
  INSERT INTO error_table
    (
      error_text,
      error_date,
      action,
      KEY,
      program_name
    )
    VALUES
    (
      ip_error_text,
      ip_error_date,
      ip_action ,
      ip_key,
      ip_program_name
    );
  -- Save changes
  COMMIT;

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    --RAISE;
END log_error;
--
--
-- Added by Juda Pena to insert a member record without any validations (plain insert)
PROCEDURE insert_member (ip_account_group_id        IN  NUMBER,
                         ip_esn                     IN  VARCHAR2,
                         ip_promotion_id            IN  NUMBER,
                         ip_status                  IN  VARCHAR2,
                         ip_member_order            IN  NUMBER,
                         ip_subscriber_uid          IN  VARCHAR2,
                         ip_master_flag             IN  VARCHAR2,
                         ip_site_part_id            IN  NUMBER,
                         ip_program_param_id        IN  NUMBER,
                         op_account_group_member_id OUT NUMBER,
                         op_err_code                OUT NUMBER,
                         op_err_msg                 OUT VARCHAR2)
AS
BEGIN

  -- Create new member (plain insert with no validations or logic)
  INSERT INTO x_account_group_member
    (
      objid,
      account_group_id,
      esn,
      member_order,
      site_part_id,
      promotion_id,
      status,
      subscriber_uid,
      master_flag,
      start_date,
      end_date,
      receive_text_alerts_flag,
      insert_timestamp,
      update_timestamp
    )
    VALUES
    (
      sa.sequ_account_group_member.NEXTVAL,
      ip_account_group_id,
      ip_esn,
      ip_member_order,
      ip_site_part_id,
      ip_promotion_id,
      UPPER(ip_status),
      ip_subscriber_uid,
      ip_master_flag,
      SYSDATE,
      NULL,
      DECODE(ip_master_flag,'Y','Y','N'), -- set receive_text_alerts_flag as Y for the first member (or the master)
      SYSDATE,
      SYSDATE
    )
  RETURNING objid
  INTO op_account_group_member_id;

  -- Set message as success
  op_err_code := 0;
  op_err_msg  := 'Success';

EXCEPTION
  WHEN OTHERS THEN
    -- Log error message
    log_error( ip_error_text => 'SQLERRM: ' || SQLERRM, ip_error_date => SYSDATE, ip_action => 'exception when others clause for ip_account_group_id = ' || ip_account_group_id ||' , ip_esn = ' || ip_esn || ' , ip_status = ' || ip_status || ' , ip_subscriber_uid = ' || ip_subscriber_uid || ' , ip_master_flag = ' || ip_master_flag, ip_key => ip_account_group_id, ip_program_name => 'brand_x_pkg.insert_member');
    op_err_code := 1;
    op_err_msg  := 'Unhandled exception : ' || SQLERRM;
    RAISE;
END insert_member;
--
--
-- Added on 12/15/2014 by Juda Pena to replace a member when a phone upgrade or warranty exchange is performed
-- Note: After a conversation with Vamsi could potentially be much safer if we include the account_group_id as an input parameter.
PROCEDURE replace_member (ip_old_esn            IN  VARCHAR2,
                          ip_new_esn            IN  VARCHAR2,
                          ip_call_trans_id      IN  NUMBER,
                          op_err_code           OUT NUMBER,
                          op_err_msg            OUT VARCHAR2)
AS
  l_old_acc_grp_mbr_rec x_account_group_member%ROWTYPE;
  -- Get the old member subscriber UID
  CURSOR c_get_old_subscriber_uid
  IS
    SELECT subscriber_uid,
      member_order,
      account_group_id
    FROM x_account_group_member
    WHERE esn = ip_old_esn
    ORDER BY (
      CASE UPPER(status)
        WHEN 'ACTIVE'
        THEN 1
        WHEN 'PAYMENT_PENDING'
        THEN 2
        WHEN 'INACTIVE'
        THEN 3
        WHEN 'EXPIRED'
        THEN 4
      END),
      (
      CASE
        WHEN (end_date IS NULL)
        THEN 1
        ELSE 2
      END ),
      insert_timestamp;

  old_subscriber_rec c_get_old_subscriber_uid%ROWTYPE;

BEGIN

  -- ESN validation
  IF ip_old_esn IS NULL OR ip_new_esn IS NULL THEN
    --
    op_err_code := 2;
    op_err_msg  := 'OLD ESN/NEW ESN cannot be blank.';
    -- Exit the program
    RETURN;
  END IF;
  -- Get the latest subscriber id for a given esn
  OPEN c_get_old_subscriber_uid;
  FETCH c_get_old_subscriber_uid INTO old_subscriber_rec;
  CLOSE c_get_old_subscriber_uid;
  -- Copying the subscriber id
  UPDATE x_account_group_member
  SET status         = 'ACTIVE',
    start_date       = SYSDATE,
    subscriber_uid   = old_subscriber_rec.subscriber_uid,
    member_order     = old_subscriber_rec.member_order
  WHERE esn          = ip_new_esn
  AND UPPER(status) <> 'EXPIRED';
  -- Updating the account group member details.
  UPDATE x_account_group_member
  SET status         = 'EXPIRED',
    end_date         = SYSDATE,
    update_timestamp = SYSDATE,
    subscriber_uid   = NULL
  WHERE esn          = ip_old_esn
  AND UPPER(status) IN ('ACTIVE','PENDING_ENROLLMENT') RETURNING objid,
    account_group_id,
    master_flag
  INTO l_old_acc_grp_mbr_rec.objid,
    l_old_acc_grp_mbr_rec.account_group_id,
    l_old_acc_grp_mbr_rec.master_flag;
  IF SQL%ROWCOUNT = 0 THEN
    -- Asked Vamsi if an error should be thrown and his response was "No"
    NULL;
    -- Exit the program
    --RETURN;
  END IF;
  -- Update existing row
  UPDATE x_account_group_member
  SET status         = 'ACTIVE'
  WHERE esn          = ip_new_esn
  AND UPPER(status) <> 'EXPIRED';
  -- If the old esn was the master then we need to set the new master esn
  IF l_old_acc_grp_mbr_rec.master_flag = 'Y' THEN
    -- Call change_master stored procedure to avoid code duplication
    change_master ( ip_account_group_id => l_old_acc_grp_mbr_rec.account_group_id, ip_esn => ip_new_esn, op_err_code => op_err_code, op_err_msg => op_err_msg );
    --
    IF op_err_code <> 0 THEN
      -- Use error codes from called routine (change_master)
      RETURN;
      --
    END IF;
  END IF;
  -- When the table_x_call_trans objid is passed then update the extension table
  IF ip_call_trans_id IS NOT NULL THEN
    -- Perform a fake update to get the table_x_call_trans_ext properly updated (from the t_call_trans trigger) with the account group information
    UPDATE table_x_call_trans
    SET update_stamp = update_stamp
    WHERE objid      = ip_call_trans_id;
  END IF;

  -- Set message as success
  op_err_code := 0;
  op_err_msg  := 'Success';

EXCEPTION
  WHEN OTHERS THEN
    -- Log error message
    log_error( ip_error_text => 'SQLERRM: ' || SQLERRM, ip_error_date => SYSDATE, ip_action => 'exception when others clause for ip_old_esn = ' || ip_old_esn ||' , ip_new_esn = ' || ip_new_esn, ip_key => ip_old_esn, ip_program_name => 'brand_x_pkg.replace_member');
    op_err_code := 1;
    op_err_msg  := 'Unhandled exception : ' || SQLERRM;
    RAISE;
END replace_member;
--
--
-- Added on 12/09/2014 by Juda Pena to return the next esn to be the master of an account group
FUNCTION select_next_master_esn (ip_account_group_id  IN  NUMBER,
                                 ip_old_master_esn    IN  VARCHAR2) RETURN VARCHAR2
IS
  -- Get the next active esn of a group  (ordered by member order and objid)
  CURSOR c_get_next_master_esn
  IS
    SELECT esn
    FROM x_account_group_member
    WHERE account_group_id = ip_account_group_id
    AND UPPER(status)     <> 'EXPIRED'
    AND (esn               <> ip_old_master_esn or ip_old_master_esn is null)     -- CR37756 PMistry 03/08/2016 Modify the condition to get next master if we don't have any master.
    AND master_flag = 'N'                                                         -- CR37756 PMistry 05/20/2016 Added master flag check as per review comment.
    ORDER BY member_order, objid;

  next_master_esn_rec c_get_next_master_esn%ROWTYPE;

BEGIN

  -- Get the next active esn of a group  (ordered by member order and objid)
  OPEN c_get_next_master_esn;
  FETCH c_get_next_master_esn INTO next_master_esn_rec;
  CLOSE c_get_next_master_esn;
  -- Return the output master esn
  RETURN(next_master_esn_rec.esn);

END select_next_master_esn;
--
--
-- Added on 12/09/2014 by Juda Pena to return the next member order
FUNCTION select_next_member_order (ip_account_group_id IN NUMBER) RETURN NUMBER
IS
  l_member_order NUMBER(22) := 1;
BEGIN

  -- Select next member_order for a given account group
  SELECT NVL( MAX(member_order),0) + 1
  INTO l_member_order
  FROM x_account_group_member
  WHERE account_group_id = ip_account_group_id;
  -- Return the member order
  RETURN( NVL(l_member_order, 1));

EXCEPTION
  WHEN OTHERS THEN
    -- Log error message
    log_error( ip_error_text => 'SQLERRM: ' || SQLERRM, ip_error_date => SYSDATE, ip_action => 'exception when others clause for ip_account_group_id = ' || ip_account_group_id, ip_key => ip_account_group_id, ip_program_name => 'brand_x_pkg.select_next_member_order');
    RETURN(1);
END select_next_member_order;
--
--
-- Added on 11/06/2014 by Juda Pena to update member information
PROCEDURE update_member (ip_account_group_member_id IN  NUMBER,
                         ip_esn                     IN  VARCHAR2,
                         ip_promotion_id            IN  NUMBER,
                         ip_status                  IN  VARCHAR2,
                         ip_start_date              IN  DATE,
                         ip_end_date                IN  DATE,
                         op_err_code                OUT NUMBER,
                         op_err_msg                 OUT VARCHAR2)
AS
BEGIN

  -- Updating the account group member details.
  UPDATE x_account_group_member
     SET promotion_id                 = NVL(ip_promotion_id,promotion_id),
         status                       = NVL(ip_status,status),
         start_date                   = NVL(ip_start_date,start_date),
         end_date                     = NVL(ip_end_date,end_date),
         update_timestamp             = SYSDATE
   WHERE ((objid = ip_account_group_member_id
          AND ip_account_group_member_id IS NOT NULL)
      OR (esn = ip_esn
          AND ip_esn IS NOT NULL
          AND ip_account_group_member_id IS NULL
          AND UPPER(status) IN ('ACTIVE','PENDING_ENROLLMENT')));

  -- Return error message when no rows were updated
  IF SQL%ROWCOUNT < 1 THEN
    op_err_code  := 2;
    op_err_msg   := 'Member was not updated';
  ELSE
    op_err_code := 0;
    op_err_msg  := 'Success';
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    -- Log error message
    log_error( ip_error_text => 'SQLERRM: ' || SQLERRM, ip_error_date => SYSDATE,
               ip_action => 'exception when others clause for ip_account_group_member_id = ' || ip_account_group_member_id || ' , ip_esn = ' || ip_esn || ' , ip_status = ' || ip_status,                ip_key => ip_account_group_member_id, ip_program_name => 'brand_x_pkg.update_member');
    op_err_code := 1;
    op_err_msg  := 'Unhandled exception : ' || SQLERRM;
    RAISE;
END update_member;
--
--
-- Added on 01/08/2015 by Juda Pena to update receive_text_alerts_flag
PROCEDURE update_receive_text_alerts (ip_esn                       IN  VARCHAR2,
                                      ip_receive_text_alerts_flag  IN  VARCHAR2,
                                      op_err_code                  OUT NUMBER,
                                      op_err_msg                   OUT VARCHAR2)
AS
BEGIN

  -- Updating the account group member details.
  UPDATE x_account_group_member
  SET receive_text_alerts_flag = ip_receive_text_alerts_flag,
    update_timestamp           = SYSDATE
  WHERE esn                    = ip_esn
  AND UPPER(status)           <> 'EXPIRED';

  op_err_code                 := 0;
  op_err_msg                  := 'Success';

EXCEPTION
  WHEN OTHERS THEN
    -- Log error message
    log_error( ip_error_text => 'SQLERRM: ' || SQLERRM, ip_error_date => SYSDATE, ip_action => 'exception when others clause for ip_esn = ' || ip_esn || ' , ip_receive_text_alerts_flag = ' || ip_receive_text_alerts_flag, ip_key => ip_esn, ip_program_name => 'brand_x_pkg.update_receive_text_alerts');
    op_err_code := 1;
    op_err_msg  := 'Unhandled exception : ' || SQLERRM;
    RAISE;
END update_receive_text_alerts;
--
--
-- Added on 11/24/2014 by Phani Kolipakula to check the compatibility between the service plan and esn.
FUNCTION valid_service_plan_esn (ip_service_plan_id IN NUMBER,
                                 ip_esn             IN VARCHAR2) RETURN VARCHAR2
IS

  CURSOR c_compatibility
  IS
    SELECT mv.sp_objid,
      pi.part_serial_no,
      pi.x_domain
    FROM table_part_inst pi,
      table_mod_level ml,
      table_part_num pn,
      sa.adfcrm_serv_plan_class_matview mv
    WHERE 1                 = 1
    AND pi.part_serial_no   = ip_esn
    AND pi.x_domain         = 'PHONES'
    AND ml.objid            = pi.n_part_inst2part_mod
    AND pn.objid            = ml.part_info2part_num
    AND mv.part_class_objid = pn.part_num2part_class
    AND mv.sp_objid         = ip_service_plan_id;

  sp_compatibility_rec c_compatibility%ROWTYPE;

BEGIN

  -- Validate service plan and esn compatibility
  OPEN c_compatibility;
  FETCH c_compatibility INTO sp_compatibility_rec;
  IF c_compatibility%NOTFOUND THEN
    -- Close the open cursor
    CLOSE c_compatibility;
    -- Incompatible service plan and esn combination
    RETURN('N');
  ELSE
    -- Close the open cursor
    CLOSE c_compatibility;
  END IF;
  -- service plan and esn are compatible
  RETURN('Y');

EXCEPTION
  WHEN OTHERS THEN
    -- Incompatible service plan and esn combination
    RETURN('N');
END valid_service_plan_esn;
--
--
-- Added on 12/01/2014 by Juda Pena to log service calls and parameters
PROCEDURE create_service_transaction_log (ip_client_transaction_id  IN  VARCHAR2,
                                          ip_client_id              IN  VARCHAR2,
                                          ip_error_code             IN  VARCHAR2,
                                          ip_error_message          IN  VARCHAR2,
                                          ip_server_transaction_id  IN  VARCHAR2,
                                          ip_custom_message         IN  VARCHAR2,
                                          ip_summary                IN  VARCHAR2,
                                          ip_custom_errcode         IN  VARCHAR2,
                                          ip_payload                IN  CLOB,
                                          ip_flow_name              IN  VARCHAR2,
                                          ip_operation_name         IN  VARCHAR2,
                                          ip_bus_org_id             IN  VARCHAR2,
                                          ip_source_system          IN  VARCHAR2,
                                          ip_instance_id            IN  NUMBER,
                                          ip_instance_name          IN  VARCHAR2,
                                          ip_failure_timestamp      IN  DATE,
                                          ip_failure_source         IN  VARCHAR2,
                                          ip_error_type             IN  VARCHAR2,
                                          ip_failure_target         IN  VARCHAR2,
                                          ip_esn                    IN  VARCHAR2,
                                          ip_min                    IN  VARCHAR2,
                                          ip_red_code               IN  VARCHAR2,
                                          ip_iccid                  IN  VARCHAR2,
                                          op_err_code               OUT NUMBER,
                                          op_err_msg                OUT VARCHAR2)
AS
BEGIN

  -- Insert transaction log
  INSERT INTO x_service_transaction_log
    (
      objid ,
      client_transaction_id ,
      client_id ,
      error_code ,
      error_message ,
      server_transaction_id ,
      custom_message ,
      summary ,
      custom_errcode ,
      payload ,
      flow_name ,
      operation_name ,
      bus_org_id ,
      source_system ,
      instance_id ,
      instance_name ,
      failure_timestamp ,
      failure_source ,
      error_type ,
      failure_target ,
      esn ,
      MIN ,
      red_code ,
      iccid
    )
    VALUES
    (
      sequ_service_transaction_log.NEXTVAL,
      ip_client_transaction_id ,
      ip_client_id ,
      ip_error_code ,
      ip_error_message ,
      ip_server_transaction_id ,
      SUBSTR(ip_custom_message,1,500) ,
      ip_summary ,
      ip_custom_errcode ,
      ip_payload ,
      ip_flow_name ,
      ip_operation_name ,
      ip_bus_org_id ,
      ip_source_system ,
      ip_instance_id ,
      ip_instance_name ,
      ip_failure_timestamp ,
      ip_failure_source ,
      ip_error_type ,
      ip_failure_target ,
      ip_esn ,
      ip_min ,
      ip_red_code ,
      ip_iccid
    );

  op_err_code := 0;
  op_err_msg  := 'Success';

EXCEPTION
  WHEN OTHERS THEN
    -- Log error message
    log_error( ip_error_text => 'SQLERRM: ' || SQLERRM, ip_error_date => SYSDATE, ip_action => 'exception when others clause for ip_client_transaction_id = ' || ip_client_transaction_id || ', ip_error_message = ' || ip_error_message, ip_key => ip_client_transaction_id, ip_program_name => 'brand_x_pkg.create_service_transaction_log');
    op_err_code := 1;
    op_err_msg  := 'Unhandled exception : ' || SQLERRM;
    RAISE;
END create_service_transaction_log;
--
--
-- Added on 11/06/2014 by Juda Pena to update account group information
PROCEDURE update_account_group (ip_account_group_id          IN  NUMBER,
                                ip_account_group_name        IN  VARCHAR2,
                                ip_service_plan_id           IN  NUMBER,
                                ip_service_plan_feature_date IN  DATE,
                                ip_program_enrolled_id       IN  NUMBER,
                                ip_status                    IN  VARCHAR2,
                                ip_start_date                IN  DATE,
                                ip_end_date                  IN  DATE,
                                op_err_code                  OUT NUMBER,
                                op_err_msg                   OUT VARCHAR2)
AS
c_active_device number;
BEGIN
  --
  IF ip_account_group_id IS NULL THEN
    op_err_code          := 2;
    op_err_msg           := 'Account group id cannot be blank.';
    --
    RETURN;
  END IF;

  --To check if there is any active device in the group (TW Web common standards)
      IF ip_status = 'EXPIRED' then
       SELECT  count(*)
                into c_active_device
      FROM   x_account_group_member agm,
             table_part_inst pi_esn
      WHERE  agm.account_group_id = ip_account_group_id
      AND    pi_esn.part_serial_no = agm.esn
      AND    pi_esn.x_domain = 'PHONES'
      AND    pi_esn.X_Part_Inst_Status=52;

      IF c_active_device>0 then
      op_err_code          := 5;
      op_err_msg           := 'Group has an active device and cannot be expired';
        --
        RETURN;
      END IF;
     END IF;
  -- Update the details in the Account Group .
  UPDATE x_account_group
  SET    account_group_name        = NVL(ip_account_group_name, account_group_name ),
         service_plan_id           = NVL(ip_service_plan_id, service_plan_id),
         service_plan_feature_date = NVL(ip_service_plan_feature_date, service_plan_feature_date),
         program_enrolled_id       = (
                                       CASE
                                         WHEN ( ip_program_enrolled_id = -1 )
                                         THEN NULL
                                         WHEN ( ip_program_enrolled_id IS NULL)
                                         THEN program_enrolled_id
                                         WHEN ( ip_program_enrolled_id > 0 )
                                         THEN ip_program_enrolled_id
                                         ELSE program_enrolled_id
                                       END ),
         status              = NVL(ip_status, status),
         start_date          = NVL(ip_start_date, start_date),
         end_date            = NVL(ip_end_date, end_date),
         update_timestamp = SYSDATE
  WHERE objid        = ip_account_group_id;
  -- If the group was not updated then
  IF SQL%ROWCOUNT = 0 THEN
    op_err_code  := 3;
    op_err_msg   := 'account group id ( ' || ip_account_group_id || ' ) was not found.';
    RETURN;
  END IF;
  -- Expire all the members in a group when status is EXPIRED and the END_DATE was passed
  IF ip_status = 'EXPIRED' AND ip_end_date IS NOT NULL THEN
    UPDATE x_account_group_member
    SET status             = ip_status, -- EXPIRED
      end_date             = ip_end_date
    WHERE account_group_id = ip_account_group_id;
  END IF;
  --
  op_err_code := 0;
  op_err_msg  := 'Success';

EXCEPTION
  WHEN OTHERS THEN
    -- Log error message
    log_error( ip_error_text => 'SQLERRM: ' || SQLERRM, ip_error_date => SYSDATE, ip_action => 'exception when others clause for ip_account_group_id = ' || ip_account_group_id || ' , ip_service_plan_id = ' || ip_service_plan_id || ' , ip_program_enrolled_id = ' || ip_program_enrolled_id || ' , ip_status = ' || ip_status, ip_key => ip_account_group_id, ip_program_name => 'brand_x_pkg.update_account_group');
    op_err_code := 1;
    op_err_msg  := 'Unhandled exception : ' || SQLERRM;
    RAISE;
END update_account_group;
--
--
--  Added on 11/19/2014 by Juda Pena to determine when an esn is the master of the account group
FUNCTION get_account_master_flag (ip_account_group_id IN NUMBER) RETURN VARCHAR2
IS
  --
  CURSOR c_count_mbrs
  IS
    SELECT COUNT(1) count_mbrs
    FROM x_account_group_member
    WHERE account_group_id = ip_account_group_id
    AND UPPER(status)     <> 'EXPIRED';

  count_mbrs_rec c_count_mbrs%ROWTYPE;
  l_master_flag  VARCHAR2(1) := 'N';

BEGIN

  -- Open cursor only when a valid account group id was passed
  IF ip_account_group_id IS NOT NULL THEN
    --
    OPEN c_count_mbrs;
    FETCH c_count_mbrs INTO count_mbrs_rec;
    CLOSE c_count_mbrs;
    IF NVL(count_mbrs_rec.count_mbrs,0) = 0 THEN
      -- Set the esn as the master
      l_master_flag := 'Y';
    ELSE
      l_master_flag := 'N';
    END IF;
  END IF;
  -- Return the result
  RETURN(NVL(l_master_flag,'N'));

EXCEPTION
  WHEN OTHERS THEN
    RETURN('N');
END get_account_master_flag;
--
--
--  Added on 12/11/2014 by Juda Pena to determine service plan id for a given group
FUNCTION get_group_service_plan_id (ip_account_group_id IN NUMBER) RETURN NUMBER
IS
  CURSOR c_get_service_plan
  IS
    SELECT service_plan_id
      FROM x_account_group
     WHERE objid = ip_account_group_id;

  service_plan_rec c_get_service_plan%ROWTYPE;

BEGIN
  --
  OPEN c_get_service_plan;
  FETCH c_get_service_plan INTO service_plan_rec;
  CLOSE c_get_service_plan;
  -- Return the result
  RETURN(service_plan_rec.service_plan_id);
  --
EXCEPTION
  WHEN OTHERS THEN
    RETURN(NULL);
END get_group_service_plan_id;
--
--
--  Added on 12/1/2014 by Juda Pena to get the group id based on a call_trans_id
PROCEDURE get_account_group_id (ip_call_trans_id    IN  NUMBER,
                                op_account_group_id OUT NUMBER,
                                op_master_flag      OUT VARCHAR2,
                                op_service_plan_id  OUT NUMBER)
AS
  -- Get the group id and master flag
  CURSOR c_get_account_group
  IS
    SELECT agm.account_group_id,
      agm.master_flag,
      ag.service_plan_id
    FROM x_account_group_member agm,
      x_account_group ag,
      table_x_call_trans ct
    WHERE ct.objid           = ip_call_trans_id
    AND ct.x_service_id      = agm.esn
    AND agm.account_group_id = ag.objid
    AND UPPER(agm.status)   <> 'EXPIRED';

BEGIN

  -- Get the group id and master flag
  OPEN c_get_account_group;
  FETCH c_get_account_group
  INTO op_account_group_id,
    op_master_flag,
    op_service_plan_id;
  CLOSE c_get_account_group;

EXCEPTION
  WHEN OTHERS THEN
    -- Log error message
    log_error( ip_error_text => 'SQLERRM: ' || SQLERRM, ip_error_date => SYSDATE, ip_action => 'exception when others clause for ip_call_trans_id = ' || ip_call_trans_id, ip_key => ip_call_trans_id, ip_program_name => 'brand_x_pkg.get_account_group_id');
    op_account_group_id := NULL;
    op_master_flag      := NULL;
    op_service_plan_id  := NULL;
END get_account_group_id;
--
--
--  Added on 12/1/2014 by Juda Pena to get the group id based on an esn
FUNCTION get_account_group_id (ip_esn            IN VARCHAR2,
                               ip_effective_date IN DATE) RETURN NUMBER
IS
  -- Get the group id and master flag
  CURSOR c_get_account_group
  IS
    SELECT objid account_group_id
    FROM x_account_group
    WHERE objid IN
      (SELECT account_group_id
      FROM x_account_group_member
      WHERE esn = ip_esn
      AND NVL(ip_effective_date, SYSDATE) BETWEEN start_date AND NVL(end_date,SYSDATE))
  ORDER BY start_date,
    end_date,
    objid;

  ag_rec c_get_account_group%ROWTYPE;

BEGIN

  IF ip_esn IS NOT NULL THEN
    -- Get the group id
    OPEN c_get_account_group;
    FETCH c_get_account_group INTO ag_rec;
    CLOSE c_get_account_group;
  END IF;

  RETURN(ag_rec.account_group_id);

EXCEPTION
  WHEN OTHERS THEN
    RETURN(NULL);
END get_account_group_id;
--
--
-- Added on 11/19/2014 by Juda Pena to get or generate the subscriber id
FUNCTION get_subscriber_uid (ip_esn IN VARCHAR2) RETURN VARCHAR2
IS
  -- Get the subscriber id given an ESN
  CURSOR c_get_subscriber
  IS
    SELECT subscriber_uid
    FROM x_account_group_member
    WHERE esn = ip_esn
    ORDER BY insert_timestamp;

  subscriber_rec c_get_subscriber%ROWTYPE;

  -- Get the latest esn given a subscriber id
  CURSOR c_get_latest_esn (p_subscriber_uid VARCHAR2)
  IS
    SELECT esn
    FROM x_account_group_member
    WHERE subscriber_uid = p_subscriber_uid
    ORDER BY insert_timestamp;

  latest_esn_rec c_get_latest_esn%ROWTYPE;

BEGIN

  -- Get the existing subscriber id (if available)
  OPEN c_get_subscriber;
  FETCH c_get_subscriber INTO subscriber_rec;
  IF c_get_subscriber%NOTFOUND THEN
    -- Get next random value (from randomUUI function)
    SELECT randomUUID
    INTO subscriber_rec.subscriber_uid
    FROM DUAL;
  ELSE
    -- Get the latest esn given a subscriber id
    OPEN c_get_latest_esn(subscriber_rec.subscriber_uid);
    FETCH c_get_latest_esn INTO latest_esn_rec;
    CLOSE c_get_latest_esn;
    -- If the latest esn for the subscriber id is different as the provided esn, then generate a new sequence
    IF NVL(latest_esn_rec.esn,-999) <> ip_esn THEN
      -- Get next sequence value
      SELECT randomUUID
      INTO subscriber_rec.subscriber_uid
      FROM DUAL;
    END IF;
  END IF;
  CLOSE c_get_subscriber;
  -- Return value
  RETURN(subscriber_rec.subscriber_uid);

EXCEPTION
  WHEN OTHERS THEN
    -- Log error message
    log_error( ip_error_text => 'SQLERRM: ' || SQLERRM, ip_error_date => SYSDATE, ip_action => 'exception when others clause for ip_esn = ' || ip_esn, ip_key => ip_esn, ip_program_name => 'brand_x_pkg.get_subscriber_uid');
    RETURN(NULL);
END get_subscriber_uid;
--
--
-- Added on 12/05/2014 by Juda Pena to get add on flag, service plan id, part number
PROCEDURE get_red_card_detail (ip_esn             IN  VARCHAR2,
                               ip_red_card_code   IN  VARCHAR2,
                               op_add_on_flag     OUT VARCHAR2,
                               op_service_plan_id OUT NUMBER,
                               op_part_number     OUT VARCHAR2,
                               op_err_code        OUT NUMBER,
                               op_err_msg         OUT VARCHAR2)
AS
  -- Get the red card part number
  CURSOR get_red_card_part_number
  IS
    SELECT part_number
    FROM table_part_num pn,
      table_mod_level ml,
      table_part_inst pi
    WHERE pi.x_red_code         = ip_red_card_code
    AND pi.n_part_inst2part_mod = ml.objid
    AND ml.part_info2part_num   = pn.objid
    AND pn.domain               = 'REDEMPTION CARDS'
  UNION
  SELECT part_number
  FROM table_part_num pn,
    table_mod_level ml,
    table_x_red_card rc
  WHERE rc.x_red_code        = ip_red_card_code
  AND rc.x_red_card2part_mod = ml.objid
  AND ml.part_info2part_num  = pn.objid
  AND pn.domain              = 'REDEMPTION CARDS';

BEGIN

  -- Get the service plan
  op_service_plan_id := get_service_plan_id ( f_esn => ip_esn, f_red_code => ip_red_card_code );
  -- Get the add on flag feature
  op_add_on_flag :=
  CASE NVL(( get_feature_value ( ip_service_plan_id => op_service_plan_id, ip_fea_name => 'SERVICE_PLAN_GROUP') ), 'NO')
  WHEN 'ADD_ON_DATA'  THEN 'YES'
  WHEN 'ADD_ON_ILD'   THEN 'YES' -- CR44729
  ELSE
    'NO'
  END;
  -- Get the part number for the red card code
  OPEN get_red_card_part_number;
  FETCH get_red_card_part_number INTO op_part_number;
  CLOSE get_red_card_part_number;
  --
  op_err_code := 0;
  op_err_msg  := 'Success';

EXCEPTION
  WHEN OTHERS THEN
    -- Log error message
    log_error( ip_error_text => 'SQLERRM: ' || SQLERRM, ip_error_date => SYSDATE, ip_action => 'exception when others clause for ip_esn = ' || ip_esn || ' , ip_red_card_code = ' || ip_red_card_code, ip_key => ip_esn, ip_program_name => 'brand_x_pkg.get_red_card_detail');
    op_err_code := 1;
    op_err_msg  := 'Unhandled exception : ' || SQLERRM;
    RAISE;
END get_red_card_detail;
--
--
-- Added on 11/24/2014 by Phani Kolipakula to check the compatibility between the account group service plan and esn.
FUNCTION valid_service_plan_group (ip_account_group_id       IN NUMBER,
                                   ip_esn                    IN VARCHAR2) RETURN VARCHAR2
IS
  -- Get the service plan, and domain for a given account group id
  CURSOR c_compatibility
  IS
    SELECT mv.sp_objid,
      pi.part_serial_no,
      pi.x_domain
    FROM table_part_inst pi,
      table_mod_level ml,
      table_part_num pn,
      sa.adfcrm_serv_plan_class_matview mv
    WHERE 1                 = 1
    AND pi.part_serial_no   = ip_esn
    AND pi.x_domain         = 'PHONES'
    AND ml.objid            = pi.n_part_inst2part_mod
    AND pn.objid            = ml.part_info2part_num
    AND mv.part_class_objid = pn.part_num2part_class
    AND mv.sp_objid        IN
      (SELECT service_plan_id
      FROM x_account_group
      WHERE objid = ip_account_group_id
      );
  sp_compatibility_rec c_compatibility%ROWTYPE;

BEGIN

  OPEN c_compatibility;
  FETCH c_compatibility INTO sp_compatibility_rec;
  IF c_compatibility%NOTFOUND THEN
    -- Close the cursor and continue
    CLOSE c_compatibility;
    -- Incompatible service plan and esn combination
    RETURN('N');
  ELSE
    -- Close the cursor and continue
    CLOSE c_compatibility;
  END IF;
  -- Service plan and esn are compatible
  RETURN('Y');

EXCEPTION
  WHEN OTHERS THEN
    -- Log error message
    log_error( ip_error_text => 'SQLERRM: ' || SQLERRM, ip_error_date => SYSDATE, ip_action => 'exception when others clause for ip_account_group_id = ' || ip_account_group_id || ' , ip_esn = ' || ip_esn, ip_key => ip_account_group_id, ip_program_name => 'brand_x_pkg.valid_service_plan_group');
    -- Incompatible service plan and esn combination
    RETURN('N');
END valid_service_plan_group;
--
--
-- Added on 11/25/2014 by Phani Kolipakula to validate all queued card sp/no lines against the provided red card code sp/no lines.
FUNCTION valid_queued_red_cards (ip_esn           IN VARCHAR2,
                                 ip_red_card_code IN VARCHAR2) RETURN VARCHAR2
AS
  -- Cursor to get the queued red cards for all the members in the group.
  CURSOR c_get_queued_pins
  IS
    SELECT *
    FROM table_part_inst pi
    WHERE pi.part_to_esn2part_inst IN
      (SELECT objid
      FROM table_part_inst
      WHERE part_serial_no IN
        (SELECT esn
        FROM x_account_group_member
        WHERE account_group_id IN
          (SELECT account_group_id
          FROM x_account_group_member
          WHERE esn          = ip_esn
          AND UPPER(status) <> 'EXPIRED'
          )
      AND UPPER(status) <> 'EXPIRED'
        )
      )
    AND pi.x_part_inst_status
      ||'' = '400'; -- Queued redemption cards
    -- Get number of lines from the service plan features
    -- CR37756 06/13/2016 sethiraj - Modify the query to avoide single row exception.
    CURSOR c_no_of_lines ( p_red_card_code IN VARCHAR2)
    IS
      SELECT TO_NUMBER(
        (SELECT fea_value
        FROM adfcrm_serv_plan_feat_matview
        WHERE sp_objid = mv.sp_objid
        AND fea_name   = 'NUMBER_OF_LINES'
        ) ) number_of_lines
      FROM table_part_inst rc,
        table_mod_level ml,
        table_part_num pn,
        adfcrm_serv_plan_class_matview mv
      WHERE 1                    = 1
      AND rc.x_red_code          = p_red_card_code
      AND ml.objid               = rc.n_part_inst2part_mod
      AND pn.objid               = ml.part_info2part_num
      AND pn.part_num2part_class = mv.part_class_objid;

      queued_lines_rec c_no_of_lines%ROWTYPE;

      pin_lines_rec c_no_of_lines%ROWTYPE;

BEGIN

      -- Loop through queued pins for all esns that are members of the group along with the provided ESN
      FOR i IN c_get_queued_pins LOOP
        -- Fetching the sp/no. of lines for the given queued red code.
        OPEN c_no_of_lines (i.x_red_code);
        FETCH c_no_of_lines INTO queued_lines_rec;
        CLOSE c_no_of_lines;
        -- Fetching the sp/no. of lines for the given red card.
        OPEN c_no_of_lines (ip_red_card_code);
        FETCH c_no_of_lines INTO pin_lines_rec;
        CLOSE c_no_of_lines;
        -- If queued card sp/no. lines matches the provided red card code sp/no lines.
        IF queued_lines_rec.number_of_lines <> pin_lines_rec.number_of_lines THEN
          -- Return as an invalid when even 1 does not match the criteria
          RETURN('N');
        END IF;
      END LOOP;

      -- Return as a valid scenario
      RETURN('Y');

EXCEPTION
  WHEN OTHERS THEN
    -- Log error message
   log_error( ip_error_text => 'SQLERRM: ' || SQLERRM, ip_error_date => SYSDATE, ip_action => 'exception when others clause for ip_esn = ' || ip_esn || ' , ip_red_card_code = ' || ip_red_card_code, ip_key => ip_esn, ip_program_name => 'brand_x_pkg.valid_queued_red_cards');
    -- Return as invalid combination whenever an exception occurs
    RETURN('N');
END valid_queued_red_cards;
--
--
-- Added on 11/25/2014 by Juda Pena, overloaded to validate all queued pins service plan no. of lines against the provided es service plan no lines.
FUNCTION valid_queued_red_cards (ip_esn             IN VARCHAR2,
                                 ip_service_plan_id IN NUMBER) RETURN VARCHAR2
AS
    -- Cursor to get the queued red cards for all the members in the group.
    CURSOR c_get_queued_pins
    IS
      SELECT *
      FROM table_part_inst pi
      WHERE pi.part_to_esn2part_inst IN
        (SELECT objid
        FROM table_part_inst
        WHERE part_serial_no IN
          (SELECT esn
          FROM x_account_group_member
          WHERE account_group_id IN
            (SELECT account_group_id
            FROM x_account_group_member
            WHERE esn          = ip_esn
            AND UPPER(status) <> 'EXPIRED'
            )
        AND UPPER(status) <> 'EXPIRED'
          )
        )
      AND pi.x_part_inst_status
        ||'' = '400'; -- Queued Redemption Cards
      -- Get number of lines from the service plan features
      -- CR37756 06/13/2016 sethiraj - Modify the query to avoide single row exception.
      CURSOR c_sp_no_of_lines
      IS
        SELECT TO_NUMBER(
          (SELECT fea_value
          FROM adfcrm_serv_plan_feat_matview
          WHERE sp_objid = ip_service_plan_id
          AND fea_name   = 'NUMBER_OF_LINES'
          ) ) number_of_lines
        FROM DUAL;
        -- Get number of lines from the service plan features
        CURSOR c_rc_no_of_lines ( p_red_card_code IN VARCHAR2)
        IS
          SELECT TO_NUMBER(
            (SELECT fea_value
            FROM adfcrm_serv_plan_feat_matview
            WHERE sp_objid = mv.sp_objid
            AND fea_name   = 'NUMBER_OF_LINES'
            ) ) number_of_lines
          FROM table_part_inst rc,
            table_mod_level ml,
            table_part_num pn,
            adfcrm_serv_plan_class_matview mv
          WHERE 1                    = 1
          AND rc.x_red_code          = p_red_card_code
          AND ml.objid               = rc.n_part_inst2part_mod
          AND pn.objid               = ml.part_info2part_num
          AND pn.part_num2part_class = mv.part_class_objid;

          queued_lines_rec c_rc_no_of_lines%ROWTYPE;

          pin_lines_rec c_sp_no_of_lines%ROWTYPE;

BEGIN

          -- Loop through queued pins for all esns that are members of the group along with the provided ESN
          FOR i IN c_get_queued_pins LOOP
            -- Fetching the sp/no. of lines for the given queued red code.
            OPEN c_rc_no_of_lines(i.x_red_code);
            FETCH c_rc_no_of_lines INTO queued_lines_rec;
            CLOSE c_rc_no_of_lines;
            -- Fetching the sp/no. of lines for the given red card.
            OPEN c_sp_no_of_lines;
            FETCH c_sp_no_of_lines INTO pin_lines_rec;
            CLOSE c_sp_no_of_lines;
            -- If queued card sp/no. lines matches the provided red card code sp/no lines.
            IF queued_lines_rec.number_of_lines <> pin_lines_rec.number_of_lines THEN
              -- Return as an invalid when even 1 does not match the criteria
              RETURN('N');
            END IF;
          END LOOP;
          -- Return as a valid scenario
          RETURN('Y');

EXCEPTION
  WHEN OTHERS THEN
    -- Return as invalid combination whenever an exception occurs
    RETURN('N');
END valid_queued_red_cards;
--
--
-- Added on 12/09/2014 by Juda Pena to validate red card sp against the account group sp.
FUNCTION incompatible_sp_enrollment (ip_esn            IN VARCHAR2,
                                     ip_red_card_code  IN VARCHAR2) RETURN VARCHAR2
AS
        -- Cursor to get the queued red cards for all the members in the group.
        CURSOR c_grp_service_plan
        IS
          SELECT service_plan_id
          FROM x_account_group
          WHERE objid IN
            (SELECT account_group_id
            FROM x_account_group_member
            WHERE esn          = ip_esn
            AND UPPER(status) <> 'EXPIRED'
            )
        AND UPPER(status) <> 'EXPIRED';
        -- Hold cursor data
        grp_service_plan c_grp_service_plan%ROWTYPE;
        l_rc_service_plan_id         NUMBER;
        l_incompatible_sp_enrollment VARCHAR2(1) := 'Y';

BEGIN

        -- Get the service plan
        l_rc_service_plan_id := get_service_plan_id ( f_esn => ip_esn, f_red_code => ip_red_card_code );
        -- Get the group service plan
        OPEN c_grp_service_plan;
        FETCH c_grp_service_plan INTO grp_service_plan;
        CLOSE c_grp_service_plan;
        -- If service plans do not match then the validation failed.
        IF NVL(l_rc_service_plan_id, 99999999) <> NVL(grp_service_plan.service_plan_id, 88888888) AND
          -- Make sure the validation occurs for all other service plans that are not Add-On Data Cards (since the Add-On is a service plan)
          NVL( get_feature_value ( ip_service_plan_id => l_rc_service_plan_id, ip_fea_name => 'SERVICE_PLAN_GROUP'), '**') NOT IN ('ADD_ON_DATA','ADD_ON_ILD') THEN --CR44729 added 'ADD_ON_ILD'
          -- Did not pass the validation
          l_incompatible_sp_enrollment := 'Y';
        ELSE
          -- Passed the validation
          l_incompatible_sp_enrollment := 'N';
        END IF;

        -- Return output result
        RETURN(l_incompatible_sp_enrollment);

EXCEPTION
  WHEN OTHERS THEN
    -- Return as failed whenever an exception occurs
    RETURN('Y');
END incompatible_sp_enrollment;
--
--
-- Added on 12/09/2014 by Juda Pena to validate sp against the account group sp.
FUNCTION incompatible_sp_enrollment (ip_esn             IN VARCHAR2,
                                     ip_service_plan_id IN NUMBER) RETURN VARCHAR2
AS
      -- Cursor to get the queued red cards for all the members in the group.
      CURSOR c_grp_service_plan
      IS
        SELECT service_plan_id
        FROM x_account_group
        WHERE objid IN
          (SELECT account_group_id
          FROM x_account_group_member
          WHERE esn          = ip_esn
          AND UPPER(status) <> 'EXPIRED'
          )
      AND UPPER(status) <> 'EXPIRED';

      -- Hold cursor data
      grp_service_plan c_grp_service_plan%ROWTYPE;

      l_incompatible_sp_enrollment VARCHAR2(1) := 'Y';

BEGIN

      -- Get the group service plan
      OPEN c_grp_service_plan;
      FETCH c_grp_service_plan INTO grp_service_plan;
      CLOSE c_grp_service_plan;
      -- If service plans do not match then fail the validation.
      IF NVL(ip_service_plan_id, 99999999) <> NVL(grp_service_plan.service_plan_id, 88888888) AND
        -- Make sure the validation occurs for all other service plans that are not Add-On Data Cards (since the Add-On is a service plan)
        NVL( get_feature_value ( ip_service_plan_id => ip_service_plan_id, ip_fea_name => 'SERVICE_PLAN_GROUP'),'**') NOT IN ( 'ADD_ON_DATA','ADD_ON_ILD') THEN --CR44729 added 'ADD_ON_ILD'
        -- Did not pass the validation
        l_incompatible_sp_enrollment := 'Y';
      ELSE
        -- Passed the validation
        l_incompatible_sp_enrollment := 'N';
      END IF;

      -- Return output result
      RETURN(l_incompatible_sp_enrollment);

EXCEPTION
  WHEN OTHERS THEN
    -- Return as failed whenever an exception occurs
    RETURN('Y');
END incompatible_sp_enrollment;
--
--
-- Added on 11/25/2014 by Phani Kolipakula to validate actual group members against the provided red card code sp/number of lines.
FUNCTION valid_number_of_lines (ip_esn                IN  VARCHAR2,
                                ip_red_card_code      IN  VARCHAR2,
                                op_available_capacity OUT NUMBER) RETURN VARCHAR2
AS

    -- Count the amount of members currently in the group
    CURSOR c_count_members
    IS
      SELECT COUNT(1) count_members
      FROM x_account_group_member
      WHERE account_group_id IN
        (SELECT account_group_id
        FROM x_account_group_member
        WHERE esn          = ip_esn
        AND UPPER(status) <> 'EXPIRED'
        )
    AND UPPER(status) <> 'EXPIRED'
    ;
    -- Get number of lines from the service plan features
    -- CR37756 04/28/2016 PMistry modify the query to avoide single row exception.
    CURSOR c_no_of_lines(ip_pin IN VARCHAR2)
    IS
 SELECT pn.part_number,
 part_num2part_class,
 TO_NUMBER( ( SELECT NVL(number_of_lines,1)
 FROM   sa.service_plan_feat_pivot_mv
 WHERE  service_plan_objid = mv.sp_objid
 ) ) number_of_lines
 FROM  table_part_inst rc,
 table_mod_level ml,
 table_part_num pn,
 adfcrm_serv_plan_class_matview mv
 WHERE 1 = 1
 AND   rc.x_red_code = ip_pin
 AND   rc.x_domain             = 'REDEMPTION CARDS'
 AND   ml.objid = rc.n_part_inst2part_mod
 AND   pn.objid = ml.part_info2part_num
 AND    pn.domain               = 'REDEMPTION CARDS'
 AND   pn.part_num2part_class = mv.part_class_objid
    -- CR41658
      UNION
 SELECT pn.part_number,
  part_num2part_class,
  TO_NUMBER( ( SELECT NVL(number_of_lines,1)
 FROM   sa.service_plan_feat_pivot_mv
 WHERE  service_plan_objid = mv.sp_objid
 ) ) number_of_lines
 FROM   table_x_red_card rc ,
 table_mod_level ml ,
 table_part_num pn,
 adfcrm_serv_plan_class_matview mv
 WHERE  rc.x_red_code       = ip_pin
 AND    pn.domain             = 'REDEMPTION CARDS'
 AND    ml.objid              = rc.x_red_card2part_mod
 AND    ml.part_info2part_num = pn.objid
 AND   pn.part_num2part_class = mv.part_class_objid
     -- CR41658
      ;


      no_of_lines_rec c_no_of_lines%ROWTYPE;
      count_members_rec c_count_members%ROWTYPE;
      lv_account_gorup_id  x_account_group_member.account_group_id%type; -- CR46213
      lv_esn    table_part_inst.part_serial_no%TYPE;    -- CR46213
      lv_number_of_lines  NUMBER;      -- CR46213

BEGIN

      -- Set the capacity of members to zero (0)
      op_available_capacity := 0;
      -- Return the no of lines from the ESN's group

      OPEN c_count_members;
      FETCH c_count_members INTO count_members_rec;
      CLOSE c_count_members;

      -- CR46213
 BEGIN

  SELECT pi.part_serial_no
  INTO lv_esn
  FROM table_x_call_trans ct,
  table_x_red_card rc,
  table_part_inst pi,
  table_site_part sp
  WHERE     1 = 1
  AND rc.red_card2call_trans = ct.objid
  AND rc.x_red_code = ip_red_card_code
  AND pi.x_part_inst2site_part = sp.objid
  AND ct.call_trans2site_part = sp.objid
  AND ROWNUM = 1
  ;

 EXCEPTION WHEN OTHERS
 THEN

  NULL;

 END;

 IF lv_esn IS NOT NULL
 THEN

  BEGIN
   SELECT account_group_id
   INTO  lv_account_gorup_id
   FROM x_account_group_member
   WHERE esn          = lv_esn
   AND UPPER(status) <> 'EXPIRED'
   ;

  EXCEPTION WHEN OTHERS
  THEN

   lv_account_gorup_id := NULL;

  END;

  BEGIN

   SELECT sa.brand_x_pkg.get_number_of_lines(sa.brand_x_pkg.get_group_service_plan_id(lv_account_gorup_id))
   INTO lv_number_of_lines
   FROM dual;

  EXCEPTION WHEN OTHERS
  THEN

   lv_number_of_lines := NULL;

  END;
 ELSE

       -- Get the number of lines allowed for the PIN's service plan
       OPEN c_no_of_lines(ip_red_card_code);
       FETCH c_no_of_lines INTO no_of_lines_rec;
       CLOSE c_no_of_lines;

       lv_number_of_lines := no_of_lines_rec.number_of_lines;

 END IF;

      -- Validate the number of lines from the group against the number of lines allowed from the PIN's service plan
      IF count_members_rec.count_members > NVL(lv_number_of_lines,0) THEN
        --
        RETURN('N'); -- Invalid
      ELSE
        -- Calculate the amount of members that could potentially be added to the group
        op_available_capacity := NVL(lv_number_of_lines,1) - count_members_rec.count_members;
        --CR48716
        IF (op_available_capacity > 0) AND (is_master_esn_active (lv_esn) = 'N') AND (lv_esn IS NOT NULL)  --CR52537
        THEN --{
         op_available_capacity := 0;
        END IF; --}
        --
        RETURN('Y'); -- Valid
      END IF;

EXCEPTION
  WHEN OTHERS THEN
    RETURN('N'); -- Invalid
END valid_number_of_lines;
--
--
-- Added on 11/25/2014 by Phani Kolipakula to validate actual group members against the provided red card code sp/number of lines.
FUNCTION valid_number_of_lines (ip_esn                IN  VARCHAR2,
                                ip_service_plan_id    IN  VARCHAR2,
                                op_available_capacity OUT NUMBER,
                                op_number_of_lines    OUT NUMBER) RETURN VARCHAR2
AS
    -- Count the amount of members currently in the group
    CURSOR c_count_members
    IS
      SELECT COUNT(1) count_members
      FROM x_account_group_member
      WHERE account_group_id IN
        (SELECT account_group_id
        FROM x_account_group_member
        WHERE esn          = ip_esn
        AND UPPER(status) <> 'EXPIRED'
        )
    AND UPPER(status) <> 'EXPIRED';

    count_members_rec c_count_members%ROWTYPE;

BEGIN

    -- Set the capacity of members to zero (0)
    op_available_capacity := 0;
    -- Get the service plan feature number of lines allowed
    op_number_of_lines := NVL( get_number_of_lines ( ip_service_plan_id => ip_service_plan_id), 1);
    -- Return the no of lines from the ESN's group
    OPEN c_count_members;
    FETCH c_count_members INTO count_members_rec;
    CLOSE c_count_members;
    -- Validate the number of lines from the group against the number of lines allowed from the PIN's service plan
    IF count_members_rec.count_members > op_number_of_lines THEN
      --
      RETURN('N'); -- Invalid
    ELSE
      -- Calculate the amount of members that could potentially be added to the group
      op_available_capacity := NVL(op_number_of_lines,1) - count_members_rec.count_members;
      --
      RETURN('Y'); -- Valid
    END IF;

EXCEPTION
  WHEN OTHERS THEN
    RETURN('N'); -- Invalid
END valid_number_of_lines;
--
--
-- Added on 11/25/2014 by Juda Pena to validate
FUNCTION valid_number_of_lines (ip_esn                IN  VARCHAR2,
                                ip_service_plan_id    IN  VARCHAR2) RETURN VARCHAR2
AS
  -- Count the amount of members currently in the group
  CURSOR c_get_grp_service_plan
  IS
    SELECT service_plan_id
    FROM x_account_group
    WHERE objid IN
      (SELECT account_group_id
      FROM x_account_group_member
      WHERE esn          = ip_esn
      AND UPPER(status) <> 'EXPIRED'
      );

  grp_service_plan_rec c_get_grp_service_plan%ROWTYPE;

  l_grp_no_of_lines NUMBER;
  l_sp_no_of_lines  NUMBER;

BEGIN

  -- Return the no of lines from the ESN's group
  OPEN c_get_grp_service_plan;
  FETCH c_get_grp_service_plan INTO grp_service_plan_rec;
  CLOSE c_get_grp_service_plan;
  -- Get the service plan feature number of lines allowed
  l_grp_no_of_lines := NVL( get_number_of_lines ( ip_service_plan_id => grp_service_plan_rec.service_plan_id), 1);
  -- Get the service plan feature number of lines allowed
  l_sp_no_of_lines := NVL( get_number_of_lines ( ip_service_plan_id => ip_service_plan_id), 1);
  -- Validate the number of lines from the group against the number of lines allowed from the PIN's service plan
  -- IF l_grp_no_of_lines < l_sp_no_of_lines THEN -- Temporary commented out by Juda Pena
  IF l_grp_no_of_lines > l_sp_no_of_lines THEN
    --
    RETURN('N'); -- Invalid
  ELSE
    --
    RETURN('Y'); -- Valid
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    RETURN('N'); -- Invalid
END valid_number_of_lines;
--
--
-- Added on 11/14/2014 by  phani kolipakula to add a account group member
PROCEDURE create_member (ip_account_group_id         IN  NUMBER,
                         ip_esn                      IN  VARCHAR2,
                         ip_promotion_id             IN  NUMBER,
                         ip_status                   IN  VARCHAR2,
                         ip_member_order             IN  NUMBER,
                         op_subscriber_uid           OUT VARCHAR2,
                         op_account_group_member_id  OUT NUMBER,
                         op_err_code                 OUT NUMBER,
                         op_err_msg                  OUT VARCHAR2)
AS
  --Cursor for no of lines present in the plan in account group member
  CURSOR c_account_group_count
  IS
    SELECT COUNT(1) count_members
    FROM x_account_group_member
    WHERE account_group_id = ip_account_group_id
    AND UPPER(status)     <> 'EXPIRED';
  --Cursor for checking the lines allowed for the plan with service plan table
  CURSOR c_no_of_lines_plan_based
  IS
    SELECT spmv.fea_value
    FROM adfcrm_serv_plan_feat_matview spmv,
      x_account_group ag,
      x_account_group_member agm
    WHERE ag.objid    = ip_account_group_id
    AND spmv.sp_objid = ag.service_plan_id
    AND ag.objid      = agm.account_group_id
    AND spmv.fea_name = 'NUMBER_OF_LINES';
  -- Cursor for the status in the account group
  CURSOR c_esn_account_group
  IS
    SELECT 1
    FROM x_account_group
    WHERE objid        = ip_account_group_id
    AND UPPER(status) <> 'EXPIRED'; -- ESN VALIDATION  AND CHECKING THE STATUS
  -- Cursor used to search if an esn is already part of an existing group
  CURSOR c_esn_account_group_member
  IS
    SELECT account_group_id
      --cwl 1/16/2015
      ,
      objid account_group_member_objid
      --cwl 1/16/2015
    FROM x_account_group_member
    WHERE esn          = ip_esn
    AND UPPER(status) <> 'EXPIRED';

  account_group_count_rec c_account_group_count%ROWTYPE;
  no_of_lines_permitted c_no_of_lines_plan_based%ROWTYPE;
  account_group_rec c_esn_account_group%ROWTYPE;
  account_group_member_rec c_esn_account_group_member%ROWTYPE;

BEGIN

  -- ESN validation
  IF ip_esn IS NULL THEN
    --
    op_err_code := 2;
    op_err_msg  := 'ESN cannot be blank.';
    --
    -- Exit the routine when an error is found
    RETURN;
  END IF;

  -- Validating if the account group exists.
  OPEN c_esn_account_group;
  FETCH c_esn_account_group INTO account_group_rec ;
  IF c_esn_account_group%NOTFOUND THEN
    op_err_code := 3;
    op_err_msg  := 'Account group does not exist.';
    CLOSE c_esn_account_group;
    -- Exit the routine when an error is found
    RETURN;
  ELSE
    CLOSE c_esn_account_group;
  END IF;

  -- Validating if the esn is already part of an account group.
  OPEN c_esn_account_group_member;
  FETCH c_esn_account_group_member INTO account_group_member_rec;
  IF c_esn_account_group_member%found THEN
    -- Close the current cursor
    CLOSE c_esn_account_group_member;
    --
    IF account_group_member_rec.account_group_id = ip_account_group_id THEN
      -- Set message as success
      --cwl 1/16/2015
      op_account_group_member_id := account_group_member_rec.account_group_member_objid;
      --cwl 1/16/2015
      op_err_code := 0;
      op_err_msg  := 'Success';
      -- Exit the routine when an error is found
      RETURN;
    ELSE
      op_err_code := 4;
      op_err_msg  := 'Member is already part of account group [ ' || account_group_member_rec.account_group_id || ' ]';
      --
      -- Exit the routine when an error is found
      RETURN;
    END IF;
  ELSE
    -- Close the current cursor
    CLOSE c_esn_account_group_member;
  END IF;

  -- Validate service plan compatibility
  IF valid_service_plan_group ( ip_account_group_id => ip_account_group_id, ip_esn => ip_esn ) = 'N' THEN
    -- Set error code and msg
    op_err_code := 6;
    op_err_msg  := 'Service plan is not compatible with the provided ESN';
    -- Exit the routine when an error is found
    RETURN;
  END IF;

  -- Get the lines in the account group member to be furhter validated against the max lines allowed per the plan
  OPEN c_no_of_lines_plan_based;
  FETCH c_no_of_lines_plan_based INTO no_of_lines_permitted;
  CLOSE c_no_of_lines_plan_based;
  -- Get the member count
  OPEN c_account_group_count;
  FETCH c_account_group_count INTO account_group_count_rec.count_members;
  IF account_group_count_rec.count_members >= no_of_lines_permitted.fea_value THEN
    CLOSE c_account_group_count;
    --
    op_err_code := 5;
    op_err_msg  := 'Group [ ' || ip_account_group_id || ' ] has reached the max number of members allowed';
    --
    -- Exit the routine when an error is found
    RETURN;
  ELSE
    CLOSE c_account_group_count;
  END IF;

  -- Call wrapper to insert member record
  insert_member ( ip_account_group_id => ip_account_group_id , ip_esn => ip_esn, ip_promotion_id => ip_promotion_id, ip_status => ip_status, ip_member_order => select_next_member_order ( ip_account_group_id => ip_account_group_id), ip_subscriber_uid => get_subscriber_uid (ip_esn), ip_master_flag => get_account_master_flag ( ip_account_group_id => ip_account_group_id) , ip_site_part_id => NULL, ip_program_param_id => NULL, op_account_group_member_id => op_account_group_member_id, op_err_code => op_err_code, op_err_msg => op_err_msg );
  IF op_err_code <> 0 THEN
    -- Exit the process whenever an error occured
    RETURN;
  END IF;

  -- Set message as success
  op_err_code := 0;
  op_err_msg  := 'Success';

EXCEPTION
  WHEN OTHERS THEN
    -- Log error message
    log_error( ip_error_text => 'SQLERRM: ' || SQLERRM, ip_error_date => SYSDATE, ip_action => 'exception when others clause for ip_account_group_id = ' || ip_account_group_id || ' , ip_esn = ' || ip_esn || ' , ip_status = ' || ip_status, ip_key => ip_account_group_id, ip_program_name => 'brand_x_pkg.create_member');
    op_err_code := 1;
    op_err_msg  := 'Unhandled exception : ' || SQLERRM;
    RAISE;
END create_member;
--
--
-- Added on 11/18/2014 by Juda Pena to get the member and group objids
PROCEDURE get_member_info (ip_esn                         IN  VARCHAR2,
                           op_account_group_member_id     OUT NUMBER,
                           op_account_group_id            OUT NUMBER,
                           op_account_group_member_status OUT VARCHAR2,
                           op_master_flag                 OUT VARCHAR2,
                           op_err_code                    OUT NUMBER,
                           op_err_msg                     OUT VARCHAR2)
AS
  -- Get member information
  CURSOR c_get_member
  IS
    SELECT objid,
      account_group_id,
      status,
      master_flag
    FROM x_account_group_member
    WHERE esn          = ip_esn
    AND UPPER(status) <> 'EXPIRED';

BEGIN

  --
  OPEN c_get_member;
  FETCH c_get_member
  INTO op_account_group_member_id,
    op_account_group_id,
    op_account_group_member_status,
    op_master_flag;
  IF c_get_member%NOTFOUND THEN
    CLOSE c_get_member;
    --
    op_err_code := 2;
    op_err_msg  := 'Member information was not found';
    -- Exit the procedure
    RETURN;
  ELSE
    CLOSE c_get_member;
  END IF;
  --
  op_err_code := 0;
  op_err_msg  := 'Success';

EXCEPTION
  WHEN OTHERS THEN
    -- Log error message
    log_error( ip_error_text => 'SQLERRM: ' || SQLERRM, ip_error_date => SYSDATE, ip_action => 'exception when others clause for ip_esn = ' || ip_esn, ip_key => ip_esn, ip_program_name => 'brand_x_pkg.get_member_info');
    op_err_code := 1;
    op_err_msg  := 'Unhandled exception : ' || SQLERRM;
    RAISE;
END get_member_info;
--
--
-- Added on 11/13/2014 by Juda Pena to get the email and web user objid
PROCEDURE get_account_info (ip_esn              IN  VARCHAR2,
                            ip_bus_org_id       IN  VARCHAR2,
                            op_email            OUT VARCHAR2,
                            op_web_user_objid   OUT NUMBER,
                            op_account_group_id OUT NUMBER,
                            op_err_code         OUT NUMBER,
                            op_err_msg          OUT VARCHAR2)
AS
  -- Query to retrieve the Web User Objid and Email
  CURSOR c_get_account_info
  IS
    SELECT c.e_mail,
      wu.objid web_user_objid
    FROM table_x_contact_part_inst cpi,
      table_contact c,
      table_part_inst pi,
      table_web_user wu
    WHERE pi.part_serial_no             = ip_esn
    AND pi.objid                        = cpi.x_contact_part_inst2part_inst
    AND cpi.x_contact_part_inst2contact = c.objid
    AND c.objid                         = wu.web_user2contact
    AND wu.web_user2bus_org            IN
      (SELECT OBJID FROM table_bus_org WHERE org_id = ip_bus_org_id
      );

  CURSOR c_get_account_group
  IS
    SELECT account_group_id
    FROM x_account_group_member
    WHERE esn          = ip_esn
    AND UPPER(status) <> 'EXPIRED';

  l_pending_stage_count NUMBER;

BEGIN

  -- Validate if ESN parameter was passed
  IF ip_esn IS NULL THEN
    -- Return error message (2)
    op_err_code := 2;
    op_err_msg  := 'ESN cannot be blank.';
    -- Exit the program whenever an error occurs
    RETURN;
  END IF;

  OPEN c_get_account_group;
  FETCH c_get_account_group INTO op_account_group_id;
  CLOSE c_get_account_group;
  -- Find the Web User Objid and Email
  OPEN c_get_account_info;
  FETCH c_get_account_info INTO op_email, op_web_user_objid;
  IF c_get_account_info%NOTFOUND THEN
    -- Return error message (4)
    op_err_code := 4;
    op_err_msg  := 'Account information was not found for the provided ESN.';
    -- Exit the program whenever an error occured
    RETURN;
  END IF;

  CLOSE c_get_account_info;
  -- Count the number of rows in staging in (PAYMENT_PENDING,QUEUED,PROCESSING,TO_QUEUE) status
  SELECT COUNT(1)
  INTO l_pending_stage_count
  FROM x_service_order_stage
  WHERE esn   = ip_esn
  AND status IN ('PAYMENT_PENDING','QUEUED','PROCESSING','TO_QUEUE');

  -- If there are any pending rows in staging
  IF l_pending_stage_count > 0 THEN
    -- Return code and message (3) as error
    op_err_code := 3;
    op_err_msg  := 'There are (' || l_pending_stage_count || ') pending stage records.';
    -- Exit the program
    RETURN;
    --
  END IF;

  -- Return code and message (0) as success
  op_err_code := 0;
  op_err_msg  := 'Success';

EXCEPTION
  WHEN OTHERS THEN
    -- Log error message
    log_error( ip_error_text => 'SQLERRM: ' || SQLERRM, ip_error_date => SYSDATE, ip_action => 'exception when others clause for ip_esn = ' || ip_esn || ' , ip_bus_org_id = ' || ip_bus_org_id, ip_key => ip_esn, ip_program_name => 'brand_x_pkg.get_account_info');
    op_err_code := 1;
    op_err_msg  := 'Unhandled exception : ' || SQLERRM;
    RAISE;
END get_account_info;
--
--
-- Added on 11/06/2014 by Juda Pena to determine the group name
PROCEDURE get_default_group_name (ip_web_user_objid      IN  NUMBER,
                                  op_account_group_name  OUT VARCHAR2)
AS
  l_count_groups NUMBER := 0;
BEGIN

  -- Get the distinct groups that belong to the web user objid
  SELECT NVL(COUNT(DISTINCT account_group_id),0) + 1
  INTO l_count_groups
  FROM x_account_group_member agm
  WHERE esn IN
    (SELECT pi.part_serial_no esn
    FROM table_x_contact_part_inst cpi,
      table_contact c,
      table_part_inst pi,
      table_web_user wu
    WHERE wu.objid          = ip_web_user_objid
    AND wu.web_user2contact = c.objid
    AND c.objid             = cpi.x_contact_part_inst2contact
    AND pi.objid            = cpi.x_contact_part_inst2part_inst
    );

  -- Generate group name based on the previous count of distinct groups
  op_account_group_name := 'GROUP ' || TO_CHAR(NVL(l_count_groups,1));

EXCEPTION
  WHEN OTHERS THEN
    op_account_group_name := 'GROUP 1';
END get_default_group_name;
--
--
-- Function was added on 12/09/2014 by Juda Pena to get the master esn of the group
FUNCTION get_master_esn (ip_account_group_id IN NUMBER) RETURN VARCHAR2
IS

  l_master_esn              VARCHAR2(30) := NULL;
  l_account_group_member_id NUMBER(22);
  l_err_code                NUMBER;
  l_err_msg                 VARCHAR2(1000);

BEGIN

  IF ip_account_group_id IS NOT NULL THEN
    -- Call the stored procedure to retrieve the master esn
    get_master_esn (ip_account_group_id => ip_account_group_id,
                    ip_esn => NULL,
                    op_master_esn => l_master_esn,
                    op_account_group_member_id => l_account_group_member_id,
                    op_err_code => l_err_code,
                    op_err_msg => l_err_msg);
  END IF;
  --
  RETURN(l_master_esn);

EXCEPTION
  WHEN OTHERS THEN
    RETURN(NULL);
END get_master_esn;
--
--
-- Added on 11/06/2014 by Juda Pena to get the master esn of the group
PROCEDURE get_master_esn (ip_account_group_id        IN  NUMBER,
                          ip_esn                     IN  VARCHAR2,
                          op_master_esn              OUT VARCHAR2,
                          op_account_group_member_id OUT NUMBER,
                          op_err_code                OUT NUMBER,
                          op_err_msg                 OUT VARCHAR2)
AS

  CURSOR c_get_master_esn_by_esn
  IS
    SELECT esn,
           objid account_group_member_id
    FROM   sa.x_account_group_member
    WHERE  account_group_id IN(SELECT account_group_id
                                 FROM sa.x_account_group_member
                                WHERE esn = ip_esn
                                  AND UPPER(status) <> 'EXPIRED')
    AND    master_flag = 'Y'
    AND    UPPER(status) <> 'EXPIRED'; -- Active members

  CURSOR c_get_master_esn_by_group
  IS
    SELECT esn,
           objid account_group_member_id
    FROM   sa.x_account_group_member
    WHERE  account_group_id = ip_account_group_id
    AND    master_flag = 'Y'
    AND    UPPER(status) <> 'EXPIRED'; -- Active members

  CURSOR c_get_member_info
  IS
    SELECT account_group_id
    FROM   sa.x_account_group_member
    WHERE  esn = ip_esn
    ORDER BY objid desc;

  -- CR43726  06/24/2016 PMistry Modify the code to get the account group id and pass for selecting next master if it's not passed.
  l_account_group_id     NUMBER;

BEGIN

  IF ip_esn IS NOT NULL THEN
    --
    OPEN c_get_master_esn_by_esn;
    FETCH c_get_master_esn_by_esn
     INTO op_master_esn,
          op_account_group_member_id;
    CLOSE c_get_master_esn_by_esn;
    --
  ELSIF ip_account_group_id IS NOT NULL THEN
    --
    OPEN c_get_master_esn_by_group;
    FETCH c_get_master_esn_by_group
     INTO op_master_esn,
          op_account_group_member_id;
    CLOSE c_get_master_esn_by_group;
    --
  ELSIF ip_account_group_id IS NULL AND ip_esn IS NULL THEN
    --
    op_err_code := 1;
    op_err_msg  := 'Parameter group id or ESN is required';
    --
    RETURN;
    --
  END IF;

  -- CR37756 Start PMistry 03/08/2016 Get the next esn and make it master if no esn is flaged as master.
  -- Get next ESN to flag it as Master
  -- CR43726 06/24/2016 PMistry Modify the code to get the account group id and pass for selecting next master if it's not passed.
  IF op_master_esn IS NULL THEN

    OPEN c_get_member_info;
    FETCH c_get_member_info INTO l_account_group_id;
    CLOSE c_get_member_info;

    op_master_esn := select_next_master_esn (ip_account_group_id => NVL(ip_account_group_id, l_account_group_id),
                                             ip_old_master_esn   => NULL);

    -- Set the next esn as Master if there is no master esn with the group.
    set_account_group_master (ip_account_group_id => ip_account_group_id,
                              ip_esn              => op_master_esn,
                              op_err_code         => op_err_code,
                              op_err_msg          => op_err_msg);

    IF op_err_code <> 0 THEN
      RETURN;
    END IF;

  END IF;

  -- CR37756 End PMistry 03/08/2016
  -- Return code and message (0) as success
  op_err_code := 0;
  op_err_msg  := 'Success';

EXCEPTION
  WHEN OTHERS THEN
    -- Log error message
    log_error( ip_error_text => 'SQLERRM: ' || SQLERRM, ip_error_date => SYSDATE, ip_action => 'exception when others clause for account_group_id = ' || ip_account_group_id || ', esn = ' || ip_esn, ip_key => ip_esn, ip_program_name => 'brand_x_pkg.get_master_esn');
    op_err_code := 1;
    op_err_msg  := 'Unhandled exception : ' || SQLERRM;
    RAISE;
END get_master_esn;
--
--
-- Added on 12/05/2014 by Juda Pena to get the feature value based on a given service plan and feature name
FUNCTION get_feature_value (ip_service_plan_id IN  NUMBER,
                            ip_fea_name        IN  VARCHAR2) RETURN VARCHAR2
IS
  -- Get feature value based on service plan and feature name
  CURSOR c_get_feature_value
  IS
    SELECT fea_value
    FROM adfcrm_serv_plan_feat_matview
    WHERE sp_objid = ip_service_plan_id
    AND fea_name   = ip_fea_name;

  feature_value_rec c_get_feature_value%ROWTYPE;

BEGIN

  -- Get feature value based on service plan and feature name
  OPEN c_get_feature_value;
  FETCH c_get_feature_value INTO feature_value_rec;
  CLOSE c_get_feature_value;

  -- Return the feature value
  RETURN(feature_value_rec.fea_value);

EXCEPTION
  WHEN OTHERS THEN
    RETURN(NULL);
END get_feature_value;
--
--
-- Added on 11/19/2014 by Juda Pena to get the feature value based on a given part number
FUNCTION get_part_num_fea_value (ip_part_number IN VARCHAR2,
                                 ip_fea_name    IN VARCHAR2) RETURN VARCHAR2
IS
  --
  CURSOR c_get_feature_value
  IS
    SELECT fea_value
    FROM adfcrm_serv_plan_feat_matview
    WHERE sp_objid IN
      (SELECT sp_objid
      FROM adfcrm_serv_plan_class_matview
      WHERE part_class_objid IN
        (SELECT part_num2part_class
        FROM table_part_num
        WHERE part_number = ip_part_number
        )
      )
    AND fea_name = ip_fea_name;

    feature_value_rec c_get_feature_value%ROWTYPE;

BEGIN

    IF ip_part_number IS NOT NULL AND ip_fea_name IS NOT NULL THEN
      OPEN c_get_feature_value;
      FETCH c_get_feature_value INTO feature_value_rec;
      CLOSE c_get_feature_value;
    END IF;

    -- Return the feature value
    RETURN(feature_value_rec.fea_value);

EXCEPTION
  WHEN OTHERS THEN
    RETURN(NULL);
END get_part_num_fea_value;
--
--
FUNCTION get_number_of_lines (ip_service_plan_id IN NUMBER) RETURN NUMBER
IS
  --
  CURSOR c_get_feature_value
  IS
    SELECT TO_NUMBER(fea_value) fea_value
    FROM adfcrm_serv_plan_feat_matview
    WHERE sp_objid = ip_service_plan_id
    AND fea_name   = 'NUMBER_OF_LINES';

  feature_value_rec c_get_feature_value%ROWTYPE;

BEGIN
  --
  OPEN c_get_feature_value;
  FETCH c_get_feature_value INTO feature_value_rec;
  CLOSE c_get_feature_value;
  -- Return the feature value
  RETURN(feature_value_rec.fea_value);

EXCEPTION
  WHEN OTHERS THEN
    RETURN(1);
END get_number_of_lines;
--
--
-- Added on 11/26/2014 by Juda Pena to determine if the brand allows shared groups
FUNCTION get_shared_group_flag (ip_bus_org_id IN VARCHAR2) RETURN VARCHAR2
IS
  cust sa.customer_type;
BEGIN
  --
  -- CR37756 PMistry 03/04/2016 replace the hardcoded value with Customer_Type function.
  --Instantiate Customer Type
  cust := customer_type();
  --
  return(cust.get_shared_group_flag (i_bus_org_id => ip_bus_org_id));

EXCEPTION
  WHEN OTHERS THEN
    -- Return as N (No) whenever an error occurs
    RETURN('N');
END get_shared_group_flag;
--
--
-- Added on 11/19/2014 by Juda Pena to get a valid esn + service plan for a given red card code
PROCEDURE get_red_card_esn_sp (ip_red_card_code    IN  VARCHAR2,
                               op_esn              OUT VARCHAR2,
                               op_service_plan_id  OUT NUMBER)
IS
  -- Get the part classes related to the given pin
  CURSOR c_get_part_class_id
  IS
    SELECT d.part_class_id,
      sp.objid service_plan_id
    FROM sa.x_serviceplanfeaturevalue_def a,
      sa.mtm_partclass_x_spf_value_def b,
      sa.x_serviceplanfeaturevalue_def c,
      sa.mtm_partclass_x_spf_value_def d,
      sa.x_serviceplanfeature_value spfv,
      sa.x_service_plan_feature spf,
      sa.x_service_plan sp
    WHERE a.objid        = b.spfeaturevalue_def_id
    AND b.part_class_id IN
      (SELECT pn.part_num2part_class
      FROM table_part_inst rc,
        table_mod_level ml,
        table_part_num pn
      WHERE 1           = 1
      AND rc.x_red_code = ip_red_card_code
      AND ml.objid      = rc.n_part_inst2part_mod
      AND pn.objid      = ml.part_info2part_num
    ---- Start added by Rahul for CR33569 on Jul142015
    UNION
    SELECT pn.part_num2part_class
    FROM table_x_red_card rc,
      table_mod_level ml,
      table_part_num pn
    WHERE 1           = 1
    AND rc.x_red_code = ip_red_card_code
    AND ml.objid      = rc.x_red_card2part_mod
    AND pn.objid      = ml.part_info2part_num
      ---- End added by Rahul for CR33569 on Jul142015
      )
    AND c.objid        = d.spfeaturevalue_def_id
    AND a.value_name   = c.value_name
    AND spfv.value_ref = a.objid
    AND spf.objid      = spfv.spf_value2spf
    AND sp.objid       = spf.sp_feature2service_plan;

    -- Get the available ESNs based on a given part class
    CURSOR c_get_esn (p_part_class IN NUMBER)
    IS
      SELECT pi.part_serial_no,
        pi.x_red_code,
        pi.x_domain,
        pn.part_num2part_class,
        pi.x_part_inst_status
      FROM table_part_num pn,
        table_mod_level ml,
        table_part_inst pi
      WHERE 1                    = 1
      AND pn.part_num2part_class = p_part_class
      AND pn.domain = 'PHONES'
      AND ml.part_info2part_num   = pn.objid
      AND pi.n_part_inst2part_mod = ml.objid
      AND pi.x_part_inst_status   = '50'
      AND NOT EXISTS (SELECT 1
                       FROM   x_account_group_member
                       WHERE  esn = pi.part_serial_no);

BEGIN

  -- CR41658 for already redeemed pin
  BEGIN

 SELECT pi.part_serial_no,svp.objid
 INTO op_esn,op_service_plan_id
 FROM table_x_call_trans ct,
 table_x_red_card rc,
 table_part_inst pi,
 table_part_num pn,
 table_site_part sp,
 table_mod_level ml
 ,x_service_plan_site_part spsp
 ,x_service_plan svp
 WHERE     1 = 1
 AND ml.objid = rc.x_red_card2part_mod
 AND rc.red_card2call_trans = ct.objid
 AND ct.x_service_id = pi.part_serial_no
 AND pn.objid = ml.part_info2part_num
 AND rc.x_red_code = ip_red_card_code
 AND pi.x_part_inst2site_part = sp.objid
 --AND sp.PART_STATUS='Active'
 --AND sp.x_expire_dt >= SYSDATE
 --AND ct.x_new_due_date >= SYSDATE
 AND spsp.x_service_plan_id = svp.objid
 and spsp.table_site_part_id = sp.objid
 AND ROWNUM = 1;
      EXCEPTION WHEN OTHERS
      THEN

 NULL;

      END;

      IF  op_esn IS NOT NULL
      THEN
 RETURN;
      END IF;
 -- CR41658 for already redeemed pin

    -- Loop through the part classes related to the provided pin
    FOR i IN c_get_part_class_id LOOP

      -- Loop through ALL the available ESNs based on a given part class
      FOR j IN c_get_esn (i.part_class_id) LOOP

        IF j.part_serial_no IS NOT NULL --Added by Rahul for CR33569 on Jul142015
          THEN
          op_esn             := j.part_serial_no;
          op_service_plan_id := i.service_plan_id;
          -- Return the first dummy ESN found to the calling program
          RETURN;
        END IF;

      END LOOP; -- j

    END LOOP;   -- i

EXCEPTION
  WHEN OTHERS THEN
    -- Log error message
    log_error( ip_error_text => 'SQLERRM: ' || SQLERRM, ip_error_date => SYSDATE, ip_action => 'exception when others clause for ip_red_card_code = ' || ip_red_card_code, ip_key => ip_red_card_code, ip_program_name => 'brand_x_pkg.get_red_card_esn_sp');
    -- Return a blank ESN if any errors occurred
    op_esn             := NULL;
    op_service_plan_id := NULL;
END get_red_card_esn_sp;
--
--
-- Added on 12/16/2014 by Juda Pena to check if the redemption of the plan is feasible
PROCEDURE redeem_plan_group_feasible (ip_account_group_id     IN  NUMBER,
                                      ip_esn                  IN  VARCHAR2,
                                      ip_redeem_now_flag      IN  VARCHAR2,
                                      ip_new_service_plan_id  IN  NUMBER,
                                      op_err_code             OUT NUMBER,
                                      op_err_msg              OUT VARCHAR2)
AS
  -- Get all members part of the group the provided esn belongs to
  CURSOR c_get_active_members
  IS
    SELECT *
    FROM x_account_group_member
    WHERE account_group_id IN
      (SELECT account_group_id
      FROM x_account_group_member
      WHERE esn          = ip_esn
      AND UPPER(status) <> 'EXPIRED'
      )
  AND UPPER(status)           <> 'EXPIRED';

  l_available_capacity NUMBER := 0;
  l_number_of_lines    NUMBER;

BEGIN

  -- 1. Validation: For all ESNs part of the group. If any ESN fails the compatibility the complete validation fails
  -- Get all the active members of a group
  FOR i IN c_get_active_members LOOP
    -- Validate provided service plan and esn compatibility
    IF valid_service_plan_esn ( ip_service_plan_id => ip_new_service_plan_id, ip_esn => i.esn ) = 'N' -- NOT VALID
      THEN
      -- Overwrite message with service plan incompatibility
      op_err_code := 2;
      op_err_msg  := 'esn ( ' || i.esn || ' ) is not compatible with the provided service plan ( ' || ip_new_service_plan_id || ' )';
      -- Exit the program
      RETURN;
    END IF;
  END LOOP;

  -- Validate the total count of active ESNs in the group cannot be greater than the number of lines allowed by the provided PIN's service plan/number of lines.
  IF valid_number_of_lines ( ip_esn => ip_esn, ip_service_plan_id => ip_new_service_plan_id, op_available_capacity => l_available_capacity, op_number_of_lines => l_number_of_lines) = 'N' THEN
    -- Overwrite message with service plan incompatibility
    op_err_code := 3;
    op_err_msg  := 'NUMBER OF ACTIVE ESNS IN THE GROUP IS GREATER THAN THE NUMBER OF LINES ALLOWED FOR THE SERVICE PLAN';
    -- Exit the program
    RETURN;
  END IF;

  -- Validate if any of the active members of a group has a card in queue and the queued pin service plan/number of lines does not match the passed red card service plan/number of lines
  IF valid_queued_red_cards ( ip_esn => ip_esn, ip_service_plan_id => ip_new_service_plan_id ) = 'N' -- AND
    -- Validation should occur only for NON Add-On Data Dards (since Add-Ons are a real service plan)
    --NVL( get_feature_value ( ip_service_plan_id => ip_new_service_plan_id,
    --                         ip_fea_name        => 'SERVICE_PLAN_GROUP'),'**') <> 'ADD_ON_DATA'
    THEN
    -- Overwrite message with service plan incompatibility
    op_err_code := 4;
    op_err_msg  := 'QUEUED PIN SERVICE PLAN/NUMBER OF LINES DOES NOT MATCH THE PROVIDED PIN SERVICE PLAN/NUMBER OF LINES';
    -- Exit the program
    RETURN;
  END IF;
  --
  op_err_code := 0;
  op_err_msg  := 'Success';

EXCEPTION
  WHEN OTHERS THEN
    -- Log error message
    log_error( ip_error_text => 'SQLERRM: ' || SQLERRM, ip_error_date => SYSDATE, ip_action => 'exception when others clause for ip_account_group_id = ' || ip_account_group_id || ' , ip_esn = ' || ip_esn, ip_key => ip_account_group_id, ip_program_name => 'brand_x_pkg.redeem_plan_group_feasible');
    op_err_code := 1;
    op_err_msg  := 'Unhandled exception : ' || SQLERRM;
    RAISE;
END redeem_plan_group_feasible;
--
--
-- Added on 11/20/2014 by Juda Pena to wrap the validate esn and service plan for brand x groups
PROCEDURE validate_esn_sp_rules (ip_esn                    IN  VARCHAR2,
                                 ip_service_plan_id        IN  NUMBER,
                                 ip_bus_org_id             IN  VARCHAR2,
                                 op_esn_sp_validation_tab  OUT esn_sp_validation_tab,
                                 op_err_code               OUT NUMBER,
                                 op_err_msg                OUT VARCHAR2)
AS

  -- Get all members part of the group the provided esn belongs to
  CURSOR c_get_active_members IS
    SELECT *
    FROM   x_account_group_member
    WHERE  account_group_id IN ( SELECT account_group_id
                                 FROM   x_account_group_member
                                 WHERE  esn = ip_esn
                                 AND    UPPER(status) <> 'EXPIRED'
                               )
    AND    UPPER(status) <> 'EXPIRED';

  -- Record to hold the input cursor from VALIDATE_RED_CARD_PKG.main
  TYPE t_row IS RECORD
  (
    msgnum                   VARCHAR2(1000),
    msgstr                   VARCHAR2(1000),
    available_capacity       NUMBER(2),
    number_of_lines          NUMBER(3),
    payment_pending_group_id NUMBER(22),
    program_enrolled_id      NUMBER(22)
  );

  l_rec                          t_row;
  l_refcursor                    sys_refcursor;
  group_rec                      x_account_group%ROWTYPE;
  l_incompatible_enrollment_flag VARCHAR2(1);
  l_program_enroll_id            NUMBER;        -- CR43726 06/24/2016 PMistry Fix for Enrollment mismatch issue between original enrollment and group enrollment
  l_grp_program_param_id         NUMBER;
  l_sp_program_param_id          NUMBER;
BEGIN
  -- Set the member available capacity to 0 (used to determine how many members can be added to a group based on a given service plan)
  l_rec.available_capacity := 0;
  l_rec.msgnum             := '0';
  l_rec.msgstr             := ' ';

  -- Validate service plan and ESN compatibility
  IF valid_service_plan_esn ( ip_service_plan_id => ip_service_plan_id,
                              ip_esn             => ip_esn) = 'N'
  THEN
    l_rec.msgnum := '1591';
    l_rec.msgstr := 'ESN IS NOT COMPATIBLE WITH THE SERVICE PLAN';
    -- Transfer control to the <<procedure_end>> block (to exit the program)
    GOTO procedure_end;
  END IF;
  -- Only for shared group plan validations (when an esn was provided)
  IF ( get_shared_group_flag ( ip_bus_org_id => ip_bus_org_id) = 'Y' )
  THEN
    -- 1. Validation: For all ESNs part of the group. If any ESN fails the compatibility the complete validation fails
    -- Get all the active members of a group
    FOR i IN c_get_active_members
    LOOP
      -- Validate group service plan and esn compatibility
      IF valid_service_plan_group ( ip_account_group_id => i.account_group_id, ip_esn => i.esn) = 'N' THEN
        -- Overwrite message with service plan incompatibility
        l_rec.msgnum := '1591';
        l_rec.msgstr := 'ESN IS NOT COMPATIBLE WITH THE SERVICE PLAN';
        -- Transfer control to the <<procedure_end>> block (to exit the program)
        GOTO procedure_end;
      END IF;
    END LOOP;
    -- 2. Validation: The total count of active ESNs in the group cannot be greater than the number of lines allowed by the
    --                provided PIN's service plan/number of lines.
    IF valid_number_of_lines ( ip_esn => ip_esn, ip_service_plan_id => ip_service_plan_id, op_available_capacity => l_rec.available_capacity, op_number_of_lines => l_rec.number_of_lines) = 'N' AND NVL(get_feature_value ( ip_service_plan_id => ip_service_plan_id, ip_fea_name => 'SERVICE_PLAN_GROUP'),'**') NOT IN ( 'ADD_ON_DATA','ADD_ON_ILD') THEN --CR44729 added 'ADD_ON_ILD'
      -- Overwrite message with service plan incompatibility
      l_rec.msgnum := '1592';
      l_rec.msgstr := 'NUMBER OF ACTIVE ESNS IN THE GROUP IS GREATER THAN THE NUMBER OF LINES ALLOWED FOR THE SERVICE PLAN';
      -- Transfer control to the <<procedure_end>> block (to exit the program)
      GOTO procedure_end;
    END IF;
    --
    -- 3. Validation: If any of the active members of a group has a card in queue and the queued pin service plan/number of lines does not match the passed red card service plan/number of lines
    IF valid_queued_red_cards ( ip_esn => ip_esn, ip_service_plan_id => ip_service_plan_id ) = 'N' AND NVL(get_feature_value ( ip_service_plan_id => ip_service_plan_id, ip_fea_name => 'SERVICE_PLAN_GROUP'),'**') NOT IN ( 'ADD_ON_DATA','ADD_ON_ILD') THEN --CR44729 added 'ADD_ON_ILD'
      -- Overwrite message with service plan incompatibility
      l_rec.msgnum := '1593';
      l_rec.msgstr := 'QUEUED PIN SERVICE PLAN/NUMBER OF LINES DOES NOT MATCH THE PROVIDED PIN SERVICE PLAN/NUMBER OF LINES';
      -- Set this flag to return the program enrolled id when there is any incompatibility
      l_incompatible_enrollment_flag := 'Y';
      -- Transfer control to the <<procedure_end>> block (to exit the program)
      GOTO procedure_end;
    END IF;
  END IF;

  -- goto end block
  << procedure_end >>

  -- get the account group information
  group_rec := get_group_rec( ip_esn => ip_esn );

  --
  IF group_rec.program_enrolled_id IS NOT NULL AND
     NVL(l_incompatible_enrollment_flag,'N') = 'N'
  THEN

    -- Get the program parameter id tied to the group
    BEGIN
      SELECT pgm_enroll2pgm_parameter,
             objid
      INTO   l_grp_program_param_id,                   -- CR43726 06/24/2016 PMistry Fix for Enrollment mismatch issue between original enrollment and group enrollment
             l_program_enroll_id
      FROM   x_program_enrolled
      WHERE  objid = group_rec.program_enrolled_id
      AND    x_enrollment_status IN ('ENROLLED','ENROLLMENTPENDING');
     EXCEPTION
       WHEN OTHERS THEN
         l_grp_program_param_id := NULL;
         l_program_enroll_id    := NULL;                                   -- CR43726 06/24/2016 PMistry Fix for Enrollment mismatch issue between original enrollment and group enrollment
    END;

    -- Get the program parameter id for a given service plan
    BEGIN
      SELECT x_sp2program_param
      INTO   l_sp_program_param_id
      FROM   mtm_sp_x_program_param
      WHERE  program_para2x_sp = ip_service_plan_id
      AND    x_recurring = 1;
    EXCEPTION
    WHEN OTHERS THEN
      l_sp_program_param_id := NULL;
    END;

    -- Program enrollment validation
    --IF l_grp_program_param_id <> l_sp_program_param_id THEN    -- CR43726 06/24/2016 PMistry Fix for Enrollment mismatch issue between original enrollment and group enrollment
    --  -- Set incompatibility flag
    --  l_incompatible_enrollment_flag := 'Y';
    --END IF;
  END IF;

  -- If the account group (esn) no of lines is less than the service plan no of lines passed
  IF valid_number_of_lines ( ip_esn             => ip_esn ,
                             ip_service_plan_id => ip_service_plan_id ) = 'N' AND
     NVL(l_incompatible_enrollment_flag,'N') = 'N' -- not set previously
  THEN
    -- Set this flag to return the program enrolled id when there is any incompatibility
    l_incompatible_enrollment_flag := 'Y';
  END IF;

  -- Get the account group data to be return in the object table
  SELECT esn_sp_validation_type ( l_rec.msgnum ,
                                  l_rec.msgstr ,
                                  NVL( l_rec.available_capacity,0) ,
                                  l_rec.number_of_lines ,
                                  ip_service_plan_id ,
                                  get_esn_pmt_pending_acc_grp_id(ip_esn => ip_esn) , -- Determine if the esn has a PAYMENT_PENDING transaction in SOS
                                  (CASE WHEN l_incompatible_enrollment_flag = 'Y' THEN l_program_enroll_id ELSE NULL END)
                                 )
  BULK COLLECT
  INTO   op_esn_sp_validation_tab
  FROM   DUAL;
  --
  op_err_code := 0;
  op_err_msg  := 'Success';

EXCEPTION
  WHEN OTHERS THEN
    -- Log error message
    log_error ( ip_error_text => 'SQLERRM: ' || SQLERRM, ip_error_date => SYSDATE, ip_action => 'exception when others clause for ip_esn = ' || ip_esn || ' , ip_service_plan_id = ' || ip_service_plan_id || ' , ip_bus_org_id = ' || ip_bus_org_id, ip_key => ip_esn, ip_program_name => 'brand_x_pkg.validate_esn_sp_rules');
    op_err_code := 1;
    op_err_msg  := 'Unhandled exception : ' || SQLERRM;
    RAISE;
END validate_esn_sp_rules;
--
--
-- CR37756 - Overloading Procedure added on 03/28/2016 by sethiraj to accept list of service_plan
PROCEDURE validate_esn_sp_rules (ip_esn                   IN  VARCHAR2,
                                 ip_service_plan_id_list  IN  typ_number_array,
                                 ip_bus_org_id            IN  VARCHAR2,
                                 op_esn_sp_validation_tab OUT esn_sp_validation_tab,
                                 op_err_code              OUT NUMBER,
                                 op_err_msg               OUT VARCHAR2)
AS
  -- Get all members part of the group the provided esn belongs to
  CURSOR c_get_active_members
  IS
    SELECT *
    FROM x_account_group_member
    WHERE account_group_id IN
      (SELECT account_group_id
      FROM x_account_group_member
      WHERE esn          = ip_esn
      AND UPPER(status) <> 'EXPIRED'
      )
  AND UPPER(status) <> 'EXPIRED';

  -- Record to hold the input cursor from VALIDATE_RED_CARD_PKG.main
  TYPE t_row
  IS
  RECORD
  (
    msgnum                   VARCHAR2(1000),
    msgstr                   VARCHAR2(1000),
    available_capacity       NUMBER(2),
    number_of_lines          NUMBER(3),
    payment_pending_group_id NUMBER(22),
    program_enrolled_id      NUMBER(22)
  );

  l_refcursor sys_refcursor;
  l_rec t_row;
  group_rec x_account_group%ROWTYPE;
  l_incompatible_enrollment_flag VARCHAR2(1);
  l_grp_program_param_id         NUMBER;
  l_program_enroll_id            NUMBER;        -- CR43726 06/24/2016 PMistry Fix for Enrollment mismatch issue between original enrollment and group enrollment
  l_sp_program_param_id          NUMBER;
  l_tab_idx                      NUMBER;

BEGIN

  -- Initialize the type
  op_esn_sp_validation_tab := sa.esn_sp_validation_tab(esn_sp_validation_type(null,null,null,null,null,null,null));
  --
  FOR i IN 1 .. ip_service_plan_id_list.COUNT
  LOOP
    -- Set the member available capacity to 0 (used to determine how many members can be added to a group based on a given service plan)
    l_rec.available_capacity := 0;
    l_rec.msgnum             := '0';
    l_rec.msgstr             := ' ';
    -- Validate service plan and ESN compatibility
    IF sa.brand_x_pkg.valid_service_plan_esn ( ip_service_plan_id => ip_service_plan_id_list(i), ip_esn => ip_esn) = 'N' THEN
      l_rec.msgnum                                                                         := '1591';
      l_rec.msgstr                                                                         := 'ESN IS NOT COMPATIBLE WITH THE SERVICE PLAN';
      -- Transfer control to the <<procedure_end>> block (to exit the program)
      GOTO procedure_end;
    END IF;
    -- Perform shared group plan validations (when an esn was provided)
    IF ( sa.brand_x_pkg.get_shared_group_flag ( ip_bus_org_id => ip_bus_org_id) = 'Y' ) -- only for shared group brands
      THEN
      -- 1. Validation: For all ESNs part of the group. If any ESN fails the compatibility the complete validation fails
      -- Get all the active members of a group
      FOR i IN c_get_active_members
      LOOP
        -- Validate group service plan and esn compatibility
        IF sa.brand_x_pkg.valid_service_plan_group ( ip_account_group_id => i.account_group_id, ip_esn => i.esn) = 'N' THEN
          -- Overwrite message with service plan incompatibility
          l_rec.msgnum := '1591';
          l_rec.msgstr := 'ESN IS NOT COMPATIBLE WITH THE SERVICE PLAN';
          -- Transfer control to the <<procedure_end>> block (to exit the program)
          GOTO procedure_end;
        END IF;
      END LOOP;
      -- 2. Validation: The total count of active ESNs in the group cannot be greater than the number of lines allowed by the
      --                provided PIN's service plan/number of lines.
      IF sa.brand_x_pkg.valid_number_of_lines ( ip_esn => ip_esn, ip_service_plan_id => to_char(ip_service_plan_id_list(i))) = 'N' AND NVL(sa.brand_x_pkg.get_feature_value ( ip_service_plan_id => ip_service_plan_id_list(i), ip_fea_name => 'SERVICE_PLAN_GROUP'),'**') NOT IN ( 'ADD_ON_DATA','ADD_ON_ILD') THEN --CR44729 added 'ADD_ON_ILD'
        -- Overwrite message with service plan incompatibility
        l_rec.msgnum := '1592';
        l_rec.msgstr := 'NUMBER OF ACTIVE ESNS IN THE GROUP IS GREATER THAN THE NUMBER OF LINES ALLOWED FOR THE SERVICE PLAN';
        -- Transfer control to the <<procedure_end>> block (to exit the program)
        GOTO procedure_end;
      END IF;
      --
      -- 3. Validation: If any of the active members of a group has a card in queue and the queued pin service plan/number of lines does not match the passed red card service plan/number of lines
      IF valid_queued_red_cards ( ip_esn => ip_esn, ip_service_plan_id => to_char(ip_service_plan_id_list(i)) ) = 'N' AND NVL(get_feature_value ( ip_service_plan_id => ip_service_plan_id_list(i), ip_fea_name => 'SERVICE_PLAN_GROUP'),'**') NOT IN ( 'ADD_ON_DATA','ADD_ON_ILD') THEN --CR44729 added 'ADD_ON_ILD'
        -- Overwrite message with service plan incompatibility
        l_rec.msgnum := '1593';
        l_rec.msgstr := 'QUEUED PIN SERVICE PLAN/NUMBER OF LINES DOES NOT MATCH THE PROVIDED PIN SERVICE PLAN/NUMBER OF LINES';
        -- Set this flag to return the program enrolled id when there is any incompatibility
        l_incompatible_enrollment_flag := 'Y';
        -- Transfer control to the <<procedure_end>> block (to exit the program)
        GOTO procedure_end;
      END IF;
    END IF;
    -- GOTO end block
    << procedure_end >>
    -- Reopen the ref cursor for the calling programs and add the number of lines to the ref cursor.
    --OPEN op_refcursor
    --FOR
    --  SELECT l_rec.msgnum                       AS strmsgnum,
    --         l_rec.msgstr                       AS strmsgstr,
    --         l_rec.available_capacity           AS available_capacity,
    --         l_rec.number_of_lines              AS number_of_lines,
    --         ip_service_plan_id                 AS service_plan_id,
    --         l_rec.payment_pending_flag         AS payment_pending_flag,
    --         incompatible_sp_enrollment ( ip_esn => ip_esn, ip_service_plan_id => ip_service_plan_id ) AS incompatible_enrollment_flag
    --  FROM   DUAL;
    -- Get the account group information
    group_rec := brand_x_pkg.get_group_rec(ip_esn => ip_esn);
    --
    IF group_rec.program_enrolled_id IS NOT NULL AND NVL(l_incompatible_enrollment_flag,'N') = 'N' THEN
      -- Get the program parameter id tied  to the group
      BEGIN
        SELECT pgm_enroll2pgm_parameter, objid
        INTO l_grp_program_param_id, l_program_enroll_id                -- CR43726 06/24/2016 PMistry Fix for Enrollment mismatch issue between original enrollment and group enrollment
        FROM x_program_enrolled
        WHERE objid              = group_rec.program_enrolled_id
        AND x_enrollment_status IN ('ENROLLED','ENROLLMENTPENDING');
      EXCEPTION
      WHEN OTHERS THEN
        l_grp_program_param_id := NULL;
        l_program_enroll_id := null;                                    -- CR43726 06/24/2016 PMistry Fix for Enrollment mismatch issue between original enrollment and group enrollment
      END;
      -- Get the program parameter id for a given service plan
      BEGIN
        SELECT x_sp2program_param
        INTO l_sp_program_param_id
        FROM mtm_sp_x_program_param
        WHERE program_para2x_sp = ip_service_plan_id_list(i)
        AND x_recurring         = 1;
      EXCEPTION
      WHEN OTHERS THEN
        l_sp_program_param_id := NULL;
      END;

      -- Program enrollment validation
      --IF NVL(l_grp_program_param_id,-999999) <> NVL(l_sp_program_param_id,-999999) THEN
      -- CR45203 Commented as part of Fixes for incompatible enrollments for Simple Mobile.
      --IF l_grp_program_param_id <> l_sp_program_param_id THEN                                 -- CR43726 06/24/2016 PMistry Fix for Enrollment mismatch issue between original enrollment and group enrollment
      --  -- Set incompatibility flag
      --  l_incompatible_enrollment_flag := 'Y';
      --END IF;
    END IF;

    -- If the account group (esn) no of lines is less than the service plan no of lines passed
    IF brand_x_pkg.valid_number_of_lines ( ip_esn => ip_esn , ip_service_plan_id => ip_service_plan_id_list(i) ) = 'N' AND NVL(l_incompatible_enrollment_flag,'N') = 'N' -- Not set previously
      THEN
      -- Set this flag to return the program enrolled id when there is any incompatibility
      l_incompatible_enrollment_flag := 'Y';
    END IF;
    --
    op_esn_sp_validation_tab(op_esn_sp_validation_tab.count) := esn_sp_validation_type(l_rec.msgnum,
                                                                                       l_rec.msgstr,
                                                                                       NVL( l_rec.available_capacity,0),
                                                                                       l_rec.number_of_lines,
                                                                                       ip_service_plan_id_list(i),
                                                                                       brand_x_pkg.get_esn_pmt_pending_acc_grp_id(ip_esn => ip_esn),
                                                                                       (CASE WHEN l_incompatible_enrollment_flag= 'Y' THEN l_program_enroll_id ELSE NULL END));   -- CR43726 06/24/2016 PMistry Fix for Enrollment mismatch issue between original enrollment and group enrollment
    IF i < ip_service_plan_id_list.COUNT THEN
      op_esn_sp_validation_tab.extend(1);
      --op_esn_sp_validation_tab := sa.esn_sp_validation_tab(esn_sp_validation_type(null,null,null,null,null,null,null));
    END IF;
    /*
    -- Get the account group data to be return in the object table
    SELECT esn_sp_validation_type ( l_rec.msgnum , l_rec.msgstr , NVL( l_rec.available_capacity,0) , l_rec.number_of_lines , ip_service_plan_id , get_esn_pmt_pending_acc_grp_id(ip_esn => ip_esn) , -- Determine if the esn has a PAYMENT_PENDING transaction in SOS
      DECODE(l_incompatible_enrollment_flag, 'Y', group_rec.program_enrolled_id, NULL)                                                                                                               -- Return the program enrolled id only when there is any incompatibility
      ) BULK COLLECT
    INTO op_esn_sp_validation_tab
    FROM DUAL;
    */
  END LOOP;

  op_err_code := 0;
  op_err_msg  := 'Success';

EXCEPTION
  WHEN OTHERS THEN
    -- Log error message
    --log_error( ip_error_text => 'SQLERRM: ' || SQLERRM, ip_error_date => SYSDATE, ip_action => 'exception when others clause for ip_esn = ' || ip_esn || ' , ip_service_plan_id = ' || ip_service_plan_id || ' , ip_bus_org_id = ' || ip_bus_org_id, ip_key => ip_esn, ip_program_name => 'brand_x_pkg.validate_esn_sp_rules');
  brand_x_pkg.log_error( ip_error_text => 'SQLERRM: ' || SQLERRM, ip_error_date => SYSDATE, ip_action => 'exception when others clause for ip_esn = ' || ip_esn || ' , ip_bus_org_id = ' || ip_bus_org_id, ip_key => ip_esn, ip_program_name => 'brand_x_pkg.validate_esn_sp_rules');
    op_err_code := 1;
    op_err_msg  := 'Unhandled exception : ' || SQLERRM;
    RAISE;
END validate_esn_sp_rules;
--
--
-- Added on 11/20/2014 by Juda Pena to wrap the validate_red_card_pkg.main and add more features for brand x groups
PROCEDURE validate_red_card_sp (ip_red_card_code      IN      VARCHAR2,
                                ip_smpnumber          IN      VARCHAR2,
                                ip_source_system      IN      VARCHAR2,
                                iop_esn               IN OUT  VARCHAR2,
                                ip_bus_org_id         IN      VARCHAR2,
                                ip_client_id          IN      VARCHAR2,
                                op_available_capacity OUT     NUMBER,
                                op_refcursor          OUT     SYS_REFCURSOR,
                                op_err_code           OUT     NUMBER,
                                op_err_msg            OUT     VARCHAR2)
AS

  -- Get all members part of the group the provided esn belongs to
  CURSOR c_get_active_members IS
    SELECT *
    FROM   x_account_group_member
    WHERE  account_group_id IN ( SELECT account_group_id
                                 FROM   x_account_group_member
                                 WHERE  esn = iop_esn
                                 AND    UPPER(status) <> 'EXPIRED'
                               )
    AND    UPPER(status) <> 'EXPIRED';

  -- Find the brand for the provided pin
  CURSOR c_get_red_card_brand IS
    SELECT bo.org_id bus_org_id, pn.part_number
    FROM   table_part_inst pi,
           table_mod_level ml,
           table_part_num pn,
           table_bus_org bo
    WHERE  1 = 1
    AND    pi.x_red_code           = ip_red_card_code
    AND    pi.x_domain             = 'REDEMPTION CARDS'
    AND    pi.n_part_inst2part_mod = ml.objid
    AND    ml.part_info2part_num   = pn.objid
    AND    pn.domain               = 'REDEMPTION CARDS'
    AND    pn.part_num2bus_org     = bo.objid
    ---- Start added by Rahul for CR33569 on Jun292015
    UNION
    SELECT bo.org_id, pn.part_number
    FROM   table_x_red_card rc ,
           table_mod_level ml ,
           table_part_num pn ,
           table_bus_org bo
    WHERE  rc.x_red_code       = ip_red_card_code
    AND    pn.domain             = 'REDEMPTION CARDS'
    AND    ml.objid              = rc.x_red_card2part_mod
    AND    ml.part_info2part_num = pn.objid
    AND    pn.part_num2bus_org   = bo.objid;
    ---- End added by Rahul for CR33569 on Jun292015

  red_card_brand_rec c_get_red_card_brand%ROWTYPE;

  -- Record to hold the input ref cursor from validate_red_card_pkg.main
  TYPE t_row IS RECORD
  ( status             VARCHAR2(1000),
    units              NUMBER,
    days               NUMBER,
    cardbrand          VARCHAR2(20),
    msgnum             VARCHAR2(1000),
    msgstr             VARCHAR2(1000),
    errorpin           VARCHAR2(1000),
    description        VARCHAR2(255),
    partnumber         VARCHAR2(30),
    cardtype           VARCHAR2(20),
    parttype           VARCHAR2(20),
    x_web_card_desc    VARCHAR2(100),
    x_sp_web_card_desc VARCHAR2(100),
    x_ild_type         NUMBER );

  l_refcursor sys_refcursor;
  l_rec t_row;
  l_number_of_lines    NUMBER;
  l_dummy_esn_flag     VARCHAR2(1) := 'N';
  l_service_plan_id    NUMBER(22);
  l_rc_service_plan_id NUMBER(22);
  l_number_of_line_flag VARCHAR2(1);
  group_rec            x_account_group%ROWTYPE;
  l_redcard_service_plan_id NUMBER(22);

  -- instantiate initial values
  rc     sa.customer_type;

  -- type to hold retrieved customer attributes
  cst    sa.customer_type := customer_type();

  -- type to hold retrieved pin attributes
  cstp    sa.customer_type := customer_type();

  -- type to hold retrieved account group attributes
  cstg    sa.customer_type := customer_type();

  lv_number_of_lines NUMBER;  --CR41658

BEGIN

  -- Set the member available capacity to 0.
  -- This is used to determine how many members can be added to a group based on a given pin
  op_available_capacity := 0;

  --CR44729 - Get Sub brand
  rc            := customer_type ( i_esn => iop_esn );
  rc.sub_brand  := rc.get_sub_brand;

  -- If brand is using a shared group plan structure
  IF get_shared_group_flag ( ip_bus_org_id => ip_bus_org_id) = 'Y' THEN

 -- Validate red card brand vs passed brand parameter
    IF ip_red_card_code IS NOT NULL THEN
      -- Find the brand for the red card (pin)
      OPEN c_get_red_card_brand;
      FETCH c_get_red_card_brand INTO red_card_brand_rec;
      IF c_get_red_card_brand%NOTFOUND THEN
        CLOSE c_get_red_card_brand;
        -- Return output message
        l_rec.msgnum := '1648';
        l_rec.msgstr := 'PIN IS NOT FOUND';
        -- Transfer control to the <<procedure_end>> block (to exit the program)
        GOTO procedure_end;
      END IF;
      CLOSE c_get_red_card_brand;
      -- If the red card brand differs from the passed brand parameter
      IF red_card_brand_rec.bus_org_id <> ip_bus_org_id THEN
        -- Return output message
        l_rec.msgnum := '1647';
        l_rec.msgstr := red_card_brand_rec.bus_org_id || ' PIN IS NOT COMPATIBLE WITH THE PROVIDED BRAND (' || NVL(rc.sub_brand,ip_bus_org_id) || ') ';
        -- Transfer control to the <<procedure_end>> block (to exit the program)
        GOTO procedure_end;
      END IF;
    END IF;
    -- If an ESN is not passed
    IF iop_esn IS NULL THEN
      -- Pick a random dummy ESN when it is not provided
      --ip_esn := get_dummy_esn ( ip_red_card_code );
      -- Pick a random dummy ESN and SERVICE_PLAN_ID
      get_red_card_esn_sp ( ip_red_card_code => ip_red_card_code, op_esn => iop_esn, op_service_plan_id => l_service_plan_id);
      -- Set a flag to Y when a dummy ESN was randomly picked
      l_dummy_esn_flag := 'Y';
    END IF;

  END IF;

  -- Validate redemption card information (call existing procedure)
  validate_red_card_pkg.main (strredcard   => ip_red_card_code,
                              strsmpnumber => ip_smpnumber,
                              strsourcesys => ip_source_system,
                              stresn       => iop_esn,
                              po_refcursor => l_refcursor ); -- Output

  -- LOOP is not necessary since there is only one row returned as an output ref cursor
  -- Fetch the data from the open cursor to the temporary table record (l_rec)
  FETCH l_refcursor
  INTO  l_rec;

  -- CR37756 PMistry 04/18/2016 return the available capacity.
  l_number_of_line_flag := valid_number_of_lines (ip_esn                => iop_esn,
                                                  ip_red_card_code      => ip_red_card_code,
                                                  op_available_capacity => op_available_capacity );

  -- LOOP is not necessary since there is only one row returned as an output ref cursor
  -- END LOOP;
  -- Perform shared group plan validations (when an esn was provided)
  IF (l_rec.msgnum                                            = '0' ) AND -- When no errors were returned from the call to validate_red_card_pkg.main
     (get_shared_group_flag ( ip_bus_org_id => ip_bus_org_id) = 'Y' ) AND -- only for shared group brands
     (NVL(l_dummy_esn_flag,'N')                               = 'N' )     -- ESN was passed as an input parameter
    THEN

    -- 1. Validation: For all ESNs part of the group. If any ESN fails the compatibility the complete validation fails
    -- Get all the active members of a group
    -- Validate group service plan and esn compatibility
    -- Overwrite message with service plan incompatibility if 'N'
    -- If found N then transfer control to the <<procedure_end>> block (to exit the program)
    FOR i IN c_get_active_members LOOP
      IF valid_service_plan_group (ip_account_group_id => i.account_group_id, ip_esn => i.esn) = 'N' THEN
        l_rec.msgnum := '1591';
        l_rec.msgstr := 'ESN IS NOT COMPATIBLE WITH THE SERVICE PLAN';
        GOTO procedure_end;
      END IF;
    END LOOP;

    -- Get the redemption card service plan ID
    l_rc_service_plan_id := get_service_plan_id (f_esn      => iop_esn,
                                                 f_red_code => ip_red_card_code);

    --CR49786 Check if the PIN has been assigned value added service (VAS)//OImana//090517
    --        If true, no need to validate the ESN and PIN number of lines and queued service plan
    IF sa.VAS_MANAGEMENT_PKG.get_vas_service_id_by_pin (in_pin => ip_red_card_code) IS NULL THEN

      -- 2. Validation: The total count of active ESNs in the group cannot be greater than the number of lines allowed by the
      --                provided PIN's service plan/number of lines.
      --                Validation should occur only for NON Add-On Data Dards (since Add-Ons are a real service plan)
      --                Overwrite message with service plan incompatibility 1592
      --                Transfer control to the <<procedure_end>> block (to exit the program)
      IF valid_number_of_lines (ip_esn                => iop_esn,
                                ip_red_card_code      => ip_red_card_code,
                                op_available_capacity => op_available_capacity ) = 'N' AND
        NVL(get_feature_value (ip_service_plan_id     => l_rc_service_plan_id,
                               ip_fea_name            => 'SERVICE_PLAN_GROUP'),'**') NOT IN('ADD_ON_DATA','ADD_ON_ILD') --CR44729 added 'ADD_ON_ILD'
      THEN
        l_rec.msgnum := '1592';
        l_rec.msgstr := 'NUMBER OF ACTIVE ESNS IN THE GROUP IS GREATER THAN THE NUMBER OF LINES ALLOWED FOR THE PIN';
        GOTO procedure_end;
      END IF;
      --
      -- 3. Validation: If any of the active members of a group has a card in queue and the queued pin service plan/number of lines
      --                does not match the passed red card service plan/number of lines
      --                Validation should occur only for NON Add-On Data Dards (since Add-Ons are a real service plan)
      --                Overwrite message with service plan incompatibility
      --                Transfer control to the <<procedure_end>> block (to exit the program)
      IF valid_queued_red_cards (ip_esn             => iop_esn,
                                 ip_red_card_code   => ip_red_card_code ) = 'N' AND
         NVL(get_feature_value (ip_service_plan_id  => l_rc_service_plan_id,
                         ip_fea_name         => 'SERVICE_PLAN_GROUP'),'**') NOT IN('ADD_ON_DATA','ADD_ON_ILD') --CR44729 added 'ADD_ON_ILD'
      THEN
        l_rec.msgnum := '1593';
        l_rec.msgstr := 'QUEUED PIN SERVICE PLAN/NUMBER OF LINES DOES NOT MATCH THE PROVIDED PIN SERVICE PLAN/NUMBER OF LINES';
        GOTO procedure_end;
      END IF;

    END IF; --CR49786

  END IF;

  -- Start TW+ logic

  -- instantiate initial values
  rc := customer_type (i_esn => iop_esn);

  -- retrieve the esn information
  cst := rc.retrieve;

--CR44729 Begin - Added below piece of code to block activation of GO_SMART ESN with Add on ILD card
  l_redcard_service_plan_id := get_service_plan_id (f_esn      => iop_esn,
                                                    f_red_code => ip_red_card_code);

  IF NVL(get_number_of_lines (ip_service_plan_id => l_redcard_service_plan_id), 1) = 0 AND cst.esn_part_inst_status <> '52' AND
     NVL(get_feature_value   (ip_service_plan_id => l_redcard_service_plan_id,
                              ip_fea_name        => 'SERVICE_PLAN_GROUP'),'**')  IN( 'ADD_ON_ILD','ADD_ON_DATA') THEN  -- CR49087  WFM change ADD_ON_DATA
     -- Return output message
      l_rec.msgnum := '1654';
      l_rec.msgstr := 'PIN IS NOT COMPATIBLE FOR ACTIVATIONS';
      -- Transfer control to the <<procedure_end>> block (to exit the program)
      GOTO procedure_end;
  END IF;
----CR44729 END

  -- type to hold retrieved attributes
  rc := customer_type();

  -- call the retrieve method
  cstp := rc.retrieve_pin ( i_red_card_code => ip_red_card_code);

  -- call the retrieve method to group details
  cstg := rc.retrieve_group (i_account_group_objid  =>  cst.account_group_objid);

  -- Leased ESNs are not allowed to redeem a different pin
  IF ip_client_id IS NOT NULL THEN
    IF cst.service_plan_objid             != cstp.service_plan_objid AND
       UPPER(ip_client_id)                != 'SMARTPAYLEASE'         AND
       cstg.group_leased_flag             != 'N'                     AND
       NVL(cstp.service_plan_group,'ANY') NOT IN ( 'ADD_ON_DATA','ADD_ON_ILD') --CR44729 added 'ADD_ON_ILD'
    THEN
      --
      l_rec.msgnum := '1652';
      l_rec.msgstr := 'SERVICE PLAN CANNOT BE CHANGED FOR LEASED ESNS';
      --
      GOTO procedure_end;
    END IF;
  END IF;
  -- End TW+ logic


  -- GOTO end block
  << procedure_end >>

  -- Call function to return the x_account_group complete row based on the esn (member)
  group_rec := get_group_rec ( ip_esn => iop_esn );
  lv_number_of_lines := NVL( TO_NUMBER( get_part_num_fea_value ( nvl(l_rec.partnumber,red_card_brand_rec.part_number), 'NUMBER_OF_LINES') ), 1); --CR41658

  -- Reopen the ref cursor for the calling programs and add the number of lines to the ref cursor.
  OPEN op_refcursor
  FOR  SELECT l_rec.status                                AS strstatus,
              l_rec.units                                 AS intunits,
              l_rec.days                                  AS intdays,
              l_rec.cardbrand                             AS strcardbrand,
              l_rec.msgnum                                AS strmsgnum,
              l_rec.msgstr                                AS strmsgstr,
              l_rec.errorpin                              AS strerrorpin,
              l_rec.description                           AS description,
              l_rec.partnumber                            AS partnumber,
              l_rec.cardtype                              AS cardtype,
              l_rec.parttype                              AS parttype,
              l_rec.x_web_card_desc                       AS x_web_card_desc,
              l_rec.x_sp_web_card_desc                    AS x_sp_web_card_desc,
              l_rec.x_ild_type                            AS x_ild_type,
              --NVL( TO_NUMBER( get_part_num_fea_value ( l_rec.partnumber, 'NUMBER_OF_LINES') ), 1) AS number_of_lines,
       lv_number_of_lines number_of_lines,  -- CR41658
              NVL(l_service_plan_id,l_rc_service_plan_id) AS service_plan_id,
              get_pmt_pending_acc_grp_id(ip_red_card_code => ip_red_card_code) AS payment_pending_group_id,
              group_rec.program_enrolled_id                               AS program_enrolled_id ,
              cstp.application_req_num                    AS application_req_num -- TW+ changes -
       FROM   DUAL;
 --
  op_err_code := 0;
  op_err_msg  := 'Success';

EXCEPTION
  WHEN OTHERS THEN
    -- Log error message
    log_error( ip_error_text   => 'SQLERRM: ' || SQLERRM,
               ip_error_date   => SYSDATE,
               ip_action       => 'exception when others clause for ip_red_card_code = ' || ip_red_card_code || ' , ip_smpnumber = ' || ip_smpnumber || ' , ip_source_system = ' || ip_source_system || ' , iop_esn = ' || iop_esn || ' , ip_bus_org_id = ' || ip_bus_org_id,
               ip_key          => ip_red_card_code,
               ip_program_name => 'brand_x_pkg.validate_red_card_sp');
    op_err_code := 1;
    op_err_msg  := 'Unhandled exception : ' || SQLERRM;
    RAISE;
END validate_red_card_sp;
--
--
-- Added on 11/20/2014 by Juda Pena to validate the
PROCEDURE validate_red_card (ip_red_card_code      IN      VARCHAR2,
                             ip_smpnumber          IN      VARCHAR2,
                             ip_source_system      IN      VARCHAR2,
                             ip_esn                IN OUT  VARCHAR2,
                             ip_bus_org_id         IN      VARCHAR2,  -- TOTAL_WIRELESS
                             op_available_capacity OUT     NUMBER,
                             op_refcursor          OUT     SYS_REFCURSOR,
                             op_err_code           OUT     NUMBER,
                             op_err_msg            OUT     VARCHAR2)
AS

  -- Get all members part of the group the provided esn belongs to
  CURSOR c_get_active_members
  IS
    SELECT *
    FROM x_account_group_member
    WHERE account_group_id IN
      (SELECT account_group_id
      FROM x_account_group_member
      WHERE esn          = ip_esn
      AND UPPER(status) <> 'EXPIRED'
      )
  AND UPPER(status) <> 'EXPIRED';

  -- Determine if the esn has a PAYMENT_PENDING transaction in SOS
  CURSOR c_find_pmt_pending
  IS
    SELECT 'Y' payment_pending_flag
    FROM x_service_order_stage
    WHERE esn         = ip_esn
    AND UPPER(status) = 'PAYMENT_PENDING';

  pmt_pending_rec c_find_pmt_pending%ROWTYPE;

  -- Record to hold the input cursor from VALIDATE_RED_CARD_PKG.main
  TYPE t_row
  IS
  RECORD
  (
    status             VARCHAR2(1000),
    units              NUMBER,
    days               NUMBER,
    cardbrand          VARCHAR2(20),
    msgnum             VARCHAR2(1000),
    msgstr             VARCHAR2(1000),
    errorpin           VARCHAR2(1000),
    description        VARCHAR2(255),
    partnumber         VARCHAR2(30),
    cardtype           VARCHAR2(20),
    parttype           VARCHAR2(20),
    x_web_card_desc    VARCHAR2(100),
    x_sp_web_card_desc VARCHAR2(100),
    x_ild_type         NUMBER );

  l_refcursor sys_refcursor;
  l_rec t_row;
  l_number_of_lines NUMBER;
  l_dummy_esn_flag  VARCHAR2(1) := 'N';
  group_rec            x_account_group%ROWTYPE;

BEGIN

  -- Set the member available capacity to 0.
  -- This is used to determine how many members can be added to a group based on a given pin
  op_available_capacity := 0;
  -- If brand is using a shared group plan structure
  IF get_shared_group_flag ( ip_bus_org_id => ip_bus_org_id) = 'Y' THEN
    -- If an ESN is not passed
    IF ip_esn IS NULL THEN
      -- Pick a random dummy ESN when it is not provided
      ip_esn := get_dummy_esn ( ip_red_card_code );
      -- Set a flag to Y when a dummy ESN was randomly picked
      l_dummy_esn_flag := 'Y';
    END IF;
  END IF;
  -- Validate redemption card information (call existing procedure)
  validate_red_card_pkg.main ( strredcard => ip_red_card_code, strsmpnumber => ip_smpnumber, strsourcesys => ip_source_system, stresn => ip_esn, po_refcursor => l_refcursor ); -- Output
  -- LOOP is not necessary since there is only one row returned as an output ref cursor
  -- Fetch the data from the open cursor to the temporary table record (l_rec)
  FETCH l_refcursor
  INTO l_rec;
  --EXIT WHEN l_refcursor%NOTFOUND;
  --DBMS_OUTPUT.PUT_LINE('status             ' || l_rec.status            );
  --DBMS_OUTPUT.PUT_LINE('units              ' || l_rec.units             );
  --DBMS_OUTPUT.PUT_LINE('days               ' || l_rec.days              );
  --DBMS_OUTPUT.PUT_LINE('cardbrand          ' || l_rec.cardbrand         );
  --DBMS_OUTPUT.PUT_LINE('msgnum             ' || l_rec.msgnum            );
  --DBMS_OUTPUT.PUT_LINE('msgstr             ' || l_rec.msgstr            );
  --DBMS_OUTPUT.PUT_LINE('errorpin           ' || l_rec.errorpin          );
  --DBMS_OUTPUT.PUT_LINE('description        ' || l_rec.description       );
  --DBMS_OUTPUT.PUT_LINE('partnumber         ' || l_rec.partnumber        );
  --DBMS_OUTPUT.PUT_LINE('cardtype           ' || l_rec.cardtype          );
  --DBMS_OUTPUT.PUT_LINE('parttype           ' || l_rec.parttype          );
  --DBMS_OUTPUT.PUT_LINE('x_web_card_desc    ' || l_rec.x_web_card_desc   );
  --DBMS_OUTPUT.PUT_LINE('x_sp_web_card_desc ' || l_rec.x_sp_web_card_desc);
  --DBMS_OUTPUT.PUT_LINE('x_ild_type         ' || l_rec.x_ild_type        );
  -- LOOP is not necessary since there is only one row returned as an output ref cursor
  -- END LOOP;
  -- Perform shared group plan validations (when an esn was provided)
  IF ( l_rec.msgnum                                           = '0' ) AND -- When no errors were returned from the call to validate_red_card_pkg.main
    ( get_shared_group_flag ( ip_bus_org_id => ip_bus_org_id) = 'Y' ) AND -- only for shared group brands
    ( NVL(l_dummy_esn_flag,'N')                               = 'N' )     -- ESN was passed as an input parameter
    THEN
    -- 1. Validation: For all ESNs part of the group. If any ESN fails the compatibility the complete validation fails
    -- Get all the active members of a group
    FOR i IN c_get_active_members
    LOOP
      -- Validate group service plan and esn compatibility
      IF valid_service_plan_group ( ip_account_group_id => i.account_group_id, ip_esn => i.esn) = 'N' THEN
        -- Overwrite message with service plan incompatibility
        l_rec.msgnum := '1591';
        l_rec.msgstr := 'ESN IS NOT COMPATIBLE WITH THE SERVICE PLAN';
        -- Transfer control to the <<procedure_end>> block (to exit the program)
        GOTO procedure_end;
      END IF;
    END LOOP;
    -- 2. Validation: The total count of active ESNs in the group cannot be greater than the number of lines allowed by the
    --                provided PIN?s service plan/number of lines.
    IF valid_number_of_lines ( ip_esn => ip_esn, ip_red_card_code => ip_red_card_code, op_available_capacity => op_available_capacity) = 'N' THEN
      -- Overwrite message with service plan incompatibility
      l_rec.msgnum := '1592';
      l_rec.msgstr := 'NUMBER OF ACTIVE ESNS IN THE GROUP IS GREATER THAN THE NUMBER OF LINES ALLOWED FOR THE PIN';
      -- Transfer control to the <<procedure_end>> block (to exit the program)
      GOTO procedure_end;
    END IF;
    --
    -- 3. Validation: If any of the active members of a group has a card in queue and the queued pin service plan/number of lines
    --                does not match the passed red card service plan/number of lines
    IF valid_queued_red_cards ( ip_esn => ip_esn, ip_red_card_code => ip_red_card_code) = 'N' THEN
      -- Overwrite message with service plan incompatibility
      l_rec.msgnum := '1592';
      l_rec.msgstr := 'NUMBER OF ACTIVE ESNS IN THE GROUP IS GREATER THAN THE NUMBER OF LINES ALLOWED FOR THE PIN';
      -- Transfer control to the <<procedure_end>> block (to exit the program)
      GOTO procedure_end;
    END IF;
  END IF;
  -- GOTO end block
  << procedure_end >>
  -- Find payment pending record in SOS
  OPEN c_find_pmt_pending;
  FETCH c_find_pmt_pending INTO pmt_pending_rec;
  IF c_find_pmt_pending%NOTFOUND THEN
    pmt_pending_rec.payment_pending_flag := 'N';
  END IF;
  CLOSE c_find_pmt_pending;
  --
  -- TW+ changes - SMEGANATHAN  starts..
  -- Call function to return the x_account_group complete row based on the esn (member)
  group_rec := get_group_rec ( ip_esn => ip_esn );
  --TW+ changes - Ends.
  -- Reopen the ref cursor for the calling programs and add the number of lines to the ref cursor.
  OPEN op_refcursor
  FOR SELECT  l_rec.status                          AS  strstatus,
              l_rec.units                           AS  intunits,
              l_rec.days                            AS  intdays,
              l_rec.cardbrand                       AS  strcardbrand,
              l_rec.msgnum                          AS  strmsgnum,
              l_rec.msgstr                          AS  strmsgstr,
              l_rec.errorpin                        AS  strerrorpin,
              l_rec.description                     AS  description,
              l_rec.partnumber                      AS  partnumber,
              l_rec.cardtype                        AS  cardtype,
              l_rec.parttype                        AS  parttype,
              l_rec.x_web_card_desc                 AS  x_web_card_desc,
              l_rec.x_sp_web_card_desc              AS  x_sp_web_card_desc,
              l_rec.x_ild_type                      AS  x_ild_type,
              NVL( TO_NUMBER( get_part_num_fea_value ( l_rec.partnumber, 'NUMBER_OF_LINES') ), 1) AS  number_of_lines,
              pmt_pending_rec.payment_pending_flag  AS  payment_pending_flag,
              'N'                                   AS  incompatible_enrollment_flag,
              NULL                                  AS application_req_num -- TW+ changes - SMEGANATHAN
  FROM DUAL;

  op_err_code := 0;
  op_err_msg  := 'Success';

EXCEPTION
  WHEN OTHERS THEN
    -- Log error message
    log_error( ip_error_text => 'SQLERRM: ' || SQLERRM, ip_error_date => SYSDATE, ip_action => 'exception when others clause for ip_red_card_code = ' || ip_red_card_code || ' , ip_smpnumber = ' || ip_smpnumber || ' , ip_source_system = ' || ip_source_system || ' , ip_esn = ' || ip_esn || ' , ip_bus_org_id = ' || ip_bus_org_id, ip_key => ip_red_card_code, ip_program_name => 'brand_x_pkg.validate_red_card');
    op_err_code := 1;
    op_err_msg  := 'Unhandled exception : ' || SQLERRM;
    RAISE;
END validate_red_card;
--
--
-- Added on 10/17/2014 by Juda Pena to change the account group service plan
PROCEDURE change_service_plan (ip_account_group_id  IN  NUMBER,
                               ip_service_plan_id   IN  NUMBER,
                               op_err_code          OUT NUMBER,
                               op_err_msg           OUT VARCHAR2)
AS
  LV_PROGRAM_PARAM_ID   sa.X_SERVICE_ORDER_STAGE.PROGRAM_PARAM_ID%TYPE;
BEGIN

  -- Required parameters
  IF ip_account_group_id IS NULL OR ip_service_plan_id IS NULL THEN
    --
    op_err_code := 2;
    op_err_msg  := 'account group id and service plan id must not be blank.';
    -- Exit the program
    RETURN;
  END IF;

  -- Update group service plan
  UPDATE x_account_group
  SET service_plan_id         = ip_service_plan_id,
    service_plan_feature_date = SYSDATE,
    update_timestamp          = SYSDATE
  WHERE objid                 = ip_account_group_id;

 --Start of CR35695
 FOR MEMBER_REC IN ( SELECT GM.OBJID
      FROM  sa.X_ACCOUNT_GROUP_MEMBER GM
      WHERE  GM.ACCOUNT_GROUP_ID = IP_ACCOUNT_GROUP_ID)
 LOOP
  FOR STAGE_REC IN ( SELECT  *
       FROM  sa.X_SERVICE_ORDER_STAGE SOS
       WHERE  SOS.STATUS = 'PAYMENT_PENDING'
       AND  SOS.ACCOUNT_GROUP_MEMBER_ID = MEMBER_REC.OBJID)
  LOOP
   LV_PROGRAM_PARAM_ID := NULL;
   IF STAGE_REC.PROGRAM_PARAM_ID IS NOT NULL THEN
    SELECT  PP.OBJID
    INTO LV_PROGRAM_PARAM_ID
    FROM  sa.MTM_SP_X_PROGRAM_PARAM MTM,
      sa.X_PROGRAM_PARAMETERS PP ,
      sa.X_SERVICE_PLAN SP
    WHERE  MTM.X_SP2PROGRAM_PARAM = PP.OBJID
    AND  MTM.PROGRAM_PARA2X_SP    = SP.OBJID
    AND  SP.OBJID = IP_SERVICE_PLAN_ID;
   END IF;
   UPDATE  sa.X_SERVICE_ORDER_STAGE
   SET  SERVICE_PLAN_ID = IP_SERVICE_PLAN_ID
     , PROGRAM_PARAM_ID = LV_PROGRAM_PARAM_ID
   WHERE   OBJID = STAGE_REC.OBJID;
  END LOOP;

 END LOOP;
 --End of CR35695

  -- Successful response
  op_err_code := 0;
  op_err_msg  := 'Success';

EXCEPTION
  WHEN OTHERS THEN
    -- Log error message
    log_error( ip_error_text => 'SQLERRM: ' || SQLERRM, ip_error_date => SYSDATE, ip_action => 'exception when others clause for ip_account_group_id = ' || ip_account_group_id || ' , ip_service_plan_id = ' || ip_service_plan_id, ip_key => ip_account_group_id, ip_program_name => 'brand_x_pkg.change_service_plan');
    op_err_code := 1;
    op_err_msg  := 'Unhandled exception : ' || SQLERRM;
    RAISE;
END change_service_plan;
--
--
-- Added on 10/29/2014 by Juda Pena to create the SOS record
PROCEDURE create_service_order_stage (ip_account_group_member_id  IN  NUMBER,
                                      ip_esn                      IN  VARCHAR2,
                                      ip_sim                      IN  VARCHAR2,
                                      ip_zipcode                  IN  VARCHAR2,
                                      ip_pin                      IN  VARCHAR2,
                                      ip_service_plan_id          IN  NUMBER,
                                      ip_case_id                  IN  NUMBER,
                                      ip_status                   IN  VARCHAR2,
                                      ip_type                     IN  VARCHAR2,
                                      ip_program_param_id         IN  NUMBER,
                                      ip_pmt_source_id            IN  VARCHAR2,
                                      ip_web_objid                IN  NUMBER,
                                      op_service_order_stage_id   OUT NUMBER,
                                      op_err_code                 OUT NUMBER,
                                      op_err_msg                  OUT VARCHAR2)
AS
  PRAGMA AUTONOMOUS_TRANSACTION; -- Declare block as an autonomous transaction
BEGIN

  -- Create the service order stage record
  INSERT INTO x_service_order_stage
    (
      objid ,
      account_group_member_id ,
      esn ,
      sim ,
      zipcode ,
      smp ,
      service_plan_id ,
      case_id ,
      status ,
      type ,
      program_param_id ,
      pmt_source_id ,
      web_objid ,
      insert_timestamp ,
      update_timestamp
    )
    VALUES
    (
      sa.sequ_service_order_stage.nextval ,
      ip_account_group_member_id ,
      ip_esn ,
      ip_sim ,
      ip_zipcode ,
      convert_pin_to_smp ( ip_red_code => ip_pin) ,
      ip_service_plan_id ,
      ip_case_id ,
      ip_status ,
      ip_type ,
      ip_program_param_id ,
      ip_pmt_source_id ,
      ip_web_objid ,
      SYSDATE ,
      SYSDATE
    )
  RETURNING objid
  INTO op_service_order_stage_id;

  op_err_code := 0;
  op_err_msg  := 'Success';

  COMMIT;

EXCEPTION
  WHEN OTHERS THEN
    -- Log error message
    log_error( ip_error_text => 'SQLERRM: ' || SQLERRM, ip_error_date => SYSDATE, ip_action => 'exception when others clause for ip_account_group_member_id = ' || ip_account_group_member_id || ' , ip_esn = ' || ip_esn || ' , ip_sim = ' || ip_sim || ' , ip_zipcode = ' || ip_zipcode || ' , ip_pin = ' || ip_pin || ' , ip_service_plan_id = ' || ip_service_plan_id || ' , ip_case_id = ' || ip_case_id || ' , ip_status = ' || ip_status || ' , ip_type = ' || ip_type || ' , ip_program_param_id = ' || ip_program_param_id || ' , ip_pmt_source_id = ' || ip_pmt_source_id || ' , ip_web_objid = ' || ip_web_objid, ip_key => ip_account_group_member_id, ip_program_name => 'brand_x_pkg.create_service_order_stage');
    ROLLBACK;
    op_err_code := 1;
    op_err_msg  := 'Unhandled exception : ' || Sqlerrm;
    RAISE;
END create_service_order_stage;
--
--
-- Added on 10/29/2014 by Juda Pena to create the stage record (wo pragma)
PROCEDURE create_service_order_stage_we (ip_account_group_member_id IN NUMBER,
                                         ip_esn                     IN VARCHAR2,
                                         ip_sim                     IN VARCHAR2,
                                         ip_zipcode                 IN VARCHAR2,
                                         ip_pin                     IN VARCHAR2,
                                         ip_service_plan_id         IN NUMBER,
                                         ip_case_id                 IN NUMBER,
                                         ip_status                  IN VARCHAR2,
                                         ip_type                    IN VARCHAR2,
                                         ip_program_param_id        IN NUMBER,
                                         ip_pmt_source_id           IN VARCHAR2,
                                         ip_web_objid               IN NUMBER,
                                         ip_sourcesystem            IN  VARCHAR2,
                                         ip_bus_org_id              IN  VARCHAR2,
                                         op_service_order_stage_id  OUT NUMBER,
                                         op_err_code                OUT NUMBER,
                                         op_err_msg                 OUT VARCHAR2)
AS
BEGIN

  -- Create the service order stage record
  INSERT INTO x_service_order_stage
    (
      objid ,
      account_group_member_id ,
      esn ,
      sim ,
      zipcode ,
      smp ,
      service_plan_id ,
      case_id ,
      status ,
      type ,
      program_param_id ,
      pmt_source_id ,
      web_objid ,
      sourcesystem ,
      bus_org_id ,
      insert_timestamp ,
      update_timestamp
    )
    VALUES
    (
      sa.sequ_service_order_stage.nextval ,
      ip_account_group_member_id ,
      ip_esn ,
      ip_sim ,
      ip_zipcode ,
      convert_pin_to_smp ( ip_red_code => ip_pin) ,
      ip_service_plan_id ,
      ip_case_id ,
      ip_status ,
      ip_type ,
      ip_program_param_id ,
      ip_pmt_source_id ,
      ip_web_objid ,
      ip_sourcesystem ,
      ip_bus_org_id ,
      SYSDATE ,
      SYSDATE
    )
  RETURNING objid
  INTO op_service_order_stage_id;

  op_err_code := 0;
  op_err_msg  := 'Success';

EXCEPTION
  WHEN OTHERS THEN
    -- Log error message
    log_error( ip_error_text => 'SQLERRM: ' || SQLERRM, ip_error_date => SYSDATE, ip_action => 'exception when others clause for ip_account_group_member_id = ' || ip_account_group_member_id || ' , ip_esn = ' || ip_esn || ' , ip_sim = ' || ip_sim || ' , ip_zipcode = ' || ip_zipcode || ' , ip_pin = ' || ip_pin || ' , ip_service_plan_id = ' || ip_service_plan_id || ' , ip_case_id = ' || ip_case_id || ' , ip_status = ' || ip_status || ' , ip_type = ' || ip_type || ' , ip_program_param_id = ' || ip_program_param_id || ' , ip_pmt_source_id = ' || ip_pmt_source_id || ' , ip_web_objid = ' || ip_web_objid, ip_key => ip_account_group_member_id, ip_program_name => 'brand_x_pkg.create_service_order_stage_we');
    op_err_code := 1;
    op_err_msg  := 'Unhandled exception : ' || SQLERRM;
    RAISE;
END create_service_order_stage_we;
--
--
-- (Overloaded) Added on 10/29/2014 by Juda Pena to create the SOS record
PROCEDURE create_service_order_stage (ip_account_group_member_id IN  NUMBER,
                                      ip_esn                     IN  VARCHAR2,
                                      ip_sim                     IN  VARCHAR2,
                                      ip_zipcode                 IN  VARCHAR2,
                                      ip_pin                     IN  VARCHAR2,
                                      ip_service_plan_id         IN  NUMBER,
                                      ip_case_id                 IN  NUMBER,
                                      ip_status                  IN  VARCHAR2,
                                      ip_type                    IN  VARCHAR2,
                                      ip_program_param_id        IN  NUMBER,
                                      ip_pmt_source_id           IN  VARCHAR2,
                                      ip_web_objid               IN  NUMBER,
                                      ip_sourcesystem            IN  VARCHAR2,
                                      ip_bus_org_id              IN  VARCHAR2,
                                      op_service_order_stage_id  OUT NUMBER,
                                      op_err_code                OUT NUMBER,
                                      op_err_msg                 OUT VARCHAR2)
AS
  PRAGMA AUTONOMOUS_TRANSACTION; -- Declare block as an autonomous transaction
BEGIN

  -- Create the service order stage record
  INSERT INTO x_service_order_stage
    (
      objid ,
      account_group_member_id ,
      esn ,
      sim ,
      zipcode ,
      smp ,
      service_plan_id ,
      case_id ,
      status ,
      type ,
      program_param_id ,
      pmt_source_id ,
      web_objid ,
      sourcesystem ,
      bus_org_id ,
      insert_timestamp ,
      update_timestamp
    )
    VALUES
    (
      sa.sequ_service_order_stage.nextval ,
      ip_account_group_member_id ,
      ip_esn ,
      ip_sim ,
      ip_zipcode ,
      convert_pin_to_smp ( ip_red_code => ip_pin) ,
      ip_service_plan_id ,
      ip_case_id ,
      ip_status ,
      ip_type ,
      ip_program_param_id ,
      ip_pmt_source_id ,
      ip_web_objid ,
      ip_sourcesystem ,
      ip_bus_org_id ,
      SYSDATE ,
      SYSDATE
    )
  RETURNING objid
  INTO op_service_order_stage_id;

  op_err_code := 0;
  op_err_msg  := 'Success';

  COMMIT;

EXCEPTION
  WHEN OTHERS THEN
    -- Log error message
    log_error( ip_error_text => 'SQLERRM: ' || SQLERRM, ip_error_date => SYSDATE, ip_action => 'exception when others clause for ip_account_group_member_id = ' || ip_account_group_member_id || ' , ip_esn = ' || ip_esn || ' , ip_sim = ' || ip_sim || ' , ip_zipcode = ' || ip_zipcode || ' , ip_pin = ' || ip_pin || ' , ip_service_plan_id = ' || ip_service_plan_id || ' , ip_case_id = ' || ip_case_id || ' , ip_status = ' || ip_status || ' , ip_type = ' || ip_type || ' , ip_program_param_id = ' || ip_program_param_id || ' , ip_pmt_source_id = ' || ip_pmt_source_id || ' , ip_web_objid = ' || ip_web_objid || ' , ip_sourcesystem = ' || ip_sourcesystem || ' , ip_bus_org_id = ' || ip_bus_org_id, ip_key => ip_account_group_member_id, ip_program_name => 'brand_x_pkg.create_service_order_stage');
    ROLLBACK;
    op_err_code := 1;
    op_err_msg  := 'Unhandled exception : ' || Sqlerrm;
    RAISE;
END create_service_order_stage;
--
--
-- CR48480 added overloaded procedure to create the SOS record with discount list
PROCEDURE create_service_order_stage (ip_account_group_member_id IN  NUMBER,
                                      ip_esn                     IN  VARCHAR2,
                                      ip_sim                     IN  VARCHAR2,
                                      ip_zipcode                 IN  VARCHAR2,
                                      ip_pin                     IN  VARCHAR2,
                                      ip_service_plan_id         IN  NUMBER,
                                      ip_case_id                 IN  NUMBER,
                                      ip_status                  IN  VARCHAR2,
                                      ip_type                    IN  VARCHAR2,
                                      ip_program_param_id        IN  NUMBER,
                                      ip_pmt_source_id           IN  VARCHAR2,
                                      ip_web_objid               IN  NUMBER,
                                      ip_sourcesystem            IN  VARCHAR2,
                                      ip_bus_org_id              IN  VARCHAR2,
                                      ip_discount_code_list      IN  discount_code_tab,
                                      op_service_order_stage_id  OUT NUMBER,
                                      op_err_code                OUT NUMBER,
                                      op_err_msg                 OUT VARCHAR2)
AS
  PRAGMA AUTONOMOUS_TRANSACTION; -- Declare block as an autonomous transaction
BEGIN

  -- Create the service order stage record
  INSERT INTO x_service_order_stage
    (
      objid ,
      account_group_member_id ,
      esn ,
      sim ,
      zipcode ,
      smp ,
      service_plan_id ,
      case_id ,
      status ,
      type ,
      program_param_id ,
      pmt_source_id ,
      web_objid ,
      sourcesystem ,
      bus_org_id ,
      discount_code_list,
      insert_timestamp ,
      update_timestamp
    )
    VALUES
    (
      sa.sequ_service_order_stage.nextval ,
      ip_account_group_member_id ,
      ip_esn ,
      ip_sim ,
      ip_zipcode ,
      convert_pin_to_smp ( ip_red_code => ip_pin) ,
      ip_service_plan_id ,
      ip_case_id ,
      ip_status ,
      ip_type ,
      ip_program_param_id ,
      ip_pmt_source_id ,
      ip_web_objid ,
      ip_sourcesystem ,
      ip_bus_org_id ,
      ip_discount_code_list,
      SYSDATE ,
      SYSDATE
    )
  RETURNING objid
  INTO op_service_order_stage_id;

  op_err_code := 0;
  op_err_msg  := 'Success';

  COMMIT;

EXCEPTION
  WHEN OTHERS THEN
    -- Log error message
    log_error( ip_error_text => 'SQLERRM: ' || SQLERRM, ip_error_date => SYSDATE, ip_action => 'exception when others clause for ip_account_group_member_id = ' || ip_account_group_member_id || ' , ip_esn = ' || ip_esn || ' , ip_sim = ' || ip_sim || ' , ip_zipcode = ' || ip_zipcode || ' , ip_pin = ' || ip_pin || ' , ip_service_plan_id = ' || ip_service_plan_id || ' , ip_case_id = ' || ip_case_id || ' , ip_status = ' || ip_status || ' , ip_type = ' || ip_type || ' , ip_program_param_id = ' || ip_program_param_id || ' , ip_pmt_source_id = ' || ip_pmt_source_id || ' , ip_web_objid = ' || ip_web_objid || ' , ip_sourcesystem = ' || ip_sourcesystem || ' , ip_bus_org_id = ' || ip_bus_org_id, ip_key => ip_account_group_member_id, ip_program_name => 'brand_x_pkg.create_service_order_stage');
    ROLLBACK;
    op_err_code := 1;
    op_err_msg  := 'Unhandled exception : ' || Sqlerrm;
    RAISE;
END create_service_order_stage;
--
--
-- Added by Juda Pena on 11/20/2014
PROCEDURE update_so_stage_status (ip_account_group_id       IN  NUMBER,
                                  ip_payment_pending_status IN  VARCHAR2,  -- PAYMENT_PENDING
                                  ip_queued_status          IN  VARCHAR2,  -- QUEUED
                                  ip_prequeued_status       IN  VARCHAR2,  -- TO_QUEUE
                                  op_err_code               OUT NUMBER,
                                  op_err_msg                OUT VARCHAR2)
AS
  -- Get stage data
  CURSOR c_get_master_stage
  IS
    SELECT sos.objid service_order_stage_id,
      sos.type,
      sos.status,
      agm.objid account_group_member_id,sos.sim
    FROM x_service_order_stage sos,
      x_account_group_member agm
    WHERE agm.account_group_id = ip_account_group_id
    AND agm.master_flag        = 'Y'
    AND agm.objid              = sos.account_group_member_id;

  master_so_rec c_get_master_stage%ROWTYPE;
  v_sim_member_count NUMBER;

BEGIN

  --CR39391 - If status='PAYMENT_PENDING' and sim is  null , device LTE then update to case_pending
  UPDATE x_account_group_member
    SET status='CASE_PENDING'
    WHERE objid IN
    (
     SELECT agm.objid
      FROM x_service_order_stage sos,
        x_account_group_member agm
      WHERE agm.account_group_id = ip_account_group_id
      AND agm.objid              = sos.account_group_member_id
      AND LTE_SERVICE_PKG.IS_ESN_LTE_CDMA(sos.esn)=1
      AND sos.sim IS  NULL
      AND UPPER(sos.status) = 'PAYMENT_PENDING'
      AND UPPER(agm.status)     <> 'EXPIRED'
     ) ;

  UPDATE x_service_order_stage
  SET status='CASE_PENDING'
  WHERE account_group_member_id IN
        (SELECT objid
        FROM x_account_group_member
        WHERE account_group_id   = ip_account_group_id
        AND UPPER(status)     <> 'EXPIRED'
    )
    and LTE_SERVICE_PKG.IS_ESN_LTE_CDMA(esn)=1
    and sim IS  NULL
    and UPPER(status) = 'PAYMENT_PENDING';

  --CR39391 ends

  -- Get master
  OPEN c_get_master_stage;
  FETCH c_get_master_stage INTO master_so_rec;
  CLOSE c_get_master_stage;
  -- When we do update status (BRANDX_PKG.UPDATE_SO_STAGE_STATUS) for changing the PAYMENT_PENDING to QUEUED will be updated as follows:
  --  If MASTER ESN is of type ACTIVATION, and status of stage is in PAYMENT_PENDING
  --cwl 1/17/2015
  IF master_so_rec.type IN ('REACTIVATION', 'ACTIVATION') AND
    --cwl 1/17/2015
    master_so_rec.status = ip_payment_pending_status THEN
    -- MASTER ESN will be updated to QUEUED
    UPDATE x_service_order_stage
    SET status  = ip_queued_status
    WHERE objid = master_so_rec.service_order_stage_id;
    --
    -- ALL MEMBER ESNs will be updated to an interim stage TO_QUEUE
    UPDATE x_service_order_stage
    SET status                     = ip_prequeued_status
    WHERE account_group_member_id IN
      (SELECT objid
      FROM x_account_group_member
      WHERE account_group_id   = ip_account_group_id
      AND NVL(master_flag,'N') = 'N'
      )
--CR39391 - If status='SIM_PENDING' and sim is not null also we need to update
    AND ( (status = 'PAYMENT_PENDING') or (status='SIM_PENDING' and sim is not null) );
--CR39391 - ends
    op_err_code := 0;
    op_err_msg  := 'Success';
    RETURN; --CR to fix activation issue
  END IF;

--CR39391 -  below piece of code takes care of Master SIM_PENDING and CASE_PENDING scenario
  IF master_so_rec.type IN ('REACTIVATION', 'ACTIVATION') AND master_so_rec.status in('SIM_PENDING','CASE_PENDING')  THEN
    IF master_so_rec.sim is not null then
        -- MASTER ESN will be updated to QUEUED
        UPDATE x_service_order_stage
        SET status  = ip_queued_status
        WHERE objid = master_so_rec.service_order_stage_id;
       -- ALL MEMBER ESNs will be updated to an interim stage TO_QUEUE
        UPDATE x_service_order_stage
        SET status = ip_prequeued_status
        WHERE account_group_member_id IN
          (SELECT objid
          FROM x_account_group_member
          WHERE account_group_id   = ip_account_group_id
          AND NVL(master_flag,'N') = 'N'
          )
        AND ( (status = 'PAYMENT_PENDING') or (status='SIM_PENDING' and sim is not null) );
    ELSE
       --check if any of the members has a sim. If yes flip the master
       SELECT count(*) INTO v_sim_member_count
        FROM x_service_order_stage sos,
          x_account_group_member agm
        WHERE agm.account_group_id = ip_account_group_id
        AND agm.master_flag        <> 'Y'
      AND UPPER(agm.status)     <> 'EXPIRED'
        AND agm.objid              = sos.account_group_member_id
      AND UPPER(sos.status)     <> 'COMPLETED'
        and  sim is not null ;

       IF v_sim_member_count > 0 THEN
        reassign_service_order_master ( ip_account_group_id  ,
                                        ip_queued_status     ,
                                        op_err_code          ,
                                        op_err_msg   )  ;
         UPDATE x_service_order_stage
          SET status = ip_prequeued_status
          WHERE account_group_member_id IN
            (SELECT objid
            FROM x_account_group_member
            WHERE account_group_id   = ip_account_group_id
            AND NVL(master_flag,'N') = 'N'
            )
          AND ( (status = 'PAYMENT_PENDING') or (status='SIM_PENDING' and sim is not null) );
       END IF;
    END IF;
    op_err_code := 0;
    op_err_msg  := 'Success';
    RETURN; --CR to fix activation issue
  END IF;
--CR39391 -  ends

  -- If MASTER ESN is of type PORT, and status of stage is in PAYMENT_PENDING (This is a scenario when the group has only PORT cases for all lines)
  IF master_so_rec.type = 'PORT' AND
    -- master_so_rec.status = ip_payment_pending_status -- Commented out on 03/20/2015 by Kumar's request
--CR39391 - BYOP added  Or part of below condition
    ( master_so_rec.status IN ('PAYMENT_PENDING','COMPLETED') or (master_so_rec.status='SIM_PENDING' and master_so_rec.sim is not null) ) THEN
    -- All ESNs belonging to the group with status PAYMENT_PENDING will be updated to QUEUED
    UPDATE x_service_order_stage
    SET status                     = ip_queued_status
    WHERE account_group_member_id IN
      (SELECT objid
      FROM x_account_group_member
      WHERE account_group_id = ip_account_group_id
      AND UPPER(status)     <> 'EXPIRED'
      )
--CR39391 - Commented below condition and added second line
    --AND status = ip_payment_pending_status;
      AND ( (status = ip_payment_pending_status) or (status='SIM_PENDING' and sim is not null) );
     ELSE
       --check if any of the members has a sim. If yes flip the master
       SELECT count(*) INTO v_sim_member_count
        FROM x_service_order_stage sos,
          x_account_group_member agm
        WHERE agm.account_group_id = ip_account_group_id
        AND agm.master_flag        <> 'Y'
      AND UPPER(agm.status)     <> 'EXPIRED'
        AND agm.objid              = sos.account_group_member_id
      AND UPPER(sos.status)     <> 'COMPLETED'
        and  sim is not null ;

       IF v_sim_member_count > 0 THEN
        reassign_service_order_master ( ip_account_group_id  ,
                                        ip_queued_status     ,
                                        op_err_code          ,
                                        op_err_msg   )  ;
         UPDATE x_service_order_stage
          SET status = ip_queued_status
          WHERE account_group_member_id IN
            (SELECT objid
            FROM x_account_group_member
            WHERE account_group_id   = ip_account_group_id
            AND NVL(master_flag,'N') = 'N'
            )
          AND ( (status = 'PAYMENT_PENDING') or (status='SIM_PENDING' and sim is not null) );
       END IF;
  END IF;

  op_err_code := 0;
  op_err_msg  := 'Success';

EXCEPTION
  WHEN OTHERS THEN
    -- Log error message
    log_error( ip_error_text => 'SQLERRM: ' || SQLERRM, ip_error_date => SYSDATE, ip_action => 'exception when others clause for ip_account_group_id = ' || ip_account_group_id || ' , ip_payment_pending_status = ' || ip_payment_pending_status || ' , ip_queued_status = ' || ip_queued_status || ' , ip_prequeued_status = ' || ip_prequeued_status, ip_key => ip_account_group_id, ip_program_name => 'brand_x_pkg.update_so_stage_status');
    op_err_code := 1;
    op_err_msg  := 'Unhandled exception : ' || Sqlerrm;
    RAISE;
END update_so_stage_status;
--
--
-- Added by Juda Pena on 11/20/2014
PROCEDURE complete_master_service_order (ip_account_group_id  IN  NUMBER,
                                         ip_complete_status   IN  VARCHAR2,  -- COMPLETE
                                         ip_queued_status     IN  VARCHAR2,  -- QUEUED
                                         ip_prequeued_status  IN  VARCHAR2,  -- TO_QUEUE
                                         op_err_code          OUT NUMBER,
                                         op_err_msg           OUT VARCHAR2)
AS
BEGIN

 --CR39391 - If status='PAYMENT_PENDING' and sim is  null , device LTE then update to case_pending
   UPDATE x_account_group_member
    SET status='CASE_PENDING'
    WHERE objid IN
    (
     SELECT agm.objid
      FROM x_service_order_stage sos,
        x_account_group_member agm
      WHERE agm.account_group_id = ip_account_group_id
      AND agm.objid              = sos.account_group_member_id
      AND LTE_SERVICE_PKG.IS_ESN_LTE_CDMA(sos.esn)=1
      AND sos.sim IS  NULL
      AND UPPER(sos.status) = 'PAYMENT_PENDING'
      AND UPPER(agm.status)     <> 'EXPIRED'
     ) ;

  UPDATE x_service_order_stage
  SET status='CASE_PENDING'
  WHERE account_group_member_id IN
        (SELECT objid
        FROM x_account_group_member
        WHERE account_group_id   = ip_account_group_id
        AND UPPER(status)     <> 'EXPIRED'
    )
    and LTE_SERVICE_PKG.IS_ESN_LTE_CDMA(esn)=1
    and sim IS  NULL
    and UPPER(status) = 'PAYMENT_PENDING';

  --CR39391 ends

  -- Update service order stage master as COMPLETE
  UPDATE x_service_order_stage
  SET status                     = ip_complete_status
  WHERE account_group_member_id IN
    (SELECT objid
    FROM x_account_group_member
    WHERE account_group_id = ip_account_group_id
    AND UPPER(status)     <> 'EXPIRED'
    AND master_flag        = 'Y'
    )
  AND UPPER(status) IN ( ip_queued_status, 'PROCESSING'); -- This should be QUEUED or PROCESSING (since the master may have been already updated to PROCESSING)

  -- Update service order stage children to QUEUED
  UPDATE x_service_order_stage
  SET status                     = ip_queued_status
  WHERE account_group_member_id IN
    (SELECT objid
    FROM x_account_group_member
    WHERE account_group_id = ip_account_group_id
    AND UPPER(status)     <> 'EXPIRED'
      --AND    NVL(master_flag,'N') = 'N'
    )
--CR39391 - commented this and added below - AND UPPER(status) = ip_prequeued_status
    AND ( (UPPER(status) = ip_prequeued_status) or (status='SIM_PENDING' and sim is not null) ) ;
--CR39391 - ends

  op_err_code      := 0;
  op_err_msg       := 'Success';

EXCEPTION
  WHEN OTHERS THEN
    -- Log error message
    log_error( ip_error_text => 'SQLERRM: ' || SQLERRM, ip_error_date => SYSDATE, ip_action => 'exception when others clause for ip_account_group_id = ' || ip_account_group_id || ' , ip_complete_status = ' || ip_complete_status || ' , ip_queued_status = ' || ip_queued_status || ' , ip_prequeued_status = ' || ip_prequeued_status, ip_key => ip_account_group_id, ip_program_name => 'brand_x_pkg.complete_master_service_order');
    op_err_code := 1;
    op_err_msg  := 'Unhandled exception : ' || Sqlerrm;
    RAISE;
END complete_master_service_order;
--
--
-- Added by Juda Pena on 11/20/2014
PROCEDURE reassign_service_order_master (ip_account_group_id  IN  NUMBER,
                                         ip_queued_status     IN  VARCHAR2,  -- QUEUED
                                         op_err_code          OUT NUMBER,
                                         op_err_msg           OUT VARCHAR2)
AS
  -- Validate there is at least one children not expired
  --cwl 1/16/2015
  CURSOR c_other_esns( p_master_esn IN VARCHAR2 )
  IS
    SELECT 1 col1
    FROM x_account_group_member agm,
      x_service_order_stage so
    WHERE agm.account_group_id = ip_account_group_id
    AND UPPER(agm.status)     <> 'EXPIRED'
    AND agm.esn               <> p_master_esn
    AND agm.objid              = so.account_group_member_id
--CR39391 -  added below line
    AND ( ( UPPER(agm.status)='SIM_PENDING' and SIM is not null ) or (UPPER(agm.status)not in ('SIM_PENDING','CASE_PENDING')) );

--CR39391 -  ends
  other_esns_rec c_other_esns%rowtype;

  --cwl 1/16/2015
  CURSOR c_get_master_stage
  IS
    SELECT convert_smp_to_pin ( ip_smp => sos.smp) pin,
      agm.esn
    FROM x_service_order_stage sos,
      x_account_group_member agm
    WHERE agm.account_group_id = ip_account_group_id
    AND agm.master_flag        = 'Y'
    AND agm.objid              = sos.account_group_member_id;

  master_so_rec c_get_master_stage%ROWTYPE;

  -- Get the next active esn of a group  (ordered by member order and objid)
  CURSOR c_get_next_master_esn ( p_master_esn IN VARCHAR2 )
  IS
    SELECT esn
    FROM
      (SELECT RANK() OVER (PARTITION BY agm.account_group_id ORDER BY (
        CASE so.type
          WHEN 'ACTIVATION'
          THEN 1
          WHEN 'REACTIVATION'
          THEN 2
          ELSE 3
        END) ASC, (
        CASE so.status
          WHEN 'TO_QUEUE'
          THEN 1
          WHEN 'QUEUED'
          THEN 2
          WHEN 'PROCESSING'
          THEN 3
          WHEN 'PAYMENT_PENDING'
          THEN 4
          WHEN 'FAILED'
          THEN 5
          ELSE 6
        END) ASC, member_order, agm.objid) rank,
        agm.esn
      FROM x_account_group_member agm,
        x_service_order_stage so
      WHERE agm.account_group_id = ip_account_group_id
      AND UPPER(agm.status)     <> 'EXPIRED'
      AND agm.esn               <> p_master_esn
      AND agm.objid              = so.account_group_member_id)
  WHERE rank = 1;

  next_master_esn_rec c_get_next_master_esn%ROWTYPE;

BEGIN

  -- Get master
  OPEN c_get_master_stage;
  FETCH c_get_master_stage INTO master_so_rec;
  CLOSE c_get_master_stage;
  --
  --cwl 1/16/2015
  OPEN c_other_esns (master_so_rec.esn);
  FETCH c_other_esns INTO other_esns_rec;
  IF c_other_esns%notfound THEN
    op_err_code := 0;
    op_err_msg  := 'Success';
    CLOSE c_other_esns;
    RETURN;
  END IF;
  CLOSE c_other_esns;
  --cwl 1/16/2015
  --
  OPEN c_get_next_master_esn (master_so_rec.esn);
  FETCH c_get_next_master_esn INTO next_master_esn_rec;
  IF c_get_next_master_esn%NOTFOUND OR next_master_esn_rec.esn IS NULL THEN
    CLOSE c_get_next_master_esn;
    op_err_code := 2;
    op_err_msg  := 'Could not find the next master esn in account group_id [ ' || ip_account_group_id || ' ]';
    -- Exit the program
    RETURN;
  END IF;
  CLOSE c_get_next_master_esn;

  -- If PIN is not burned
  IF NVL(is_pin_burned(master_so_rec.pin),'N') = 'N' THEN
    -- CHANGE MASTER to the next ESN in the group (preference for ACTIVATION), move the PIN from the old master to the new master
    change_master ( ip_account_group_id => ip_account_group_id, ip_esn => next_master_esn_rec.esn, op_err_code => op_err_code, op_err_msg => op_err_msg, ip_switch_pin_flag => 'Y');
    IF op_err_code <> 0 THEN
      -- Exit whenever an error ocurred
      RETURN;
    END IF;
    -- If PIN is burned
  ELSE
    -- CHANGE MASTER to the next ESN in the group (preference for ACTIVATION), do not move the PIN from the old master to the new master, but use only SERVICE_PLAN_ID
    change_master ( ip_account_group_id => ip_account_group_id, ip_esn => next_master_esn_rec.esn, op_err_code => op_err_code, op_err_msg => op_err_msg, ip_switch_pin_flag => 'N');
    IF op_err_code <> 0 THEN
      -- Exit whenever an error ocurred
      RETURN;
    END IF;
  END IF;

  -- Update the new master to QUEUED
  UPDATE x_service_order_stage
  SET status                     = ip_queued_status
  WHERE account_group_member_id IN
    (SELECT objid
    FROM x_account_group_member
    WHERE account_group_id = ip_account_group_id
    AND UPPER(status)     <> 'EXPIRED'
    AND master_flag        = 'Y'
    )
  --CR39391 - Commented this line and added below --AND ( UPPER(status) NOT IN ('FAILED','COMPLETED','PROCESSING','DELETED','SIM_PENDING')
  AND ( (UPPER(status) NOT IN ('FAILED','COMPLETED','PROCESSING','DELETED','SIM_PENDING','CASE_PENDING') ) OR
  (UPPER(status)='SIM_PENDING' and sim is not null) ) ; -- To restrict staging records to be reset to queued in a never-ending loop
--CR39391 -  ends

  op_err_code           := 0;
  op_err_msg            := 'Success';

EXCEPTION
  WHEN OTHERS THEN
    -- Log error message
    log_error( ip_error_text => 'SQLERRM: ' || SQLERRM, ip_error_date => SYSDATE, ip_action => 'exception when others clause for ip_account_group_id = ' || ip_account_group_id || ' , ip_queued_status = ' || ip_queued_status, ip_key => ip_account_group_id, ip_program_name => 'brand_x_pkg.reassign_service_order_master');
    op_err_code := 1;
    op_err_msg  := 'Unhandled exception : ' || Sqlerrm;
    RAISE;
END reassign_service_order_master;
--
--
-- Added on 11/10/2014 by phani kolipakula to update service order stage
PROCEDURE update_service_order_stage (ip_service_order_stage_id  IN  NUMBER,
                                      ip_account_group_member_id IN  NUMBER,
                                      ip_esn                     IN  VARCHAR2,
                                      ip_sim                     IN  VARCHAR2,
                                      ip_zipcode                 IN  VARCHAR2,
                                      ip_pin                     IN  VARCHAR2,
                                      ip_service_plan_id         IN  NUMBER,
                                      ip_case_id                 IN  NUMBER,
                                      ip_status                  IN  VARCHAR2,
                                      ip_type                    IN  VARCHAR2,
                                      ip_program_param_id        IN  NUMBER,
                                      ip_pmt_source_id           IN  VARCHAR2,
                                      op_err_code                OUT NUMBER,
                                      op_err_msg                 OUT VARCHAR2)
AS
  l_service_plan_id NUMBER       := ip_service_plan_id;
  l_esn             VARCHAR2(30) := ip_esn;
BEGIN

  IF ip_service_order_stage_id IS NULL THEN
    op_err_code                := 2;
    op_err_msg                 := 'service order stage objid cannot be blank';
    RETURN;
  END IF;

  IF l_esn IS NULL THEN
    BEGIN
      SELECT esn
      INTO l_esn
      FROM x_service_order_stage
      WHERE objid = ip_service_order_stage_id;
    EXCEPTION
    WHEN OTHERS THEN
      NULL;
    END;
  END IF;

  -- temporary fix for cr37870
  IF l_esn            IS NOT NULL AND ip_pin IS NOT NULL THEN
    l_service_plan_id := get_service_plan_id ( f_esn => l_esn, f_red_code => ip_pin);
  END IF;
  --
  UPDATE x_service_order_stage
  SET esn            = NVL(l_esn,esn ) ,
    sim              = NVL(ip_sim,sim) ,
    zipcode          = NVL(ip_zipcode,zipcode) ,
    smp              = nvl2(ip_pin,convert_pin_to_smp(ip_red_code => ip_pin),smp) ,
    service_plan_id  = NVL(l_service_plan_id,service_plan_id) ,
    case_id          = NVL(ip_case_id, case_id) ,
    status           = NVL(ip_status ,status) ,
    type             = NVL(ip_type, type) ,
    program_param_id = NVL(ip_program_param_id, program_param_id) ,
    pmt_source_id    = NVL(ip_pmt_source_id, pmt_source_id ) ,
    update_timestamp = SYSDATE
  WHERE objid        = ip_service_order_stage_id;
  --AND    account_group_member_id = ip_account_group_member_id;

  ---For CR35694
  UPDATE x_service_order_stage
  SET service_plan_id            = NVL(l_service_plan_id,service_plan_id)
  WHERE account_group_member_id IN
    (SELECT objid
    FROM x_account_group_member
    WHERE account_group_id IN
      (SELECT account_group_id
      FROM x_account_group_member
      WHERE esn  = l_esn
      AND status = 'PENDING_ENROLLMENT'
      )
    AND status = 'PENDING_ENROLLMENT'
    )
--CR39391 - commented this and added below -- AND status = 'PAYMENT_PENDING';
    AND  ( (status = 'PAYMENT_PENDING') or (status='SIM_PENDING' and sim is not null) );
--CR39391 -  Ends

  UPDATE x_account_group
  SET service_plan_id = NVL(l_service_plan_id, service_plan_id)
  WHERE objid        IN
    (SELECT account_group_id
    FROM x_account_group_member
    WHERE esn  = l_esn
    AND status = 'PENDING_ENROLLMENT'
    );

  op_err_code := 0;
  op_err_msg  := 'Success';

EXCEPTION
  WHEN OTHERS THEN
    -- Log error message
    log_error( ip_error_text => 'SQLERRM: ' || SQLERRM, ip_error_date => SYSDATE, ip_action => 'exception when others clause for ip_service_order_stage_id = ' || ip_service_order_stage_id || ' , ip_account_group_member_id = ' || ip_account_group_member_id || ' , ip_esn = ' || ip_esn || ' , ip_sim = ' || ip_sim, ip_key => ip_service_order_stage_id, ip_program_name => 'brand_x_pkg.update_service_order_stage');
    op_err_code := 1;
    op_err_msg  := 'Unhandled exception : ' || Sqlerrm;
    RAISE;
END update_service_order_stage;
--
--
-- Added on 11/10/2014 by phani kolipakula to create account group benefit
PROCEDURE create_account_group_benefit (ip_account_group_id         IN  NUMBER,
                                        ip_service_plan_id          IN  NUMBER,
                                        ip_status                   IN  VARCHAR2,
                                        ip_start_date               IN  DATE,
                                        ip_end_date                 IN  DATE,
                                        ip_call_trans_id            IN  NUMBER,
                                        op_account_group_benefit_id OUT NUMBER,
                                        op_err_code                 OUT NUMBER,
                                        op_err_msg                  OUT VARCHAR2)
AS
BEGIN

  -- Required parameters
  IF ip_account_group_id IS NULL OR ip_service_plan_id IS NULL THEN
    --
    op_err_code := 2;
    op_err_msg  := 'account group id and service plan id must not be blank.';
    -- Exit the program
    RETURN;
  END IF;

  -- Create the account group benefit record
  INSERT INTO x_account_group_benefit
    (
      objid ,
      account_group_id ,
      service_plan_id ,
      status ,
      start_date ,
      end_date ,
      call_trans_id ,
      insert_timestamp ,
      update_timestamp
    )
    VALUES
    (
      sa.sequ_account_group_benefit.NEXTVAL ,
      ip_account_group_id ,
      ip_service_plan_id ,
      ip_status ,
      ip_start_date ,
      ip_end_date ,
      ip_call_trans_id ,
      SYSDATE ,
      SYSDATE
    )
  RETURNING objid
  INTO op_account_group_benefit_id;

  op_err_code := 0;
  op_err_msg  := 'Success';

EXCEPTION
  WHEN OTHERS THEN
    -- Log error message
    log_error( ip_error_text => 'SQLERRM: ' || SQLERRM, ip_error_date => SYSDATE, ip_action => 'exception when others clause for ip_account_group_id = ' || ip_account_group_id || ' , ip_service_plan_id = ' || ip_service_plan_id || ' , ip_status = ' || ip_status || ' , ip_start_date = ' || ip_start_date || ' , ip_end_date = ' || ip_end_date, ip_key => ip_account_group_id, ip_program_name => 'brand_x_pkg.create_account_group_benefit');
    op_err_code := 1;
    op_err_msg  := 'Unhandled exception : ' || SQLERRM;
    RAISE;
END create_account_group_benefit;
--
--
-- Added on 11/10/2014 by phani kolipakula to update account group benefit
PROCEDURE update_account_group_benefit (ip_account_group_benefit_id  IN  NUMBER,
                                        ip_account_group_id          IN  NUMBER,
                                        ip_service_plan_id           IN  NUMBER,
                                        ip_status                    IN  VARCHAR2,
                                        ip_start_date                IN  DATE,
                                        ip_end_date                  IN  DATE,
                                        ip_call_trans_id             IN  NUMBER,
                                        op_err_code                  OUT NUMBER,
                                        op_err_msg                   OUT VARCHAR2)
AS
BEGIN

  UPDATE x_account_group_benefit
  SET service_plan_id  = NVL(ip_service_plan_id, service_plan_id) ,
    status             = NVL(ip_status, status) ,
    start_date         = NVL(ip_start_date, start_date) ,
    end_date           = NVL(ip_end_date, end_date) ,
    call_trans_id      = NVL(ip_call_trans_id,call_trans_id) ,
    update_timestamp   = SYSDATE
  WHERE objid          = ip_account_group_benefit_id
  AND account_group_id = ip_account_group_id;

  op_err_code         := 0;
  op_err_msg          := 'Success';

EXCEPTION
  WHEN OTHERS THEN
    -- Log error message
    log_error( ip_error_text => 'SQLERRM: ' || SQLERRM, ip_error_date => SYSDATE, ip_action => 'exception when others clause for ip_account_group_benefit_id = ' || ip_account_group_benefit_id || ' , ip_account_group_id = ' || ip_account_group_id || ' , ip_service_plan_id = ' || ip_service_plan_id || ' , ip_status = ' || ip_status || ' , ip_start_date = ' || ip_start_date || ' , ip_end_date = ' || ip_end_date, ip_key => ip_account_group_benefit_id, ip_program_name => 'brand_x_pkg.update_account_group_benefit');
    op_err_code := 1;
    op_err_msg  := 'Unhandled exception : ' || Sqlerrm;
    RAISE;
END update_account_group_benefit;
--
--
-- Added on 11/06/2014 by Juda Pena to get member status and type (x_service_order_stage) information
FUNCTION get_group_status (ip_account_group_id IN  NUMBER) RETURN VARCHAR2
IS
  -- Get the member information
  CURSOR c_get_status
  IS
    SELECT status FROM x_account_group WHERE objid = ip_account_group_id;

  status_rec c_get_status%ROWTYPE;

BEGIN

  -- Retrieve the information
  OPEN c_get_status;
  FETCH c_get_status INTO status_rec;
  CLOSE c_get_status;

  -- Return output
  RETURN(status_rec.status);

EXCEPTION
  WHEN OTHERS THEN
    RETURN(NULL);
END get_group_status;
--
--
-- Added on 11/06/2014 by Juda Pena to get member status and type (x_service_order_stage) information
PROCEDURE get_group_master (ip_account_group_id             IN  NUMBER,
                            ip_so_status                    IN VARCHAR2,
                            op_account_group_member_id      OUT NUMBER,
                            op_account_group_status         OUT VARCHAR2,
                            op_account_group_member_status  OUT VARCHAR2,
                            op_type                         OUT VARCHAR2,
                            op_so_stage_objid               OUT NUMBER,
                            op_err_code                     OUT NUMBER,
                            op_err_msg                      OUT VARCHAR2)
AS
  -- Get the member information
  CURSOR c_get_member_info
  IS
    SELECT agm.objid,
      ag.status account_group_status,
      agm.status,
      sos.type,
      sos.objid
    FROM x_account_group_member agm,
      x_service_order_stage sos,
      x_account_group ag
    WHERE agm.account_group_id = ip_account_group_id
    AND agm.master_flag        = 'Y'
    AND agm.objid              = sos.account_group_member_id
    AND agm.account_group_id   = ag.objid
      --CR39391 - Added SIM_PENDING to below condition
    AND sos.status IN ('PAYMENT_PENDING','COMPLETED','SIM_PENDING')
      -- Added by Juda for CR34443
    ORDER BY (
      CASE sos.status
        WHEN 'PAYMENT_PENDING'
        THEN 1
        WHEN 'COMPLETED'
        THEN 2
        ELSE 3
      END );

BEGIN

  -- Retrieve the information
  OPEN c_get_member_info;
  FETCH c_get_member_info
  INTO op_account_group_member_id,
    op_account_group_status,
    op_account_group_member_status,
    op_type,
    op_so_stage_objid;
  --
  IF c_get_member_info%NOTFOUND THEN
    CLOSE c_get_member_info;
    --
    op_err_code := 2;
    op_err_msg  := 'Member information was not found.';
    -- Exit the program whenever an error occured
    RETURN;
    --
  ELSE
    CLOSE c_get_member_info;
  END IF;

  op_err_code := 0;
  op_err_msg  := 'Success';

EXCEPTION
  WHEN OTHERS THEN
    -- Log error message
    log_error( ip_error_text => 'SQLERRM: ' || SQLERRM, ip_error_date => SYSDATE, ip_action => 'exception when others clause for ip_account_group_id = ' || ip_account_group_id || ' , ip_so_status = ' || ip_so_status, ip_key => ip_account_group_id, ip_program_name => 'brand_x_pkg.get_group_master');
    op_err_code := 1;
    op_err_msg  := 'Unhandled exception : ' || SQLERRM;
    RAISE;
END get_group_master;
--
--
-- Added by Juda Pena on 03/03/2015 to be used by CBO to provide the get account group summary data
PROCEDURE get_account_group_summary (ip_web_objid         IN  NUMBER,   -- optional
                                     ip_s_login_name      IN  VARCHAR2, -- optional
                                     ip_account_group_id  IN  NUMBER,   -- optional
                                     ip_bus_org_id        IN  VARCHAR2, -- mandatory
                                     op_refcursor         OUT SYS_REFCURSOR,
                                     op_err_code          OUT NUMBER,
                                     op_err_msg           OUT VARCHAR2)
AS
BEGIN
  --
  OPEN op_refcursor FOR SELECT web.objid webobjid,
  pi.part_serial_no esn ,
  conpi.x_esn_nick_name esn_nick_name,
  NVL(conpi.x_is_default, 0) is_default,
  NVL(conpi.x_transfer_flag, 0) transfer_flag,
  web.web_user2contact web_contact_objid,
  pi.x_part_inst2contact part_contact_objid,
  code.x_code_name code_name,
  code.x_code_number code_number,
  bus.org_id bus_orgid,
  pi.x_port_in is_portin,
  pc.name pc_name,
  conpi.x_verified is_verified,
  (SELECT 'Y'
  FROM table_part_inst b
  WHERE b.part_to_esn2part_inst = pi.objid
  AND b.x_domain                = 'LINES'
  AND x_part_inst_status       IN (37,38,39,73)
  AND NOT EXISTS
    (SELECT 1
    FROM table_case t_case,
      table_condition t_cond
    WHERE t_case.x_esn              = pi.part_serial_no
    AND t_case.case_state2condition = t_cond.objid
    AND UPPER(t_cond.title) NOT LIKE 'CLOSE%'
    AND UPPER(t_case.title) LIKE '%SIM%'
    )
  AND ROWNUM = 1
  ) reserved_line_available,
  pi.x_hex_serial_no,
  (SELECT UPPER(pcv.x_param_value)
  FROM table_x_part_class_values PCV,
    table_x_part_class_params PCP
  WHERE 1                   = 1
  AND pcp.x_param_name      = 'OPERATING_SYSTEM'
  AND pcv.value2class_param = pcp.objid
  AND pcv.value2part_class  = pc.objid
  AND ROWNUM                = 1
  ) operating_sys,
  web.s_login_name s_login_name,
  ag.account_group_name group_name ,
  ag.program_enrolled_id group_prog_enroll_id ,
  ag.end_date group_end_date,
  ag.service_plan_feature_date group_plan_feature_dt ,
  ag.service_plan_id group_plan_id ,
  ag.start_date group_start_dt,
  ag.status group_status ,
  agm.master_flag esn_master_flag ,
  agm.account_group_id group_id,
  agm.esn group_esn_no ,
  agm.member_order esn_order ,
  agm.start_date esn_start_dt ,
  agm.end_date esn_end_date,
  agm.status group_esn_status ,
  agm.program_param_id esn_prog_id FROM table_x_code_table code,
  table_part_num pn,
  table_mod_level ml,
  table_part_inst pi,
  table_x_contact_part_inst conpi,
  table_bus_org bus,
  table_web_user web,
  table_part_class pc ,
  x_account_group_member agm ,
  x_account_group ag WHERE 1 = 1 AND ( ( web.objid = NVL(ip_web_objid, web.objid) ) AND ( web.s_login_name = NVL(ip_s_login_name,web.s_login_name) ) AND ( ag.objid = NVL(ip_account_group_id,ag.objid) ) ) AND web.web_user2bus_org = bus.objid AND bus.s_org_id = ip_bus_org_id AND conpi.x_contact_part_inst2contact(+) = web.web_user2contact AND pn.part_num2bus_org = bus.objid AND pi.objid(+) = conpi.x_contact_part_inst2part_inst AND pi.n_part_inst2part_mod = ml.objid AND ml.part_info2part_num = pn.objid AND code.objid(+) = pi.status2x_code_table AND pn.part_num2part_class = pc.objid AND agm.esn(+) = pi.part_serial_no AND agm.account_group_id = ag.objid (+) ORDER BY group_id,
  group_esn_status;

  -- Return the output
  op_err_code := 0;
  op_err_msg  := 'Success';

EXCEPTION
  WHEN OTHERS THEN
    -- Log error message
    log_error( ip_error_text => 'SQLERRM: ' || SQLERRM, ip_error_date => SYSDATE, ip_action => 'exception when others clause for ip_web_objid = ' || ip_web_objid || ' , ip_s_login_name = ' || ip_s_login_name || ' , ip_account_group_id = ' ||ip_account_group_id, ip_key => ip_web_objid, ip_program_name => 'brand_x_pkg.get_account_group_summary');
    op_err_code := 1;
    op_err_msg  := 'Unhandled exception : ' || SQLERRM;
    RAISE;
END get_account_group_summary;
--
--
-- Added overloaded on 11/06/2014 by Juda Pena to get member account information
PROCEDURE read_account_group (ip_esn        IN  VARCHAR2,
                              op_refcursor  OUT SYS_REFCURSOR,
                              op_err_code   OUT NUMBER,
                              op_err_msg    OUT VARCHAR2)
AS
BEGIN

  OPEN op_refcursor FOR SELECT ag.objid account_group_id,
  ag.account_group_name,
  (SELECT esn
  FROM x_account_group_member
  WHERE account_group_id = ag.objid
  AND master_flag        = 'Y'
  ),
  ag.service_plan_id,
  ag.service_plan_feature_date,
  ag.program_enrolled_id,
  ag.status,
  ag.start_date,
  ag.end_date,
  agm.objid account_group_member_id,
  agm.esn,
  agm.member_order,
  agm.site_part_id,
  agm.promotion_id,
  agm.status,
  agm.subscriber_uid,
  NULL program_param_id,
  agm.start_date,
  agm.end_date  FROM x_account_group ag,
  x_account_group_member agm WHERE ( ( ag.objid IN
      (SELECT account_group_id
      FROM x_account_group_member
      WHERE esn                         = ip_esn
      AND UPPER(status)                <> 'EXPIRED'
      ) ) ) AND agm.account_group_id(+) = ag.objid AND UPPER( agm.status(+) ) <> 'EXPIRED' ORDER BY agm.master_flag DESC;

  -- Return the output
  op_err_code := 0;
  op_err_msg  := 'Success';

EXCEPTION
  WHEN OTHERS THEN
    -- Log error message
    log_error( ip_error_text => 'SQLERRM: ' || SQLERRM, ip_error_date => SYSDATE, ip_action => 'exception when others clause for ip_esn = ' || ip_esn, ip_key => ip_esn, ip_program_name => 'brand_x_pkg.read_account_group');
    op_err_code := 1;
    op_err_msg  := 'Unhandled exception : ' || SQLERRM;
    RAISE;
END read_account_group;
--
--
-- Added on 11/06/2014 by Juda Pena to get member status and type (x_service_order_stage) information
PROCEDURE read_account_group  (ip_account_group_id  IN  NUMBER,
                               ip_esn               IN  VARCHAR2,
                               op_account_group_tab OUT account_group_member_tab,
                               op_err_code          OUT NUMBER,
                               op_err_msg           OUT VARCHAR2)
AS
--CR50270
v_service_end_date date;
v_next_refill_date date;

BEGIN

  -- Initialize the table
  op_account_group_tab := account_group_member_tab();
  IF ip_esn            IS NOT NULL THEN
    -- Get the account group data to be return in the object table
    --CR50270
    v_service_end_date := sa.CUSTOMER_INFO.get_service_forecast_due_date (ip_esn);

    BEGIN
       SELECT x_expire_dt
         INTO v_next_refill_date
         FROM table_site_part s,
              table_part_inst p
        WHERE s.objid = p.x_part_inst2site_part
          AND p.part_serial_no = ip_esn;
    EXCEPTION WHEN OTHERS THEN

        v_next_refill_date := NULL;

    END;

    SELECT account_group_member_type ( ag.objid , ag.account_group_name,
      (SELECT esn AS master_esn
      FROM x_account_group_member
      WHERE account_group_id = ag.objid
      AND master_flag        = 'Y'
      ), ag.service_plan_id, ag.service_plan_feature_date, ag.program_enrolled_id, ag.status, ag.start_date, ag.end_date, agm.objid, agm.esn, agm.member_order, agm.site_part_id, agm.promotion_id, agm.status, agm.subscriber_uid, NULL , agm.start_date , agm.end_date, v_service_end_date, v_next_refill_date ) BULK COLLECT
    INTO op_account_group_tab
    FROM x_account_group ag,
      x_account_group_member agm
    WHERE ag.objid IN
      (SELECT account_group_id
      FROM x_account_group_member
      WHERE esn          = ip_esn
      AND UPPER(status) <> 'EXPIRED'
      ) -- When an ESN is passed, use only the ESN (ignore the ACCOUNT_GROUP_ID)
    AND agm.account_group_id(+) = ag.objid
    AND UPPER( agm.status(+) ) <> 'EXPIRED'
    ORDER BY agm.master_flag DESC;
    --
  ELSIF ip_account_group_id IS NOT NULL THEN
    -- Get the account group data to be return in the object table
    --CR50270 sa.CUSTOMER_INFO.get_service_forecast_due_date (agm.esn)
    SELECT account_group_member_type ( ag.objid , ag.account_group_name,
      (SELECT esn AS master_esn
      FROM x_account_group_member
      WHERE account_group_id = ag.objid
      AND master_flag        = 'Y'
      ), ag.service_plan_id, ag.service_plan_feature_date, ag.program_enrolled_id, ag.status, ag.start_date, ag.end_date, agm.objid, agm.esn, agm.member_order, agm.site_part_id, agm.promotion_id, agm.status, agm.subscriber_uid, NULL , agm.start_date , agm.end_date, sa.CUSTOMER_INFO.get_service_forecast_due_date (agm.esn),
      (SELECT x_expire_dt
         FROM table_site_part s,
              table_part_inst p
        WHERE s.objid = p.x_part_inst2site_part
          AND p.part_serial_no = agm.esn
      )
      ) BULK COLLECT
    INTO op_account_group_tab
    FROM x_account_group ag,
      x_account_group_member agm
    WHERE ag.objid              = ip_account_group_id -- When the ACCOUNT_GROUP_ID is passed use the ACCOUNT_GROUP_ID (get all members)
    AND agm.account_group_id(+) = ag.objid
    AND UPPER( agm.status(+) ) <> 'EXPIRED'
    ORDER BY agm.master_flag DESC;
    --
  ELSE
    op_err_code := 2;
    op_err_msg  := 'ESN/GROUP ID NOT PASSED';
    RETURN;
  END IF;
  -- If rows were returned set to success
  IF NVL(op_account_group_tab.COUNT,0) > 0 THEN
    -- Set output messages to success
    op_err_code := 0;
    op_err_msg  := 'Success';
    --
  ELSE
    -- Set output messages when record(s) was not found
    op_err_code := 2;
    op_err_msg  := 'Group Not Found';
  END IF;
  --
EXCEPTION
  WHEN OTHERS THEN
    -- Log error message
    log_error( ip_error_text => 'SQLERRM: ' || SQLERRM, ip_error_date => SYSDATE, ip_action => 'exception when others clause for ip_account_group_id = ' || ip_account_group_id || ' , ip_esn = ' || ip_esn, ip_key => ip_account_group_id, ip_program_name => 'brand_x_pkg.read_account_group');
    op_account_group_tab := NULL;
    op_err_code          := 1;
    op_err_msg           := 'Unhandled exception : ' || SQLERRM;
    RAISE;
END read_account_group;
--
--
PROCEDURE read_account_group_member (ip_account_group_id        IN NUMBER,
                                     ip_account_group_member_id IN NUMBER,
                                     op_account_group_tab       OUT account_group_member_tab,
                                     op_err_code                OUT NUMBER,
                                     op_err_msg                 OUT VARCHAR2)
AS
BEGIN

  -- Initialize the table
  op_account_group_tab := account_group_member_tab();

  -- Get the account group data to be return in the object table
    --CR50270 sa.CUSTOMER_INFO.get_service_forecast_due_date (agm.esn)
  SELECT account_group_member_type ( ag.objid , ag.account_group_name,
    (SELECT esn AS master_esn
    FROM x_account_group_member
    WHERE account_group_id = ag.objid
    AND master_flag        = 'Y'
    AND UPPER(status)     <> 'EXPIRED'
    ) , ag.service_plan_id, ag.service_plan_feature_date, ag.program_enrolled_id, ag.status, ag.start_date, ag.end_date, agm.objid, agm.esn, agm.member_order, agm.site_part_id, agm.promotion_id, agm.status, agm.subscriber_uid, NULL, agm.start_date , agm.end_date, sa.CUSTOMER_INFO.get_service_forecast_due_date (agm.esn),
      (SELECT x_expire_dt
         FROM table_site_part s,
              table_part_inst p
        WHERE s.objid = p.x_part_inst2site_part
          AND p.part_serial_no = agm.esn
      )
      ) BULK COLLECT
  INTO op_account_group_tab
  FROM x_account_group ag,
    x_account_group_member agm
  WHERE ( ( agm.objid             = ip_account_group_member_id
  AND ip_account_group_member_id IS NOT NULL) -- When member_id is passed, use only the ESN (ignore the ACCOUNT_GROUP_ID)
  OR ( agm.account_group_id       = ip_account_group_id
  AND ip_account_group_member_id IS NULL) -- When the ACCOUNT_GROUP_ID is passed use the ACCOUNT_GROUP_ID (get all members)
    )
  AND agm.account_group_id = ag.objid;

  -- Set output messages to success
  op_err_code := 0;
  op_err_msg  := 'Success';
  --
EXCEPTION
  WHEN OTHERS THEN
    -- Log error message
    log_error( ip_error_text => 'SQLERRM: ' || SQLERRM, ip_error_date => SYSDATE, ip_action => 'exception when others clause for ip_account_group_id = ' || ip_account_group_id || ' , ip_account_group_member_id = ' || ip_account_group_member_id, ip_key => ip_account_group_id, ip_program_name => 'brand_x_pkg.read_account_group_member');
    op_account_group_tab := NULL;
    op_err_code          := 1;
    op_err_msg           := 'Unhandled exception : ' || SQLERRM;
    RAISE;
END read_account_group_member;
--
--
-- Added on 10/28/2014 by Juda Pena to set the account group master esn
PROCEDURE set_account_group_master (ip_account_group_id IN NUMBER,
                                    ip_esn              IN VARCHAR2,
                                    op_err_code         OUT VARCHAR2,
                                    op_err_msg          OUT VARCHAR2)
AS

  -- Search for an esn in a group
  CURSOR c_validate_esn
  IS
    SELECT 1
    FROM   x_account_group_member
    WHERE  account_group_id = ip_account_group_id
    AND    esn              = ip_esn;

  -- Get the master esn of the group
  CURSOR c_get_master_esn
  IS
    SELECT esn
    FROM   x_account_group_member
    WHERE  account_group_id = ip_account_group_id
    AND    master_flag      = 'Y';

  -- Get the program enrolled id
  CURSOR c_get_program_enrolled
  IS
    SELECT pe.objid program_enrolled_id
    FROM   x_program_enrolled pe,
           x_service_plan_site_part spsp,
           table_site_part tsp,
           x_program_parameters pp,
           mtm_sp_x_program_param mtm,
           x_service_plan sp
    WHERE  1                           = 1
    AND    pe.x_esn                    = ip_esn
    AND    pe.pgm_enroll2site_part     = spsp.table_site_part_id
    AND    spsp.table_site_part_id     = tsp.objid
    AND    pe.pgm_enroll2pgm_parameter = pp.objid
    AND    pp.objid                    = mtm.x_sp2program_param
    AND    mtm.program_para2x_sp       = spsp.x_service_plan_id
    AND    sp.objid                    = mtm.program_para2x_sp;

  validate_esn_rec      c_validate_esn%ROWTYPE;
  program_enrolled_rec  c_get_program_enrolled%ROWTYPE;
  old_master_esn_rec    c_get_master_esn%ROWTYPE;

BEGIN

  OPEN c_validate_esn;
  FETCH c_validate_esn INTO validate_esn_rec;
  IF c_validate_esn%NOTFOUND THEN
    -- Close the cursor and continue
    CLOSE c_validate_esn;
    -- Set error code
    op_err_code := 2;
    op_err_msg  := 'ESN does not belong to the account group';
    --
    -- Exit the program whenever an error occured
    RETURN;
    --
  ELSE
    -- Close the cursor and continue
    CLOSE c_validate_esn;
  END IF;

  -- Get the esn master
  OPEN c_get_master_esn;
  FETCH c_get_master_esn INTO old_master_esn_rec;
  CLOSE c_get_master_esn;

  -- Remove the previous master ESN
  UPDATE x_account_group_member
  SET    master_flag      = 'N',
         update_timestamp = SYSDATE
  WHERE  account_group_id = ip_account_group_id
  AND    master_flag      = 'Y';

  -- Set the new master ESN
  UPDATE x_account_group_member
  SET master_flag        = 'Y',
    update_timestamp     = SYSDATE
  WHERE account_group_id = ip_account_group_id
  AND esn                = ip_esn
  AND UPPER(status)     <> 'EXPIRED';
  -- Validate if master was set correctly
  IF SQL%ROWCOUNT <> 1 THEN
    -- Set error code
    op_err_code := 3;
    op_err_msg  := 'Master ESN was not changed properly';
    --
    -- Exit the program whenever an error occured
    RETURN;
  END IF;
  -- Retrieve the program enrolled id
  BEGIN
    SELECT objid program_enrolled_id
    INTO program_enrolled_rec
    FROM x_program_enrolled
    WHERE x_esn = ip_esn;
  EXCEPTION
  WHEN too_many_rows THEN
    -- Reset rowtype record to NULL
    program_enrolled_rec := NULL;
    -- Get the program enrolled
    OPEN c_get_program_enrolled;
    FETCH c_get_program_enrolled INTO program_enrolled_rec;
    CLOSE c_get_program_enrolled;
  WHEN no_data_found THEN
    -- Set error code
    op_err_code := 4;
    op_err_msg  := 'Cannot find the program enrolled id for the provided esn';
    --
    -- Exit the program whenever an error occured
    RETURN;
  END;
  -- Update program enrolled id when available
  IF program_enrolled_rec.program_enrolled_id IS NOT NULL THEN
    -- Updating the program_enrolled_id
    UPDATE x_account_group
    SET program_enrolled_id = program_enrolled_rec.program_enrolled_id
    WHERE objid             = ip_account_group_id;
  ELSE
    -- Set error code
    op_err_code := 5;
    op_err_msg  := 'Cannot find the program enrolled id for the provided esn';
    --
    -- Exit the program whenever an error occured
    RETURN;
  END IF;
  -- Update new esn part inst objids for the queued redemption cards
  UPDATE table_part_inst pi_pin
  SET pi_pin.part_to_esn2part_inst =
    (SELECT objid
    FROM table_part_inst
    WHERE part_serial_no = ip_esn -- New Master ESN
    )
  WHERE pi_pin.part_to_esn2part_inst =
    (SELECT objid
    FROM table_part_inst
    WHERE part_serial_no = old_master_esn_rec.esn -- Old Master ESN
    )
  AND pi_pin.x_part_inst_status
    ||'' = '400'; -- Queued Redemption Cards

  -- Set as successful execution
  op_err_code := 0;
  op_err_msg  := 'Success';

EXCEPTION
  WHEN OTHERS THEN
    -- Log error message
    log_error( ip_error_text => 'SQLERRM: ' || SQLERRM, ip_error_date => SYSDATE, ip_action => 'exception when others clause for ip_account_group_id = ' || ip_account_group_id || ' , ip_esn = ' || ip_esn, ip_key => ip_account_group_id, ip_program_name => 'brand_x_pkg.set_account_group_master');
    op_err_code := 1;
    op_err_msg  := 'Unhandled exception : ' || SQLERRM;
    RAISE;
END set_account_group_master;
--
--
-- Test Stored Procedure to find an esn list, plan and red card available
PROCEDURE get_tw_test_esns (ip_part_class_name  IN  VARCHAR2,
                            op_service_plan_id  OUT NUMBER,
                            op_market_name      OUT VARCHAR2,
                            op_esn_list         OUT VARCHAR2,
                            op_red_card_list    OUT VARCHAR2)
IS
  -- Get the service plan + number of lines based on the part class name
  CURSOR c_get_service_plan
  IS
    SELECT a.sp_objid service_plan_id,
      a.sp_mkt_name market_name,
      brand_x_pkg.get_number_of_lines ( ip_service_plan_id => a.sp_objid) number_of_lines
    FROM adfcrm_serv_plan_class_matview a
    WHERE part_class_objid IN
      ( SELECT objid FROM table_part_class WHERE name = ip_part_class_name );

  -- rowtype to hold cursor values
  service_plan_rec c_get_service_plan%ROWTYPE;
  -- Get the esns based on the service plan
  --CURSOR get_phones_esns (p_service_plan_id NUMBER) IS
  --  select pi_esn.part_serial_no esn
  --  from   table_part_num pn,
  --         table_mod_level ml_esn,
  --         table_part_inst pi_esn
  --  where  1 = 1
  --  and    pn.domain = 'PHONES'
  --  and    pn.part_number like 'TW%'
  --  and    ml_esn.part_info2part_num  = pn.objid
  --  and    pi_esn.n_part_inst2part_mod = ml_esn.objid
  --  AND    pi_esn.x_part_inst_status = '50'
  --  AND NOT EXISTS ( SELECT 1
  --                   FROM   x_account_group_member
  --                   WHERE  esn = pi_esn.part_serial_no
  --                 )
  --  AND NOT EXISTS ( SELECT 1
  --                   FROM   x_service_order_stage
  --                   WHERE  esn = pi_esn.part_serial_no
  --                 )
  --  AND    brand_x_pkg.valid_service_plan_esn ( ip_service_plan_id => p_service_plan_id,
  --                                              ip_esn             => pi_esn.part_serial_no) = 'Y';
  -- Get a random ESN list based on a compatible service plan
  CURSOR get_phones_esns (p_service_plan_id NUMBER)
  IS
    SELECT row_num,
      esn
    FROM
      (SELECT ROWNUM row_num,
        pi_esn.part_serial_no esn,
        COUNT(1) OVER (ORDER BY 1 RANGE UNBOUNDED PRECEDING) count_rows
      FROM table_part_num pn,
        table_mod_level ml_esn,
        table_part_inst pi_esn
      WHERE 1       = 1
      AND pn.domain = 'PHONES'
      AND pn.part_number LIKE 'TW%'
      AND ml_esn.part_info2part_num   = pn.objid
      AND pi_esn.n_part_inst2part_mod = ml_esn.objid
      AND pi_esn.x_part_inst_status   = '50'
        --AND    pn.part_number IN ('TWLG236C')
      AND NOT EXISTS
        ( SELECT 1 FROM x_account_group_member WHERE esn = pi_esn.part_serial_no
        )
    AND NOT EXISTS
      ( SELECT 1 FROM x_service_order_stage WHERE esn = pi_esn.part_serial_no
      )
    AND brand_x_pkg.valid_service_plan_esn ( ip_service_plan_id => p_service_plan_id, ip_esn => pi_esn.part_serial_no) = 'Y'
      )
    WHERE row_num BETWEEN NVL(FLOOR(DBMS_RANDOM.VALUE( low => 1, high => count_rows)),1) AND count_rows;

    -- Query to pick a valid redemption card to activate the phone
    CURSOR c_pick_red_card (p_esn VARCHAR2, p_service_plan_id NUMBER, p_red_code VARCHAR2)
    IS
      SELECT row_num,
        x_red_code
      FROM
        (SELECT
          /*+  use_nl(pi_card) use_nl(pn_card) use_nl(ml_card) */
          ROWNUM row_num,
          pi_card.x_red_code,
          COUNT(1) OVER (ORDER BY 1 RANGE UNBOUNDED PRECEDING) count_rows
        FROM
          ( SELECT DISTINCT sp.objid service_plan_id,
            d.part_class_id phone_pc_objid,
            b.part_class_id card_pc_objid
          FROM sa.x_serviceplanfeaturevalue_def a,
            sa.mtm_partclass_x_spf_value_def b,
            sa.x_serviceplanfeaturevalue_def c,
            sa.mtm_partclass_x_spf_value_def d,
            sa.x_serviceplanfeature_value spfv,
            sa.x_service_plan_feature spf,
            sa.x_service_plan sp
          WHERE a.objid        = b.spfeaturevalue_def_id
          AND b.part_class_id IN
            (SELECT pn.part_num2part_class
            FROM table_part_num pn
            WHERE 1       = 1
            AND pn.domain = 'REDEMPTION CARDS'
            AND pn.part_number LIKE 'TW%'
            AND EXISTS
              (SELECT 1
              FROM table_part_class
              WHERE objid = pn.part_num2part_class
              AND name    = ip_part_class_name
              )
            )
          AND c.objid          = d.spfeaturevalue_def_id
          AND d.part_class_id IN
            ( SELECT DISTINCT pn.part_num2part_class
            FROM table_part_inst pi,
              table_mod_level ml,
              table_part_num pn
            WHERE 1               = 1
            AND pi.part_serial_no = p_esn
            AND ml.objid          = pi.n_part_inst2part_mod
            AND pn.objid          = ml.part_info2part_num
            AND pn.domain         = 'PHONES'
            AND pn.part_number LIKE 'TW%'
            )
          AND a.value_name   = c.value_name
          AND spfv.value_ref = a.objid
          AND spf.objid      = spfv.spf_value2spf
          AND sp.objid       = spf.sp_feature2service_plan
          AND sp.objid       = p_service_plan_id
          ) tab1,
          table_part_num pn_card,
          table_mod_level ml_card,
          table_part_inst pi_card
        WHERE 1                          = 1
        AND pn_card.part_num2part_class  = tab1.card_pc_objid
        AND ml_card.part_info2part_num   = pn_card.objid
        AND pi_card.n_part_inst2part_mod = ml_card.objid
        AND pi_card.x_part_inst_status   = '42'
          --AND NOT EXISTS ( SELECT 1
          --                 FROM   x_service_order_stage
          --                 WHERE  convert_smp_to_pin(ip_smp => smp) = pi_card.x_red_code
          --               )
        AND ( (pi_card.x_red_code = p_red_code
        AND p_red_code           IS NOT NULL) -- Validate red code when available
        OR (p_red_code           IS NULL)     -- Ignore when it's not passed
          )
        )
      WHERE row_num BETWEEN NVL(FLOOR(DBMS_RANDOM.VALUE( low => 1, high => count_rows)),1) AND count_rows;

      -- Red card rowtype row
      red_card_rec c_pick_red_card%ROWTYPE;
      l_index NUMBER := 0;

BEGIN

      -- Set the redemption card list variable to NULL
      op_red_card_list := NULL;
      -- Get a compatible service plan based on a compatible part class name
      OPEN c_get_service_plan;
      FETCH c_get_service_plan INTO service_plan_rec;
      CLOSE c_get_service_plan;

      -- Get TOTAL_WIRELESS available phone ESNs
      FOR i IN get_phones_esns (service_plan_rec.service_plan_id)
      LOOP
        -- Set the index variable
        l_index := l_index + 1;
        -- Concatenate the next ESN to the ESN list
        op_esn_list := op_esn_list || ',' || i.esn;
        -- Pick a compatible redemption card
        OPEN c_pick_red_card (i.esn, service_plan_rec.service_plan_id, op_red_card_list);
        FETCH c_pick_red_card INTO red_card_rec;
        CLOSE c_pick_red_card;
        -- Set the output redemption card code
        op_red_card_list := red_card_rec.x_red_code;
        -- Exit when the max number of lines has been reached to the desired quantity of ESNs
        EXIT
      WHEN l_index >= service_plan_rec.number_of_lines;
      END LOOP;

      -- Set the out parameters (service plan and market name)
      op_service_plan_id := service_plan_rec.service_plan_id;
      op_market_name     := service_plan_rec.market_name;
      -- Remove the extra comma from the ESN list
      op_esn_list        := SUBSTR(op_esn_list,2);

END get_tw_test_esns;
--
--
-- Test Stored Procedure to find an esn list, plan and red card available
PROCEDURE get_tw_test_esns2 (ip_part_class_name  IN  VARCHAR2,
                             op_service_plan_id  OUT NUMBER,
                             op_market_name      OUT VARCHAR2,
                             op_esn_list         OUT VARCHAR2,
                             op_red_card_list    OUT VARCHAR2)
IS
    -- Get the service plan + number of lines based on the part class name
    CURSOR c_get_service_plan
    IS
      SELECT a.sp_objid service_plan_id,
        a.sp_mkt_name market_name,
        brand_x_pkg.get_number_of_lines ( ip_service_plan_id => a.sp_objid) number_of_lines
      FROM adfcrm_serv_plan_class_matview a
      WHERE part_class_objid IN
        ( SELECT objid FROM table_part_class WHERE name = ip_part_class_name );

    -- rowtype to hold cursor values
    service_plan_rec c_get_service_plan%ROWTYPE;
    -- Get the esns based on the service plan
    --CURSOR get_phones_esns (p_service_plan_id NUMBER) IS
    --  select pi_esn.part_serial_no esn
    --  from   table_part_num pn,
    --         table_mod_level ml_esn,
    --         table_part_inst pi_esn
    --  where  1 = 1
    --  and    pn.domain = 'PHONES'
    --  and    pn.part_number like 'TW%'
    --  and    ml_esn.part_info2part_num  = pn.objid
    --  and    pi_esn.n_part_inst2part_mod = ml_esn.objid
    --  AND    pi_esn.x_part_inst_status = '50'
    --  AND NOT EXISTS ( SELECT 1
    --                   FROM   x_account_group_member
    --                   WHERE  esn = pi_esn.part_serial_no
    --                 )
    --  AND NOT EXISTS ( SELECT 1
    --                   FROM   x_service_order_stage
    --                   WHERE  esn = pi_esn.part_serial_no
    --                 )
    --  AND    brand_x_pkg.valid_service_plan_esn ( ip_service_plan_id => p_service_plan_id,
    --                                              ip_esn             => pi_esn.part_serial_no) = 'Y';
    -- Get a random ESN list based on a compatible service plan
    CURSOR get_phones_esns (p_service_plan_id NUMBER)
    IS
      SELECT row_num,
        esn,
        part_number,
        RPAD(' ',18,' ') new_esn
      FROM
        (SELECT ROWNUM row_num,
          pi_esn.part_serial_no esn,
          pn.part_number,
          COUNT(1) OVER (ORDER BY 1 RANGE UNBOUNDED PRECEDING) count_rows
        FROM table_part_num pn,
          table_mod_level ml_esn,
          table_part_inst pi_esn
        WHERE 1       = 1
        AND pn.domain = 'PHONES'
        AND pn.part_number LIKE 'TW%'
        AND ml_esn.part_info2part_num   = pn.objid
        AND pi_esn.n_part_inst2part_mod = ml_esn.objid
        AND pi_esn.x_part_inst_status   = '50'
          --AND    pn.part_number IN ('TWLG236C')
        AND pn.part_num2bus_org IN
          ( SELECT objid FROM table_bus_org WHERE org_id = 'TOTAL_WIRELESS'
          )
      AND NOT EXISTS
        ( SELECT 1 FROM x_account_group_member WHERE esn = pi_esn.part_serial_no
        )
      AND NOT EXISTS
        ( SELECT 1 FROM x_service_order_stage WHERE esn = pi_esn.part_serial_no
        )
      AND brand_x_pkg.valid_service_plan_esn ( ip_service_plan_id => p_service_plan_id, ip_esn => pi_esn.part_serial_no) = 'Y'
        )
      WHERE row_num BETWEEN NVL(FLOOR(DBMS_RANDOM.VALUE( low => 1, high => count_rows)),1) AND count_rows;

      -- Query to pick a valid redemption card to activate the phone
      CURSOR c_pick_red_card (p_esn VARCHAR2, p_service_plan_id NUMBER, p_red_code VARCHAR2)
      IS
        SELECT row_num,
          x_red_code,
          part_number -- , get_test_pin(part_number) new_red_code
        FROM
          (SELECT
            /*+  use_nl(pi_card) use_nl(pn_card) use_nl(ml_card) */
            ROWNUM row_num,
            pi_card.x_red_code,
            pn_card.part_number,
            COUNT(1) OVER (ORDER BY 1 RANGE UNBOUNDED PRECEDING) count_rows
          FROM
            ( SELECT DISTINCT sp.objid service_plan_id,
              d.part_class_id phone_pc_objid,
              b.part_class_id card_pc_objid
            FROM sa.x_serviceplanfeaturevalue_def a,
              sa.mtm_partclass_x_spf_value_def b,
              sa.x_serviceplanfeaturevalue_def c,
              sa.mtm_partclass_x_spf_value_def d,
              sa.x_serviceplanfeature_value spfv,
              sa.x_service_plan_feature spf,
              sa.x_service_plan sp
            WHERE a.objid        = b.spfeaturevalue_def_id
            AND b.part_class_id IN
              (SELECT pn.part_num2part_class
              FROM table_part_num pn
              WHERE 1       = 1
              AND pn.domain = 'REDEMPTION CARDS'
              AND pn.part_number LIKE 'TW%'
              AND EXISTS
                (SELECT 1
                FROM table_part_class
                WHERE objid = pn.part_num2part_class
                AND name    = ip_part_class_name
                )
              )
            AND c.objid          = d.spfeaturevalue_def_id
            AND d.part_class_id IN
              ( SELECT DISTINCT pn.part_num2part_class
              FROM table_part_inst pi,
                table_mod_level ml,
                table_part_num pn
              WHERE 1               = 1
              AND pi.part_serial_no = p_esn
              AND ml.objid          = pi.n_part_inst2part_mod
              AND pn.objid          = ml.part_info2part_num
              AND pn.domain         = 'PHONES'
              AND pn.part_number LIKE 'TW%'
              )
            AND a.value_name   = c.value_name
            AND spfv.value_ref = a.objid
            AND spf.objid      = spfv.spf_value2spf
            AND sp.objid       = spf.sp_feature2service_plan
            AND sp.objid       = p_service_plan_id
            ) tab1,
            table_part_num pn_card,
            table_mod_level ml_card,
            table_part_inst pi_card
          WHERE 1                          = 1
          AND pn_card.part_num2part_class  = tab1.card_pc_objid
          AND ml_card.part_info2part_num   = pn_card.objid
          AND pi_card.n_part_inst2part_mod = ml_card.objid
          AND pi_card.x_part_inst_status   = '42'
            --AND NOT EXISTS ( SELECT 1
            --                 FROM   x_service_order_stage
            --                 WHERE  convert_smp_to_pin(ip_smp => smp) = pi_card.x_red_code
            --               )
          AND ( (pi_card.x_red_code = p_red_code
          AND p_red_code           IS NOT NULL) -- Validate red code when available
          OR (p_red_code           IS NULL)     -- Ignore when it's not passed
            )
          )
        WHERE row_num BETWEEN NVL(FLOOR(DBMS_RANDOM.VALUE( low => 1, high => count_rows)),1) AND count_rows;

        -- Red card rowtype row
        red_card_rec c_pick_red_card%ROWTYPE;
        l_index NUMBER := 0;

BEGIN

        -- Set the redemption card list variable to NULL
        op_red_card_list := NULL;
        -- Get a compatible service plan based on a compatible part class name
        OPEN c_get_service_plan;
        FETCH c_get_service_plan INTO service_plan_rec;
        CLOSE c_get_service_plan;

        -- Get TOTAL_WIRELESS available phone ESNs
        FOR i IN get_phones_esns (service_plan_rec.service_plan_id)
        LOOP
          -- Set the index variable
          l_index := l_index + 1;
          -- Concatenate the next ESN to the ESN list
          --op_esn_list := op_esn_list || ',' || i.esn;
          -- Generate a new esn
          -- Commented out since this code is not in CLFYTOPP (production)
          --i.new_esn := get_test_esn(i.part_number);
          -- Concatenate new esn to the esn list
          op_esn_list := op_esn_list || ',' || i.new_esn;
          -- Pick a compatible redemption card
          OPEN c_pick_red_card (i.new_esn, service_plan_rec.service_plan_id, op_red_card_list);
          FETCH c_pick_red_card INTO red_card_rec;
          CLOSE c_pick_red_card;
          -- Set the output redemption card code
          --op_red_card_list := get_test_pin(red_card_rec.part_number);
          -- Exit when the max number of lines has been reached to the desired quantity of ESNs
          EXIT
        WHEN l_index >= service_plan_rec.number_of_lines;
        END LOOP;

        -- Set the output parameters (service plan and market name)
        op_service_plan_id := service_plan_rec.service_plan_id;
        op_market_name     := service_plan_rec.market_name;
        -- Remove the extra comma from the ESN list
        op_esn_list        := SUBSTR(op_esn_list,2);

END get_tw_test_esns2;
--
--
PROCEDURE get_status_by_esn (ip_esn        IN  VARCHAR2,
                             op_min        OUT VARCHAR2,
                             op_esn        OUT VARCHAR2,
                             op_esn_status OUT VARCHAR2,
                             op_min_status OUT VARCHAR2)
IS
BEGIN

      -- Get the min and other info based on the esn
      SELECT pi_min.part_serial_no MIN,
        pi_esn.part_serial_no esn,
        pi_esn.x_part_inst_status esn_status,
        pi_min.x_part_inst_status min_status
      INTO op_min,
        op_esn,
        op_esn_status,
        op_min_status
      FROM table_part_inst pi_esn,
        table_part_inst pi_min
      WHERE 1                   = 1
      AND pi_esn.part_serial_no = ip_esn
      AND pi_esn.x_domain       = 'PHONES'
      AND pi_esn.objid          = pi_min.part_to_esn2part_inst;

EXCEPTION
  WHEN OTHERS THEN
    NULL;
END get_status_by_esn;
--
--
PROCEDURE get_status_by_min (ip_min        IN  VARCHAR2,
                             op_min        OUT VARCHAR2,
                             op_esn        OUT VARCHAR2,
                             op_esn_status OUT VARCHAR2,
                             op_min_status OUT VARCHAR2)
IS
BEGIN

    -- Get the esn and other info based on the min
    SELECT pi_min.part_serial_no MIN,
      pi_esn.part_serial_no esn,
      pi_esn.x_part_inst_status esn_status,
      pi_min.x_part_inst_status min_status
    INTO op_min,
      op_esn,
      op_esn_status,
      op_min_status
    FROM table_part_inst pi_min,
      table_part_inst pi_esn
    WHERE 1                   = 1
    AND pi_min.part_serial_no = ip_min
    AND pi_min.x_domain       = 'LINES'
    AND pi_esn.objid          = pi_min.part_to_esn2part_inst;

EXCEPTION
  WHEN OTHERS THEN
    NULL;
END get_status_by_min;
--
--
-- Added on 10/28/2014 by Juda Pena to find if an open port case exists for a min
FUNCTION port_case_exists (ip_min IN VARCHAR2) RETURN VARCHAR2
IS
  l_port_case_exists_flag VARCHAR2(1);
BEGIN

  -- Find an open port case for a provided min
  BEGIN
    SELECT 'Y'
    INTO l_port_case_exists_flag
    FROM table_x_case_detail cd
    WHERE x_name = 'CURRENT_MIN'
    AND x_value  = ip_min
    AND EXISTS
      (SELECT 1
      FROM table_case c
      WHERE c.objid = cd.detail2case
      AND EXISTS
        ( SELECT 1 FROM x_service_order_stage WHERE case_id = TO_NUMBER(c.id_number)
        )
      AND NOT EXISTS
        (SELECT 1
        FROM table_condition
        WHERE objid = c.case_state2condition
        AND s_title
          ||'' = 'CLOSED'
        )
      );
  EXCEPTION
  WHEN too_many_rows THEN
    RETURN 'Y';
  WHEN no_data_found THEN
    RETURN 'N';
  WHEN OTHERS THEN
    RETURN 'N';
  END;

  RETURN NVL(l_port_case_exists_flag, 'N');

EXCEPTION
  WHEN OTHERS THEN
    RETURN 'N';
END port_case_exists;
--
--
-- CR33453
PROCEDURE attach_pin_to_staging (ip_group_id  IN  NUMBER,
                                 ip_pin       IN  VARCHAR2,
                                 op_err_code  OUT NUMBER,
                                 op_err_msg   OUT VARCHAR2)
IS

  l_esn VARCHAR2(40):= NULL;
  l_smp VARCHAR2(40):= NULL;

BEGIN

  IF IP_GROUP_ID IS NULL OR IP_PIN IS NULL THEN
    OP_ERR_CODE  := 2;
    OP_ERR_MSG   := 'account group id or pin cannot be blank';
    RETURN;
  END IF;

  l_esn         := NVL(get_master_esn(ip_group_id),-1);

  IF l_esn       < 0 THEN
    OP_ERR_CODE := 3;
    OP_ERR_MSG  := 'master esn not found for group_id '|| ip_group_id;
    RETURN;
  END IF;

  l_smp         := NVL(convert_pin_to_smp (ip_pin),-1);

  IF l_smp       < 0 THEN
    OP_ERR_CODE := 3;
    OP_ERR_MSG  := 'smp not found for pin '|| ip_pin;
    RETURN;
  END IF;

  UPDATE x_service_order_stage
  SET SMP            = l_smp,
    update_timestamp = SYSDATE
  WHERE OBJID        =
    (SELECT MAX (OBJID)
    FROM x_service_order_stage SO
    WHERE SO.ESN   = l_esn
    AND SO.STATUS <> 'COMPLETED'
    );

  COMMIT;

  op_err_code := 0;
  op_err_msg  := 'Success';

EXCEPTION
  WHEN OTHERS THEN
    -- Log error message
    log_error (ip_error_text => 'SQLERRM: ' || SQLERRM, ip_error_date => SYSDATE, ip_action => 'exception when others clause for ip_group_id = ' || ip_group_id || ' , ip_pin = ' || ip_pin ,ip_key => ip_group_id ,ip_program_name => 'brand_x_pkg.attach_pin_to_staging' );
    op_err_code := 1;
    op_err_msg  := 'Unhandled exception : ' || Sqlerrm;
    ROLLBACK;
    RAISE;
END attach_pin_to_staging;
--
--
-- CR39391 - BYOP New Procedure to update the status by ESN
PROCEDURE update_so_stage_status_by_esn (ip_account_group_id  IN  NUMBER,
                                         ip_esn               IN  VARCHAR2,
                                         ip_status            IN  VARCHAR2,
                                         op_err_code          OUT NUMBER,
                                         op_err_msg           OUT VARCHAR2)
AS

  v_objid           NUMBER;
  v_sim             table_part_inst.x_iccid%TYPE;
  v_account_group_id x_account_group_member.account_group_id%TYPE;
  v_update_count    NUMBER;

  -- Get stage data
  CURSOR c_get_master_stage
  IS
    SELECT sos.objid service_order_stage_id,
      sos.type,
      sos.status,agm.status agm_status,
      agm.objid account_group_member_id,sos.sim,convert_smp_to_pin ( ip_smp => sos.smp) pin,sos.esn
    FROM x_service_order_stage sos,
      x_account_group_member agm
    WHERE agm.account_group_id = v_account_group_id
    AND agm.master_flag        = 'Y'
    AND UPPER(agm.status)     <> 'EXPIRED'
    AND agm.objid              = sos.account_group_member_id;
  master_so_rec c_get_master_stage%ROWTYPE;

  CURSOR c_get_child_stage
  IS
       SELECT  sos.type from x_service_order_stage sos
        WHERE account_group_member_id IN
          (SELECT objid
          FROM x_account_group_member
          WHERE account_group_id   = v_account_group_id
          AND NVL(master_flag,'N') = 'N'
          AND UPPER(status)     <> 'EXPIRED'
          )
         AND esn=ip_esn;
  child_so_rec c_get_child_stage%ROWTYPE;

BEGIN

  -- get account group id if passing null other use the one passed
  IF ip_account_group_id IS NULL THEN
    SELECT MAX(agm.account_group_id)
    INTO v_account_group_id
    FROM x_service_order_stage sos,
      x_account_group_member agm
    WHERE agm.esn          = ip_esn
    AND UPPER(agm.status) <> 'EXPIRED'
    AND agm.objid          = sos.account_group_member_id;
  ELSE
    v_account_group_id:=ip_account_group_id;
  END IF;

  -- Get master
  OPEN c_get_master_stage;
  FETCH c_get_master_stage INTO master_so_rec;
  CLOSE c_get_master_stage;

  IF NVL(ip_status,'X')='SIM_PENDING' THEN
    SELECT MAX(sos.objid)
    INTO v_objid
    FROM sa.x_service_order_stage sos,
         x_account_group_member agm
    WHERE 1=1
    AND agm.account_group_id = v_account_group_id
    AND agm.objid = sos.account_group_member_id
    AND sos.esn = ip_esn
    AND UPPER(agm.status)     <> 'EXPIRED'
    AND upper(sos.status) IN ('CASE_PENDING')
    AND upper(type)   IN ('ACTIVATION','REACTIVATION','PORT');

    UPDATE sa.x_service_order_stage
    SET status     = upper(ip_status)
    WHERE objid    = v_objid;

    UPDATE sa.x_account_group_member
    SET status     = upper(ip_status)
    WHERE objid IN (SELECT account_group_member_id FROM x_service_order_stage WHERE objid=v_objid);

    IF SQL%ROWCOUNT=1 THEN
      op_err_code := 0;
      op_err_msg  := 'Success';
    ELSE
      op_err_code := 3;
      op_err_msg  := 'Error: Unable to find CASE_PENDING record for ESN - '||ip_esn;
    END IF;
    RETURN;
  END IF;

  IF NVL(ip_status,'X')='QUEUED' THEN
   --fetch sim from table_part_inst and update in x_service_order_stage
    SELECT max(x_iccid) INTO v_sim
      FROM table_part_inst pi
     WHERE pi.part_serial_no=ip_esn
       AND ROWNUM=1;
    IF v_sim IS NULL THEN
      op_err_code := 5;
      op_err_msg  := 'Error: Unable to find SIM for ESN - '||ip_esn;
      RETURN;
    END IF;

    UPDATE x_service_order_stage
       SET sim  = v_sim
     WHERE account_group_member_id IN
        (SELECT objid
        FROM x_account_group_member
        WHERE account_group_id   = v_account_group_id
        AND UPPER(status)     <> 'EXPIRED'
        )
       AND esn=ip_esn;

      --Check if ESN in PAYMENT_PENDING or SIM_PENDING with SIM status. If not return Err
      SELECT COUNT(*)
      INTO v_update_count
      FROM x_service_order_stage
      WHERE account_group_member_id IN
        (SELECT objid
        FROM x_account_group_member
        WHERE account_group_id = v_account_group_id
        AND UPPER(status)     <> 'EXPIRED'
        )
      AND esn           =ip_esn
      AND ( (status     = 'PAYMENT_PENDING')
      OR (status        ='SIM_PENDING'
      AND sim          IS NOT NULL) );
      IF v_update_count =0 THEN
        op_err_code    := 6;
        op_err_msg     := 'Error: Not in PAYMENT_PENDING or SIM_PENDING with SIM status for ESN - '||ip_esn;
        RETURN;
      END IF;

      -- IF Master needs to be activated
      IF ip_esn=master_so_rec.esn THEN
        UPDATE x_service_order_stage
        SET status                     = upper(ip_status)
        WHERE objid = master_so_rec.service_order_stage_id
          AND esn=ip_esn
         AND ( (status = 'PAYMENT_PENDING') or (status='SIM_PENDING' and sim is not null) )
         RETURNING ACCOUNT_GROUP_MEMBER_ID into v_objid;
        op_err_code := 0;
        op_err_msg  := 'Success';

        --Update X_ACCOUNT_GROUP_MEMBER to PENDING_ENROLLMENT if esn sos status in QUEUED or TO_QUEUE
        UPDATE sa.x_account_group_member
        SET status     = upper('PENDING_ENROLLMENT')
        WHERE objid = v_objid
        AND   UPPER(status)='SIM_PENDING';

        RETURN;
      END IF;

      IF master_so_rec.status in ( 'COMPLETED','QUEUED' ) THEN
       -- Get Child
        OPEN c_get_child_stage;
        FETCH c_get_child_stage INTO child_so_rec;
        CLOSE c_get_child_stage;
         IF master_so_rec.type = 'PORT'
            AND  (master_so_rec.status <> 'COMPLETED' OR (master_so_rec.status = 'COMPLETED' AND UPPER(master_so_rec.agm_status)<>'ACTIVE'))
            AND child_so_rec.type <> 'PORT'  THEN
              change_master ( ip_account_group_id => v_account_group_id, ip_esn => ip_esn, op_err_code => op_err_code, op_err_msg => op_err_msg, ip_switch_pin_flag => 'N');
              IF op_err_code <> 0 THEN
                -- Exit whenever an error ocurred
                RETURN;
              END IF;
        END IF;

        UPDATE x_service_order_stage
        SET status =CASE WHEN upper(master_so_rec.status)='QUEUED' AND upper(master_so_rec.type) <>'PORT' THEN 'TO_QUEUE'
                          ELSE upper(ip_status)
                     END                    --= upper(ip_status)
        WHERE account_group_member_id IN
          (SELECT objid
          FROM x_account_group_member
          WHERE account_group_id   = v_account_group_id
          AND UPPER(status)     <> 'EXPIRED'
          )
         AND esn=ip_esn
         AND ( (status = 'PAYMENT_PENDING') or (status='SIM_PENDING' and sim is not null) );
    ELSE
        --Change Master Below
        -- If PIN is not burned
        IF NVL(is_pin_burned(master_so_rec.pin),'N') = 'N' THEN
          -- CHANGE MASTER to the next ESN in the group (preference for ACTIVATION), move the PIN from the old master to the new master
          change_master ( ip_account_group_id => v_account_group_id, ip_esn => ip_esn, op_err_code => op_err_code, op_err_msg => op_err_msg, ip_switch_pin_flag => 'Y');
          IF op_err_code <> 0 THEN
            -- Exit whenever an error ocurred
            RETURN;
          END IF;
          -- If PIN is burned
        ELSE
          -- CHANGE MASTER to the next ESN in the group (preference for ACTIVATION), do not move the PIN from the old master to the new master, but use only SERVICE_PLAN_ID
          change_master ( ip_account_group_id => v_account_group_id, ip_esn => ip_esn, op_err_code => op_err_code, op_err_msg => op_err_msg, ip_switch_pin_flag => 'N');
          IF op_err_code <> 0 THEN
            -- Exit whenever an error ocurred
            RETURN;
          END IF;
        END IF;

        -- MEMBER ESN can be updated to QUEUED
        UPDATE x_service_order_stage
        SET status = CASE WHEN upper(master_so_rec.status)='QUEUED' AND upper(master_so_rec.type) <>'PORT' THEN 'TO_QUEUE'
                          ELSE upper(ip_status)
                     END
        WHERE account_group_member_id IN
          (SELECT objid
          FROM x_account_group_member
          WHERE account_group_id   = v_account_group_id
          AND UPPER(status)     <> 'EXPIRED'
          )
         AND esn=ip_esn
         AND ( (status = 'PAYMENT_PENDING') or (status='SIM_PENDING' and sim is not null) );

      END IF;

 --Update X_ACCOUNT_GROUP_MEMBER to PENDING_ENROLLMENT if esn sos status in QUEUED or TO_QUEUE
    SELECT Max(sos.objid)
    INTO   v_objid
    FROM   sa.X_SERVICE_ORDER_STAGE sos,
           X_ACCOUNT_GROUP_MEMBER agm
    WHERE  1=1
    AND    agm.account_group_id = v_account_group_id
    AND    agm.objid = sos.account_group_member_id
    AND    sos.esn = ip_esn
    AND    Upper(agm.status) <> 'EXPIRED'
    AND    Upper(sos.status) IN ('QUEUED', 'TO_QUEUE')
    AND    Upper(TYPE)       IN ('ACTIVATION',
                                 'REACTIVATION',
                                 'PORT');

    UPDATE sa.X_ACCOUNT_GROUP_MEMBER
    SET    status = 'PENDING_ENROLLMENT'
    WHERE  objid IN
           (
                  SELECT account_group_member_id
                  FROM   X_SERVICE_ORDER_STAGE
                  WHERE  objid=v_objid)
     AND   UPPER(status)='SIM_PENDING';
  END IF ;

  op_err_code := 0;
  op_err_msg  := 'Success';

EXCEPTION
  WHEN OTHERS THEN
    op_err_code := 1;
    op_err_msg  := 'Unhandled exception : ' || Sqlerrm;
    RAISE;
END update_so_stage_status_by_esn;
--
--
-- CR39391 - BYOP New Procedure to return the status of PIN based on i/p group or Pin
FUNCTION is_pin_burned_by_group_pin_esn (ip_account_group_id IN NUMBER,
                                         ip_esn              IN VARCHAR2,
                                         ip_pin              IN VARCHAR2) RETURN VARCHAR2
IS
  -- Get stage data
  CURSOR c_get_master_stage IS
    SELECT sos.objid                                service_order_stage_id,
           sos.TYPE,
           sos.status,
           agm.status                               agm_status,
           agm.objid                                account_group_member_id,
           sos.sim,
           Convert_smp_to_pin ( ip_smp => sos.smp ) pin,
           sos.esn
    FROM   X_SERVICE_ORDER_STAGE sos,
           X_ACCOUNT_GROUP_MEMBER agm
    WHERE  agm.account_group_id = ip_account_group_id AND
           agm.master_flag = 'Y' AND
           Upper( agm.status ) <> 'EXPIRED' AND
           agm.objid = sos.account_group_member_id;

  master_so_rec c_get_master_stage%ROWTYPE;

BEGIN

    IF ip_pin IS NOT NULL THEN
      RETURN Is_pin_burned( ip_pin );
    END IF;

    IF ip_account_group_id IS NULL THEN
      RETURN 'N';
    END IF;

    -- Get master
    OPEN c_get_master_stage;

    FETCH c_get_master_stage INTO master_so_rec;

    CLOSE c_get_master_stage;

    RETURN Is_pin_burned( master_so_rec.pin );

END is_pin_burned_by_group_pin_esn;
--
--
-- CR41658
PROCEDURE get_groupid_of_redeemed_pin (ip_pin        IN  VARCHAR2,
                                       op_esn        OUT VARCHAR2,
                                       op_group_id   OUT VARCHAR2,
                                       op_web_objid  OUT VARCHAR2,
                                       op_error_code OUT VARCHAR2,
                                       op_err_msg    OUT VARCHAR2)
IS
BEGIN

 OP_ERROR_CODE := '0';

 BEGIN
  SELECT ct_ext.account_group_id
  INTO OP_GROUP_ID
  FROM table_x_call_trans ct,
   table_x_call_trans_ext ct_ext,
   table_x_red_card rc
  WHERE     1 = 1
  AND rc.red_card2call_trans   =  ct.objid
  AND ct_ext.call_trans_ext2call_trans = ct.objid
  AND rc.x_red_code    =  IP_PIN
  AND ct.x_new_due_date   >=  SYSDATE
  AND ROWNUM     =  1;
 EXCEPTION WHEN OTHERS
 THEN
  OP_ERROR_CODE := '99';
  OP_ERR_MSG := SQLERRM||' Pin is not redeemed or service end date crossed for redeemed pin';
  RETURN;
 END;

 BEGIN
 SELECT web.objid , pi.part_serial_no
 INTO OP_WEB_OBJID, OP_ESN
 FROM table_web_user web,
  table_x_contact_part_inst conpi,
  table_part_inst pi
 WHERE 1                               = 1
 AND pi.objid                          = conpi.x_contact_part_inst2part_inst
 AND conpi.x_contact_part_inst2contact = web.web_user2contact
 AND pi.part_serial_no                 = NVL(get_master_esn(OP_GROUP_ID),-1);
 EXCEPTION
 WHEN OTHERS THEN
  OP_ERROR_CODE := '99';
  OP_ERR_MSG := 'Web objid and ESN not found for Group   '||OP_GROUP_ID;
 END;

EXCEPTION
  WHEN OTHERS THEN
    OP_ERROR_CODE := '99';
    OP_ERR_MSG := 'BRAND_X_PKG.GET_GROUPID_OF_REDEEMED_PIN main exception '||SQLERRM||' - '||IP_PIN||' - '||OP_ESN;
END get_groupid_of_redeemed_pin;
--
--
--Added new function - CR48716
FUNCTION is_master_esn_active (i_esn IN VARCHAR2) RETURN VARCHAR2
IS

 v_master_esn VARCHAR2(40):= NULL;
 v_group_id   VARCHAR2(40):= NULL;
 v_err_code   VARCHAR2(40):= NULL;
 v_err_msg    VARCHAR2(40):= NULL;
 v_is_active  VARCHAR2(40):= 'N';

BEGIN

 get_master_esn (NULL,
                 i_esn,
                 v_master_esn,
                 v_group_id,
                 v_err_code,
                 v_err_msg);

 DBMS_OUTPUT.PUT_LINE('Master ESN:'||v_master_esn||' i_esn:'||i_esn||' v_group_id:'||v_group_id||' v_err_code:'||v_err_code||' v_err_msg:'||v_err_msg);

 BEGIN

   SELECT 'Y'
   INTO   v_is_active
   FROM   table_part_inst tpi,
          table_site_part tsp
   WHERE  tpi.part_serial_no        = NVL(v_master_esn, i_esn)
   AND    tpi.x_domain              = 'PHONES'
   AND    tpi.x_part_inst_status    = '52'
   AND    tpi.x_part_inst2site_part = tsp.objid
   AND    TRUNC(tsp.x_expire_dt)   >= TRUNC(SYSDATE)
   AND    ROWNUM = 1;
 EXCEPTION
   WHEN OTHERS THEN
     v_is_active := 'N';
     DBMS_OUTPUT.PUT_LINE('Active ESN not found '||sqlerrm);
 END;

 DBMS_OUTPUT.PUT_LINE('v_is_active: '||v_is_active);

 RETURN v_is_active;

EXCEPTION
  WHEN OTHERS THEN
   RETURN 'N';
   DBMS_OUTPUT.PUT_LINE('in main exception is_master_esn_active '||sqlerrm);
END is_master_esn_active;
--
--
-- CR48846
PROCEDURE get_member_esn_by_group (i_groupid      IN NUMBER,
                                   o_esn_list_cur OUT SYS_REFCURSOR,
                                   o_err_msg      OUT VARCHAR2)
IS
BEGIN

  IF i_groupid IS NULL THEN
    o_err_msg := 'FAILURE';
    OPEN o_esn_list_cur FOR
      SELECT NULL ESN,
             NULL PART_CLASS,
             NULL ESN_TYPE
      FROM DUAL;
    RETURN;
  END IF;

  OPEN o_esn_list_cur FOR
    SELECT   sos.esn,
             pc.name part_class,
             MAX (sos.type)KEEP (DENSE_RANK LAST ORDER BY sos.insert_timestamp) esn_type
    FROM     x_account_group_member agm,
             x_service_order_stage sos,
             x_account_group ag,
             table_part_num pn,
             table_part_inst pi,
             table_mod_level ml,
             table_part_class pc
    WHERE agm.account_group_id = i_groupid
    AND agm.objid              = sos.account_group_member_id
    AND agm.account_group_id   = ag.objid
    AND pi.x_domain            = 'PHONES'
    AND pi.part_serial_no      = sos.esn
    AND ml.objid               = pi.n_part_inst2part_mod
    AND pn.objid               = ml.part_info2part_num
    AND pc.objid               = pn.part_num2part_class
    GROUP BY sos.esn, pc.name;

  o_err_msg := 'SUCCESS';

EXCEPTION
  WHEN OTHERS THEN
    o_err_msg := 'FAILURE';
    OPEN o_esn_list_cur FOR
      SELECT NULL ESN,
             NULL PART_CLASS,
             NULL ESN_TYPE
      FROM DUAL;
END get_member_esn_by_group;
--
--
PROCEDURE get_group_mins (i_groupid      IN  NUMBER,
                          i_master_esn   IN  VARCHAR2,
                          i_min          IN  VARCHAR2,
                          o_min_list_cur OUT SYS_REFCURSOR,
                          o_error_code   OUT NUMBER,
                          o_error_msg    OUT VARCHAR2)
IS
 n_groupid  NUMBER;
BEGIN
  --
  n_groupid := NVL(i_groupid, get_account_group_id ( ip_esn            => nvl(i_master_esn,sa.customer_info.get_esn(i_min)),
                                                     ip_effective_date => null ));

  --
  IF n_groupid IS NULL THEN
    o_error_code:=-8000;
    o_error_msg := 'FAILURE';
    OPEN o_min_list_cur
    FOR
    SELECT NULL ESN,
           NULL MIN
    FROM   DUAL;
    --
    RETURN;
  END IF;
  --
  OPEN o_min_list_cur
  FOR
  SELECT pi_esn.part_serial_no esn,
         pi_min.part_serial_no min
  FROM   x_account_group_member agm,
         table_part_inst pi_esn,
         table_part_inst pi_min
  WHERE  agm.account_group_id = n_groupid
  AND    pi_esn.part_serial_no = agm.esn
  AND    pi_esn.x_domain = 'PHONES'
  AND    pi_min.part_to_esn2part_inst = pi_esn.objid
  AND    pi_min.x_domain = 'LINES';

  o_error_code:=0;
  o_error_msg := 'SUCCESS';

EXCEPTION
  WHEN OTHERS THEN
    o_error_code:=-8000;
    o_error_msg := 'FAILURE: ' || SQLERRM;
    OPEN o_min_list_cur
    FOR
    SELECT NULL ESN,
           NULL MIN
    FROM   DUAL;
END get_group_mins;
--
--
-- CR48846 - Return staged flag,pin avialable flag and group service plan id details for an ESN
PROCEDURE get_esn_details (i_esn                        IN VARCHAR2,
                           o_is_staged_flag             OUT VARCHAR2,
                           o_is_pin_available_flag      OUT VARCHAR2,
                           o_group_service_plan_id      OUT NUMBER,
                           o_error_code                 OUT VARCHAR2,
                           o_error_msg                  OUT VARCHAR2)
IS

c_master_esn              VARCHAR2(30);
c_esn_part_inst_status    VARCHAR2(20);
n_staged_rec_count        NUMBER;
n_staged_rec_smp_count    NUMBER;
c customer_type           :=customer_type();

BEGIN

  IF(i_esn is NULL) THEN
    o_error_code:='100';
    o_error_msg :='ESN CANNOT BE NULL';
    RETURN;
  END IF;

  /*Retrieve Master ESN*/
  BEGIN

    SELECT xagm.esn
      INTO c_master_esn
    FROM x_account_group_member xag ,
         x_account_group_member xagm
    WHERE xag.esn           =i_esn
    AND xag.ACCOUNT_GROUP_ID=xagm.ACCOUNT_GROUP_ID
    AND xagm.MASTER_FLAG    ='Y';

  EXCEPTION
  WHEN OTHERS THEN
    o_error_code:= '101';
    o_error_msg := 'MASTER ESN NOT FOUND';
    RETURN;
  END ;

  /*Get Part Inst Status of ESN*/
  c_esn_part_inst_status:=c.get_esn_part_inst_status(c_master_esn);

  /*Check to see if ESN is staged*/
  BEGIN
    SELECT COUNT(*)
      INTO n_staged_rec_count
    FROM x_service_order_stage
    WHERE esn  =i_esn
    AND status ='PAYMENT_PENDING';
  EXCEPTION
  WHEN OTHERS THEN
    NULL;
  END;

  IF n_staged_rec_count>0 THEN
    o_is_staged_flag:='Y';
  ELSE
    o_is_staged_flag:='N';
  END IF;

  --Retrieve service plan id for the ESN

  o_group_service_plan_id := NULL;

  BEGIN
    SELECT ag.service_plan_id
      INTO o_group_service_plan_id
    FROM x_account_group ag,
           x_account_group_member agm
    WHERE ag.objid = agm.account_group_id
    AND agm.esn     = i_esn ;

  EXCEPTION
  WHEN OTHERS THEN
    o_group_service_plan_id:=NULL;
  END;

  --Check to see if PIN is  Available
  IF(c_esn_part_inst_status ='52') THEN
    o_is_pin_available_flag:='Y';
  ELSE
    o_is_pin_available_flag:='N';
    BEGIN
      SELECT (CASE
              WHEN sg.smp IS NULL
                THEN 'N'
              ELSE 'Y'
              END )
        INTO o_is_pin_available_flag
      FROM x_service_order_stage sg
      WHERE esn  = c_master_esn
      AND status ='PAYMENT_PENDING';
    EXCEPTION
      WHEN OTHERS THEN
      o_is_pin_available_flag:='N';
    END;
  END IF;


  o_error_code:='0';
  o_error_msg:='SUCCESS';

END get_esn_details;
--
--
--TW Web common standards
PROCEDURE get_group_details (i_account_group_id         IN  VARCHAR2,
                             o_is_pin_available_flag    OUT VARCHAR2,
                             o_group_service_plan_id    OUT NUMBER,
                             o_payment_pending_devices  OUT SYS_REFCURSOR,
                             o_error_code               OUT VARCHAR2,
                             o_error_msg                OUT VARCHAR2)
IS

        c_master_esn       VARCHAR2(30);
        c_is_staged_flag   VARCHAR2(10);

BEGIN

        IF
            ( i_account_group_id IS NULL )
        THEN
            o_error_code := '100';
            o_error_msg := 'GROUP ID CANNOT BE NULL';
            return;
        END IF;

        /*Retrieve Master ESN*/

        BEGIN
            SELECT
                esn
            INTO
                c_master_esn
            FROM
                x_account_group_member
            WHERE
                account_group_id = i_account_group_id
                AND   master_flag = 'Y';

        EXCEPTION
            WHEN OTHERS THEN
                o_error_code := '101';
                o_error_msg := 'MASTER ESN NOT FOUND';
                return;
        END;

        get_esn_details(i_esn => c_master_esn,
      o_is_staged_flag => c_is_staged_flag,
      o_is_pin_available_flag => o_is_pin_available_flag,
      o_group_service_plan_id=> o_group_service_plan_id,
      o_error_code => o_error_code,
      o_error_msg => o_error_msg);

        OPEN o_payment_pending_devices FOR
        SELECT
            sg.*
        FROM
            x_account_group_member agm,
            x_service_order_stage sg
        WHERE sg.account_group_member_id = agm.objid
        AND   sg.status = 'PAYMENT_PENDING'
        AND   account_group_id = i_account_group_id;

        o_error_code := '0';
        o_error_msg := 'SUCCESS';

EXCEPTION
  WHEN OTHERS THEN
    o_error_code := '1000';
    o_error_msg := 'BRAND_X_PKG.get_group_details main exception';
END get_group_details;
--
--
-- CR50295
PROCEDURE get_esn_info_from_reserved_pin (ip_pin        IN  VARCHAR2,
                                          op_recordset  OUT SYS_REFCURSOR,
                                          op_error_code OUT VARCHAR2,
                                          op_err_msg    OUT VARCHAR2)
AS

l_esn  table_part_inst.part_serial_no%TYPE ;
l_esn_status table_part_inst.part_status%TYPE;
l_group_id x_account_group_member.account_group_id%TYPE;
l_master_flag   x_account_group_member.master_flag%TYPE;
l_bundle_code       table_x_bundle.x_bundle_code%TYPE;

BEGIN

   BEGIN
       SELECT x_bundle_code
      INTO l_bundle_code
         FROM table_x_bundle
        WHERE bundle2part_inst IN(SELECT objid
                                    FROM table_part_inst inst
                                   WHERE x_red_code = ip_pin)
          AND rownum < 2;

       op_error_code := '0';
       op_err_msg := 'SUCCESS';

       dbms_output.put_line('l_bundle_code :'||l_bundle_code);

    EXCEPTION WHEN OTHERS
    THEN
 op_error_code := '99';
 op_err_msg := SQLERRM||' - ESN and Bundle code were not found for Reserved PIN';

        OPEN op_recordset
         FOR
      SELECT NULL part_serial_no,
             NULL esn_status,
             NULL pin2esn_flag
       FROM DUAL;

      RETURN;

    END;

    IF l_bundle_code IS NOT NULL THEN

    BEGIN

 op_error_code := '0';
 op_err_msg := 'SUCCESS';

         OPEN op_recordset
          FOR
       SELECT part_serial_no,
              code.x_code_name esn_status,
              pin2esn_flag
         FROM table_part_inst inst,
              table_x_bundle bi,
              table_x_code_table code
        WHERE inst.objid   = bi.bundle2part_inst
          AND bi.x_bundle_code = l_bundle_code
          AND inst.x_part_inst_status = code.x_code_number
    AND NVL(inst.x_red_code,'X') <> ip_pin
    ;

 RETURN;

 EXCEPTION WHEN OTHERS THEN

 op_error_code := '99';
 op_err_msg := SQLERRM||' ESN not found for bundle code and PIN';

  OPEN op_recordset
          FOR
       SELECT NULL part_serial_no,
              NULL esn_status,
              NULL pin2esn_flag
         FROM DUAL;

 RETURN;

 END;
 END IF;

EXCEPTION
  WHEN OTHERS THEN
    op_error_code := '99';
    op_err_msg := 'BRAND_X_PKG.GET_ESN_INFO_FROM_RESERVED_PIN main exception '||' - '||IP_PIN||' - No ESN data found';
    OPEN op_recordset FOR
       SELECT NULL part_serial_no,
              NULL esn_status,
              NULL pin2esn_flag
         FROM DUAL;
     RETURN;
END get_esn_info_from_reserved_pin;
--
--
-- CR50295
PROCEDURE get_bundled_info_from_esn (ip_esn        IN  table_part_inst.part_serial_no%TYPE,
                                     op_recordset  OUT SYS_REFCURSOR,
                                     op_red_code   OUT table_part_inst.x_red_code%TYPE,
                                     op_pin_status OUT table_x_code_table.x_code_name%TYPE,
                                     op_error_code OUT VARCHAR2,
                                     op_err_msg    OUT VARCHAR2)
AS

l_bundle_code       table_x_bundle.x_bundle_code%TYPE;
l_count            NUMBER := 0;

BEGIN

   BEGIN
       SELECT x_bundle_code
       INTO l_bundle_code
         FROM table_x_bundle
        WHERE bundle2part_inst IN(SELECT objid
                                    FROM table_part_inst inst
                                   WHERE part_serial_no = ip_esn)
          AND rownum < 2;

       op_error_code := '0';
       op_err_msg := 'SUCCESS';

       dbms_output.put_line('l_bundle_code :'||l_bundle_code);

    EXCEPTION WHEN OTHERS
    THEN
 op_error_code := '99';
 op_err_msg := SQLERRM||' - ESN and Bundle code were not found for Bundled ESN';
 op_red_code := NULL;
 op_pin_status := NULL;

      OPEN op_recordset
       FOR
    SELECT NULL part_serial_no,
           NULL esn_status,
           NULL account_group_id
      FROM DUAL;

 RETURN;

    END;

    IF l_bundle_code IS NOT NULL THEN

    BEGIN

 op_error_code := '0';
 op_err_msg := 'SUCCESS';

   BEGIN

      SELECT x_red_code pin,
                    code.x_code_name esn_status
        INTO op_red_code,
      op_pin_status
               FROM table_part_inst inst,
                    table_x_bundle bi,
                    table_x_code_table code
              WHERE inst.objid   = bi.bundle2part_inst
                AND bi.x_bundle_code = l_bundle_code
                AND inst.x_part_inst_status = code.x_code_number
  AND x_red_code IS NOT NULL;

  EXCEPTION WHEN OTHERS THEN

      op_red_code := NULL;
      op_pin_status := NULL;

  END;

         OPEN op_recordset
          FOR
       SELECT part_serial_no,
              code.x_code_name esn_status,
              account_group_id
         FROM table_part_inst inst,
              table_x_bundle bi,
              table_x_code_table code,
              X_ACCOUNT_GROUP_MEMBER agm
        WHERE inst.objid   = bi.bundle2part_inst
          AND bi.x_bundle_code = l_bundle_code
          AND inst.x_part_inst_status = code.x_code_number
          AND inst.part_serial_no = agm.esn(+)
    AND x_red_code IS NULL;

 RETURN;

 EXCEPTION WHEN OTHERS THEN

    op_error_code := '99';
    op_err_msg := SQLERRM||'No ESN and Group ID were not found for bundled ESN';
    op_red_code := NULL;
    op_pin_status := NULL;

   OPEN op_recordset
           FOR
        SELECT NULL part_serial_no,
               NULL esn_status,
               NULL account_group_id
          FROM DUAL;

  RETURN;

 END;
 END IF;

EXCEPTION
  WHEN OTHERS THEN
    op_error_code := '99';
    op_err_msg := 'BRAND_X_PKG.GET_BUNDLED_INFO_FROM_ESN main exception '||' - '||IP_ESN||' - No Bundled data found';
    OPEN op_recordset FOR
    SELECT NULL part_serial_no,
               NULL esn_status,
               NULL account_group_id
          FROM DUAL;
    RETURN;
END get_bundled_info_from_esn;
--
--
PROCEDURE delete_stage (i_esn      IN  VARCHAR2,
                        o_response OUT VARCHAR2)
AS

c_status VARCHAR2(50);
o_error_code number;
v_esn varchar2(100);

BEGIN

  v_esn:=i_esn;

  -- Fail when the esn was not passed
  IF v_esn IS NULL THEN
    o_response := 'ESN NOT PASSED';
    RETURN;
  END IF;

  BEGIN
    SELECT a.status
    INTO   c_status
    FROM   sa.x_service_order_stage a
    WHERE  a.esn = v_esn
    AND    a.objid = (SELECT MAX(b.objid)
                      FROM   sa.x_service_order_stage b
                      WHERE  a.esn = b.esn);
  EXCEPTION
    WHEN OTHERS THEN
      c_status:=NULL;
  END;

  IF c_status = 'COMPLETED' THEN

    DELETE FROM x_service_order_stage
    WHERE  esn = v_esn;

  ELSIF c_status = 'PAYMENT_PENDING' THEN

    -- Delete the member from the group
    delete_member (ip_account_group_id        => get_account_group_id (ip_esn => v_esn, ip_effective_date => null),
                   iop_esn                    => v_esn,
                   ip_account_group_member_id => NULL,
                   op_err_code                => o_error_code,
                   op_err_msg                 => o_response,
                   ip_bypass_last_mbr_flag    => 'Y');

  END IF;

  o_response := 'SUCCESS';

EXCEPTION
  WHEN OTHERS THEN
    -- Log error message
    o_response  := 'ERROR DELETING STAGE DATA : ' || SQLERRM;
END delete_stage;
--
--
-- CR55236 - Delete a member from a group and call deactservice
-- CR55465 - Added criteria for active ESN to be moved to dummy account along with its original group
PROCEDURE deactivate_member (i_account_group_id IN  NUMBER,
                             i_esn              IN  VARCHAR2,
                             i_sourcesystem     IN  VARCHAR2,
                             i_deactreason      IN  VARCHAR2,
                             i_userobjid        IN  VARCHAR2 DEFAULT NULL,
                             o_error_code       OUT NUMBER,
                             o_error_msg        OUT VARCHAR2)
IS

  c    sa.customer_type := customer_type (i_esn => i_esn);
  cust sa.customer_type;
  --
  c_userobjid     VARCHAR2(240) := i_userobjid;
  c_return_ds     VARCHAR2(30)  := 'False';
  c_returnmsg_ds  VARCHAR2(2400);

BEGIN

  -- CR55465 - Addiding criteria for TW WEB TAS - Allow to remove an Active device from account
  cust  := c.retrieve_group (i_account_group_objid => i_account_group_id);

  -- if the esn is active call deactservice
  IF c.get_esn_part_inst_status (i_esn => c.esn) = '52' THEN  --Active

    IF i_userobjid IS NULL THEN
      BEGIN
        SELECT TO_CHAR(objid)
          INTO c_userobjid
          FROM sa.table_user
         WHERE s_login_name = USER;
      EXCEPTION
        WHEN OTHERS THEN
          BEGIN
            SELECT TO_CHAR(objid)
              INTO c_userobjid
              FROM sa.table_user
             WHERE s_login_name = 'SA'
               AND ROWNUM = 1;
          EXCEPTION
            WHEN OTHERS THEN
              c_userobjid := '268435556';  --hardcoded SA schema user
          END;
      END;
    END IF;

    -- CR55465 - If single-line or multi-line service with one device then remove ESN from group and account and add it to dummy account and group.
    -- CR55465 - If the deactivation reason is not 'REMOVED_FROM_ACCOUNT' then maintain original process to remove line from group and deactivate it.
    IF (cust.group_total_lines = 1) AND (cust.group_allowed_lines > 0) AND (NVL(i_deactreason,'X') = 'REMOVED_FROM_ACCOUNT') THEN

      dbms_output.put_line('ESN is the only active device in group and should not be deactivated - sp: '||c.get_service_plan_objid (i_esn => c.esn));

      -- CR55465 - Update existing group name to default value
      update_acct_group_name (i_account_group_id,
                              i_esn,
                              'GROUP 1',    -- DEFAULT
                              o_error_code,
                              o_error_msg);

      IF o_error_code != 0 THEN
        dbms_output.put_line('Unable to update the account group name to default value - '||o_error_msg);
      END IF;

    ELSE

      -- Delete the member from the group
      delete_member (ip_account_group_id        => i_account_group_id,
                     iop_esn                    => c.esn,
                     ip_account_group_member_id => NULL,
                     op_err_code                => o_error_code,
                     op_err_msg                 => o_error_msg,
                     ip_bypass_last_mbr_flag    => 'Y');

      IF o_error_code != 0 THEN
        RETURN;
      END IF;

      -- call the service deactivation process
      sa.SERVICE_DEACTIVATION.deactservice (ip_sourcesystem    => i_sourcesystem,
                                            ip_userobjid       => c_userobjid,
                                            ip_esn             => c.esn,
                                            ip_min             => c.get_min (i_esn => c.esn),
                                            ip_deactreason     => i_deactreason,
                                            intbypassordertype => 2,
                                            ip_newesn          => NULL,
                                            ip_samemin         => 'false',
                                            op_return          => c_return_ds,
                                            op_returnmsg       => c_returnmsg_ds);

      -- When the member is deleted from the group, but the deactivation fails
      IF c_return_ds != 'true' then
        o_error_code := -80;
        o_error_msg  := 'THE ESN HAS BEEN DELETED FROM THE GROUP BUT NOT DEACTIVATED - '|| c_returnmsg_ds;
        RETURN;
      END IF;

    END IF;

  ELSE  -- non-Active - Just delete member from group

    -- Delete the member from the group
    delete_member (ip_account_group_id        => i_account_group_id,
                   iop_esn                    => c.esn,
                   ip_account_group_member_id => NULL,
                   op_err_code                => o_error_code,
                   op_err_msg                 => o_error_msg,
                   ip_bypass_last_mbr_flag    => 'Y');

    IF o_error_code != 0 THEN
      RETURN;
    END IF;

  END IF;

  -- Deletion of the member from group and deactivation were successful
  o_error_code := 0;
  o_error_msg  := 'SUCCESS';

EXCEPTION
  WHEN OTHERS THEN
    o_error_code := -10;
    o_error_msg  := SQLERRM;
END deactivate_member;
--
--
--TW Web Common Standards
PROCEDURE get_discount_amount (i_account_group_id IN  NUMBER,
                               i_esn              IN  VARCHAR2,
                               i_enrolled_flag    IN  VARCHAR2,
                               i_brand            IN  VARCHAR2,
                               o_discount_amount  OUT NUMBER,
                               o_error_code       OUT NUMBER,
                               o_error_msg        OUT VARCHAR2)
IS

  v_esn   x_program_enrolled.x_esn%TYPE;

BEGIN

        --Not enrolled
        IF
            i_enrolled_flag = 'N'
        THEN
            o_discount_amount := 0;
            o_error_code := 0;
            o_error_msg := 'SUCCESS';
            return;
        END IF;
        --error when group id and esn is null

        IF
            i_esn IS NULL AND i_account_group_id IS NULL
        THEN
            o_discount_amount := 0;
            o_error_code := 10;
            o_error_msg := 'ESN AND GROUP ID CANNOT BE NULL';
            return;
        END IF;

        v_esn :=
            CASE
                WHEN i_account_group_id IS NOT NULL THEN get_master_esn(i_account_group_id)
                ELSE i_esn
            END;
            SELECT x_discount_amount
             INTO
            o_discount_amount
          FROM table_x_promotion tp,
                x_program_enrolled pe,
                sa.x_program_parameters PP
          WHERE 1                           = 1
            AND pe.x_esn                      = v_esn
            AND tp.objid                      = pe.pgm_enroll2x_promotion
            AND pe.x_next_charge_date        >= TRUNC(SYSDATE)
            AND pe.x_is_grp_primary           = 1
            AND pe.x_enrollment_status NOT   IN ('DEENROLLED' ,'ENROLLMENTFAILED' , 'READYTOREENROLL')
            AND pp.objid                      = pe.pgm_enroll2pgm_parameter
            AND NVL(pp.x_prog_class,'X') NOT IN ('ONDEMAND','WARRANTY');


        o_error_code := 0;
        o_error_msg := 'SUCCESS';

EXCEPTION
  WHEN OTHERS THEN
    o_discount_amount := 0;
    o_error_code := 1;
    o_error_msg := 'FAILURE';
END get_discount_amount;
--
--
-- CR55465 - TW ESN Program enrollment data for dummy account creation
PROCEDURE get_prg_enroll_objid (i_esn                IN  VARCHAR2,
                                i_prog_enroll_status IN  VARCHAR2 DEFAULT 'ENROLLED',
                                o_prog_enroll_tab    OUT esn_program_enroll_tab,
                                o_error_code         OUT NUMBER,
                                o_error_msg          OUT VARCHAR2)
IS

  l_org_id        sa.table_bus_org.org_id%TYPE;
  l_enroll_status sa.x_program_enrolled.x_enrollment_status%TYPE;
  cust            customer_type;

BEGIN

  -- CR55465 - use types esn_program_enroll_type and esn_program_enroll_tab//OImana
  -- Initiate values
  o_prog_enroll_tab := sa.esn_program_enroll_tab ();
  o_error_code := 0;
  o_error_msg  := 'SUCCESS';
  --
  cust     := customer_type (i_esn => i_esn);
  l_org_id := cust.get_bus_org_id (i_esn => i_esn);
  l_enroll_status := NVL(i_prog_enroll_status, 'ENROLLED');

  SELECT *
    BULK COLLECT
    INTO o_prog_enroll_tab
    FROM (SELECT sa.esn_program_enroll_type (pe.objid,
                                             pe.x_enrollment_status,
                                             pe.x_enrolled_date,
                                             pp.x_program_name,
                                             pp.x_prog_class,
                                             pp.x_type,
                                             ve.product_id,
                                             ve.vas_group_name,
                                             ve.vas_product_type,
                                             ve.vas_name,
                                             ve.vas_category,
                                             ve.vas_vendor,
                                             ve.vas_association,
                                             ve.vas_bus_org_id,
                                             ve.vas_esn,
                                             ve.vas_min,
                                             ve.vas_sim,
                                             ve.vas_id,
                                             ve.vas_subscription_status)
                                        FROM sa.x_program_enrolled pe,
                                             sa.x_program_parameters pp,
                                             sa.table_bus_org bo,
                                             (SELECT DISTINCT
                                                     vp.program_parameters_objid,
                                                     vp.product_id,
                                                     vp.vas_group_name,
                                                     vp.vas_product_type,
                                                     vp.vas_name,
                                                     vp.vas_category,
                                                     vp.vas_vendor,
                                                     vp.vas_association,
                                                     vp.vas_bus_org vas_bus_org_id,
                                                     vs.vas_esn,
                                                     vs.vas_min,
                                                     vs.vas_sim,
                                                     vs.vas_id,
                                                     vs.status vas_subscription_status
                                                FROM sa.vas_programs_view vp,
                                                     sa.x_vas_subscriptions vs
                                               WHERE vp.vas_bus_org = l_org_id
                                                 AND vs.vas_id = vp.vas_service_id
                                                 AND vs.vas_is_active = 'T'
                                                 AND vs.vas_esn = i_esn) ve
                                       WHERE ve.program_parameters_objid(+) = pp.objid
                                         AND bo.org_id = l_org_id
                                         AND bo.objid = pp.prog_param2bus_org
                                         AND pp.objid = pe.pgm_enroll2pgm_parameter
                                         AND pe.x_enrollment_status = l_enroll_status
                                         AND pe.x_esn = i_esn);

  IF (o_prog_enroll_tab IS NULL) OR (o_prog_enroll_tab.COUNT = 0) THEN
    o_error_code := -1;
    o_error_msg  := 'ERROR - No program enrollment data found for ESN: '||i_esn||' - ORG_ID: '||l_org_id||' - STATUS: '||l_enroll_status;
    dbms_output.put_line(o_error_msg);
    RETURN;
  ELSE
    dbms_output.put_line('Results found: '||o_error_msg||' - record count: '||o_prog_enroll_tab.COUNT);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    o_prog_enroll_tab := NULL;
    o_error_code := -2;
    o_error_msg  := 'ERROR - Failed in calling get_prg_enroll_objid: '||SQLERRM;
    dbms_output.put_line(o_error_msg);
END get_prg_enroll_objid;
--
--
END brand_x_pkg;
/