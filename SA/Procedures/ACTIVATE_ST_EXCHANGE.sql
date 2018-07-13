CREATE OR REPLACE PROCEDURE sa."ACTIVATE_ST_EXCHANGE"
(
  ip_old_site_part_objid IN NUMBER
 ,ip_program_objid       IN NUMBER
 ,ip_new_part_serial_no  IN VARCHAR2
 ,op_site_part_objid     OUT NUMBER
 ,op_error_code          OUT VARCHAR2
 ,op_errormessage        OUT VARCHAR2
) IS
  /************************************************************************************************
  | Copyright   Tracfone  Wireless Inc. All rights reserved
  |
  | PURPOSE  :  Activate Straight Talk Exchange
  | FREQUENCY:
  | PLATFORMS:
  |
  | REVISIONS:
  | VERSION  DATE        WHO              PURPOSE
  | -------  ---------- -----             ------------------------------------------------------
  | 1.0-1.6      11/18/09   Natalio Guada     Initial Revision
  |                                       ST_BUNDLE_III CR12155
  |                                       Line is assumed reserved.
  |                                       Old Site part is assumed inactive
  |                                       Old and new esn are assumed ST
  |1.7           05/06/10   Skuthadi      CR11971 Skip insert into
  |                                       x_switchbased_transaction if ESN iS ST_GSM
  |1.8           06/28/10   Nguada        CR13250 Prevent ST GSM from Activating since Code Gen is required
  |1.9           07/28/10   Ymillan         CR13940  add null parameters into call sp_create_call_trans_2 (safelink service plan project)
  |1.10          11/17/10   kacosta       CR14714 - "Fix Ship Confirm Process Fix ST CDMA Phones"
  |                                       If get_param_by_name_fun(r2.name ,'NON_PPE') <> '1' is true procedure process is terminating but it was returning a sucessful error code
  |                                       Modified to return an error code if get_param_by_name_fun(r2.name ,'NON_PPE') <> '1' is true
  |                                       Also, performed code clean up and improved error handling
  | CVS
  | 1.8         06/30/12   Icanavan      CR20451 | CR20854: Add TELCEL Brand
  |************************************************************************************************/
  CURSOR c1 IS
    SELECT sp.x_service_id
          ,sp.x_min
          ,sp.site_part2site
          ,sp.x_zipcode
          ,spsp.x_service_plan_id
          ,spsp.x_switch_base_rate
          ,pi.x_part_inst2contact
          ,pi.objid
          ,pi.warr_end_date
          ,sp.x_msid
      FROM table_site_part          sp
          ,x_service_plan_site_part spsp
          ,table_part_inst          pi
     WHERE sp.objid = ip_old_site_part_objid
       AND spsp.table_site_part_id = sp.objid
       AND pi.part_serial_no = sp.x_service_id
       AND pi.x_domain = 'PHONES';
  r1 c1%ROWTYPE;
  -- CR13250 Start.
  CURSOR c2 IS
    SELECT table_part_inst.objid
          ,x_technology
          ,NAME
      FROM table_part_inst
          ,table_mod_level
          ,table_part_num
          ,table_part_class
     WHERE part_serial_no = ip_new_part_serial_no
       AND x_domain = 'PHONES'
       AND n_part_inst2part_mod = table_mod_level.objid
       AND table_mod_level.part_info2part_num = table_part_num.objid
       AND part_num2part_class = table_part_class.objid;
  -- CR13250 End.
  r2 c2%ROWTYPE;
  CURSOR c3(old_esn VARCHAR2) IS
    SELECT cpi.*
          ,wu.objid web_user_objid
      FROM table_x_contact_part_inst cpi
          ,table_part_inst           pi
          ,table_web_user            wu
     WHERE cpi.x_contact_part_inst2part_inst = pi.objid
       AND pi.part_serial_no = old_esn
       AND pi.x_domain = 'PHONES'
       AND web_user2contact = cpi.x_contact_part_inst2contact;
  r3 c3%ROWTYPE;

  CURSOR chk_st_gsm_cur IS -- CR11971 ST_GSM
    SELECT pcv.x_param_value
      FROM table_x_part_class_params pcp
          ,table_x_part_class_values pcv
          ,table_part_num            pn
          ,table_part_inst           pi
          ,table_mod_level           ml
          ,table_bus_org             bo
     WHERE 1 = 1
       AND pcp.x_param_name = 'NON_PPE'
       AND pi.part_serial_no = ip_new_part_serial_no
       AND pn.part_num2bus_org = bo.objid
      -- AND bo.org_id = 'STRAIGHT_TALK'
      --  CR20451 | CR20854: Add TELCEL Brand
      AND bo.org_flow = '3'
       AND pcv.value2class_param = pcp.objid
       AND pcv.value2part_class = pn.part_num2part_class
       AND ml.part_info2part_num = pn.objid
       AND pi.n_part_inst2part_mod = ml.objid;

  rec_chk_st_gsm      chk_st_gsm_cur%ROWTYPE;
  p_min               VARCHAR2(200);
  p_esn               VARCHAR2(200);
  p_site_objid        NUMBER;
  p_expdate           DATE;
  p_zipcode           VARCHAR2(200);
  p_site_part_objid   NUMBER;
  op_calltranobj      NUMBER;
  p_action_item_objid NUMBER;
  p_status_code       NUMBER;
  p_destination_queue NUMBER;
  op_result           VARCHAR2(200);
  op_msg              VARCHAR2(200);
  p_errorcode         VARCHAR2(200);
  p_errormessage      VARCHAR2(200);
  p_due_date          DATE;
  call_result         BOOLEAN;
  found_rec           NUMBER;
  --
  -- CR14714 Start kacosta 11/17/2010
  ex_business_logic_failure EXCEPTION;
  -- CR14714 End kacosta 11/17/2010
  --
BEGIN
  --
  -- CR14714 Start kacosta 11/17/2010
  --op_error_code := '0';
  --op_errormessage := '';
  p_errorcode    := '0';
  p_errormessage := '';
  -- CR14714 End kacosta 11/17/2010
  --
  IF NVL(ip_old_site_part_objid
        ,0) = 0 THEN
    --
    -- CR14714 Start kacosta 11/17/2010
    --op_error_code := '10';
    --op_errormessage := 'Site Part OBJID null';
    --RETURN;
    p_errorcode    := '10';
    p_errormessage := 'Site Part OBJID null';
    RAISE ex_business_logic_failure;
    -- CR14714 End kacosta 11/17/2010
    --
  END IF;
  --
  -- CR14714 Start kacosta 11/17/2010
  IF c1%ISOPEN THEN
    CLOSE c1;
  END IF;
  -- CR14714 End kacosta 11/17/2010
  --
  OPEN c1;
  FETCH c1
    INTO r1;
  IF c1%NOTFOUND THEN
    CLOSE c1;
    --
    -- CR14714 Start kacosta 11/17/2010
    --op_error_code := '20';
    --op_errormessage := 'Old Site Part or Service Plan not found';
    --RETURN;
    p_errorcode    := '20';
    p_errormessage := 'Old Site Part or Service Plan not found';
    RAISE ex_business_logic_failure;
    -- CR14714 End kacosta 11/17/2010
    --
  END IF;
  CLOSE c1;
  --
  -- CR14714 Start kacosta 11/17/2010
  IF c2%ISOPEN THEN
    CLOSE c2;
  END IF;
  -- CR14714 End kacosta 11/17/2010
  --
  OPEN c2;
  FETCH c2
    INTO r2;
  IF c2%NOTFOUND THEN
    CLOSE c2;
    --
    -- CR14714 Start kacosta 11/17/2010
    --op_error_code := '30';
    --op_errormessage := 'New part serial no not found';
    --RETURN;
    p_errorcode    := '30';
    p_errormessage := 'New part serial no not found';
    RAISE ex_business_logic_failure;
    -- CR14714 End kacosta 11/17/2010
    --
    -- CR13250 Start.
  ELSE
    CLOSE c2;
    IF get_param_by_name_fun(r2.name
                            ,'NON_PPE') <> '1' THEN
      --Non PPE cannot be activated this way.
      --
      -- CR14714 Start kacosta 11/17/2010
      --op_error_code                     := '0';
      --op_errormessage                   := '';
      --RETURN;
      p_errorcode    := '40';
      p_errormessage := 'Non PPE cannot be activated this way; Failure calling get_param_by_name_fun in activate_st_exchange';
      RAISE ex_business_logic_failure;
      -- CR14714 End kacosta 11/17/2010
      --
    END IF;
    -- CR13250 End.

-- CR20451 | CR20854: Add TELCEL Brand
  IF GET_BRAND_OBJID(R1.X_SERVICE_ID) <> GET_BRAND_OBJID(ip_new_part_serial_no) then
      p_errorcode    := '50';
      p_errormessage := 'Old and New ESN brands do not match failed calling GET_BRAND_OBJID function in ACTIVATE_ST_EXCHANGE';
      RAISE ex_business_logic_failure;
  END IF ;

  END IF;
  --
  -- CR14714 Start kacosta 11/17/2010
  --CLOSE c2;
  -- CR14714 End kacosta 11/17/2010
  --
  -- Link new esn to old contact
  UPDATE table_part_inst
     SET x_part_inst2contact = r1.x_part_inst2contact
        ,warr_end_date       = r1.warr_end_date
   WHERE part_serial_no = ip_new_part_serial_no;
  COMMIT;
  convert_bo_to_sql_pkg.createsitepart(p_min             => r1.x_min
                                      ,p_esn             => ip_new_part_serial_no
                                      ,p_site_objid      => r1.site_part2site
                                      ,p_expdate         => r1.warr_end_date
                                      ,p_pin             => NULL
                                      ,p_zipcode         => r1.x_zipcode
                                      ,p_site_part_objid => p_site_part_objid
                                      ,p_errorcode       => p_errorcode
                                      ,p_errormessage    => p_errormessage);
  --
  -- CR14714 Start kacosta 11/17/2010
  IF NVL(p_errorcode
        ,'0') NOT IN (''
                     ,'0') THEN
    p_errormessage := SUBSTR(p_errormessage || '; failure calling convert_bo_to_sql_pkg.createsitepart'
                            ,1
                            ,200);
    RAISE ex_business_logic_failure;
  ELSE
    p_errorcode    := '0';
    p_errormessage := '';
  END IF;
  -- CR14714 End kacosta 11/17/2010
  --
  UPDATE table_site_part
     SET x_expire_dt = r1.warr_end_date
        ,part_status = 'CarrierPending'
   WHERE objid = p_site_part_objid;
  COMMIT;
  --
  -- CR14714 Start kacosta 11/17/2010
  --op_site_part_objid := p_site_part_objid;
  --IF p_errorcode <> '' AND p_errorcode <> '0' THEN
  --  RETURN;
  --ELSE
  --  p_errorcode := '0';
  --  p_errormessage := '';
  --END IF;
  -- CR14714 End kacosta 11/17/2010
  --
  INSERT INTO x_service_plan_site_part
    (table_site_part_id
    ,x_service_plan_id
    ,x_switch_base_rate)
  VALUES
    (p_site_part_objid
    ,r1.x_service_plan_id
    ,r1.x_switch_base_rate);
  INSERT INTO x_service_plan_hist
    (plan_hist2site_part
    ,x_start_date
    ,plan_hist2service_plan)
  VALUES
    (p_site_part_objid
    ,SYSDATE
    ,r1.x_service_plan_id);
  convert_bo_to_sql_pkg.sp_create_call_trans_2(ip_esn              => ip_new_part_serial_no
                                              ,ip_action_type      => '1'
                                              ,ip_sourcesystem     => 'Clarify'
                                              ,ip_brand_name       => '200' --to be replaced by 'STRAIGHT_TALK'
                                              ,ip_reason           => NULL
                                              ,ip_result           => 'Completed'
                                              ,ip_ota_req_type     => NULL
                                              ,ip_ota_type         => NULL
                                              ,ip_total_units      => 0
                                              ,ip_orig_login_objid => 268435556 --sa objid
                                              ,ip_action_text      => NULL
                                              ,op_calltranobj      => op_calltranobj
                                              ,op_err_code         => p_errorcode
                                              ,op_err_msg          => p_errormessage); -- CR13940
  --
  -- CR14714 Start kacosta 11/17/2010
  IF NVL(p_errorcode
        ,'0') NOT IN (''
                     ,'0') THEN
    RAISE ex_business_logic_failure;
  ELSE
    p_errorcode    := '0';
    p_errormessage := '';
  END IF;
  -- CR14714 End kacosta 11/17/2010
  --
  call_result := toss_util_pkg.set_pi_status_fun(r1.x_min
                                                ,'LINES'
                                                ,'13'
                                                ,'ST_EXCHANGE');
  call_result := toss_util_pkg.insert_pi_hist_fun(r1.x_min
                                                 ,'LINES'
                                                 ,'ACTIVATION'
                                                 ,'ST_EXCHANGE');
  --
  -- CR14714 Start kacosta 11/17/2010
  --IF p_errorcode <> '0' THEN
  --  RETURN;
  --ELSE
  --  p_errorcode := '0';
  --  p_errormessage := '';
  --END IF;
  IF chk_st_gsm_cur%ISOPEN THEN
    CLOSE chk_st_gsm_cur;
  END IF;
  -- CR14714 End kacosta 11/17/2010
  --
  -- ST_GSM CR11971 Starts
  OPEN chk_st_gsm_cur;
  FETCH chk_st_gsm_cur
    INTO rec_chk_st_gsm; -- ST_GSM CR11971 Skip INSERT x_switchbased_transaction if ESN is ST GSM

  IF chk_st_gsm_cur%FOUND THEN

    IF rec_chk_st_gsm.x_param_value != 0 THEN
      -- 0 -- ST GSM
      INSERT INTO sa.x_switchbased_transaction
        (objid
        ,x_sb_trans2x_call_trans
        ,status
        ,x_type
        ,x_value
        ,exp_date
        ,rsid)
      VALUES
        (sa.sequ_x_sb_transaction.nextval
        ,op_calltranobj
        ,'CarrierPending'
        ,'AP'
        ,r1.x_switch_base_rate
        ,r1.warr_end_date
        ,'5050');
      COMMIT;
    END IF; -- ST_GSM CR11971 ENDS
  END IF;

  CLOSE chk_st_gsm_cur;

  switch_based.passive_activation(p_min        => r1.x_min
                                 ,p_esn        => ip_new_part_serial_no
                                 ,p_msid       => r1.x_msid
                                 ,p_err_num    => p_errorcode
                                 ,p_err_string => p_errormessage
                                 ,p_due_date   => p_due_date);
  --
  -- CR14714 Start kacosta 11/17/2010
  IF NVL(p_errorcode
        ,'0') NOT IN (''
                     ,'0') THEN
    RAISE ex_business_logic_failure;
  ELSE
    p_errorcode    := '0';
    p_errormessage := '';
  END IF;
  -- CR14714 End kacosta 11/17/2010
  --
  UPDATE table_x_call_trans
     SET x_new_due_date = r1.warr_end_date
   WHERE objid = op_calltranobj;
  UPDATE table_part_inst
     SET warr_end_date = r1.warr_end_date
   WHERE part_serial_no = ip_new_part_serial_no;
  UPDATE table_site_part
     SET x_expire_dt = r1.warr_end_date
        ,part_status = 'CarrierPending'
   WHERE objid = p_site_part_objid;
  --take out service days from old ESN
  UPDATE table_part_inst
     SET warr_end_date = SYSDATE
   WHERE part_serial_no = r1.x_service_id
     AND x_domain = 'PHONES';
  COMMIT;
  igate.sp_create_action_item(p_contact_objid     => r1.x_part_inst2contact
                             ,p_call_trans_objid  => op_calltranobj
                             ,p_order_type        => 'ESN Change'
                             ,p_bypass_order_type => 0
                             ,p_case_code         => NULL
                             ,p_status_code       => p_status_code
                             ,p_action_item_objid => p_action_item_objid);
  igate.sp_determine_trans_method(p_action_item_objid  => p_action_item_objid
                                 ,p_order_type         => 'ESN Change'
                                 ,p_trans_method       => NULL
                                 ,p_destination_queue  => p_destination_queue
                                 ,p_application_system => NULL);
  --
  -- CR14714 Start kacosta 11/17/2010
  IF c3%ISOPEN THEN
    CLOSE c3;
  END IF;
  -- CR14714 End kacosta 11/17/2010
  --
  OPEN c3(r1.x_service_id);
  FETCH c3
    INTO r3;
  IF c3%FOUND THEN
    CLOSE c3;
    SELECT COUNT(*)
      INTO found_rec
      FROM table_x_contact_part_inst
     WHERE x_contact_part_inst2contact = r3.x_contact_part_inst2contact
       AND x_contact_part_inst2part_inst = r2.objid;
    IF found_rec = 0 THEN
      INSERT INTO table_x_contact_part_inst
        (objid
        ,x_contact_part_inst2contact
        ,x_contact_part_inst2part_inst
        ,x_esn_nick_name
        ,x_is_default
        ,x_transfer_flag
        ,x_verified)
      VALUES
        (sa.seq('x_contact_part_inst')
        ,r3.x_contact_part_inst2contact
        ,r2.objid
        ,NULL
        ,r3.x_is_default
        ,r3.x_transfer_flag
        ,r3.x_verified);
      COMMIT;
    END IF;
    DELETE FROM table_x_contact_part_inst
     WHERE x_contact_part_inst2contact = r3.x_contact_part_inst2contact
       AND x_contact_part_inst2part_inst = r3.x_contact_part_inst2part_inst;
    COMMIT;
  ELSE
    CLOSE c3;
  END IF;
  IF ip_program_objid IS NOT NULL THEN
    UPDATE x_program_enrolled
       SET x_esn                = ip_new_part_serial_no
          ,pgm_enroll2site_part = p_site_part_objid
          ,pgm_enroll2part_inst = r2.objid
          ,x_enrollment_status  = 'ENROLLED'
     WHERE objid = ip_program_objid;
    COMMIT;
  END IF;
  --
  -- CR14714 Start kacosta 11/17/2010
  op_site_part_objid := p_site_part_objid;
  op_error_code      := p_errorcode;
  op_errormessage    := p_errormessage;
  -- CR14714 End kacosta 11/17/2010
  --
EXCEPTION
  --
  -- CR14714 Start kacosta 11/17/2010
  WHEN ex_business_logic_failure THEN
    IF c1%ISOPEN THEN
      CLOSE c1;
    END IF;
    IF c2%ISOPEN THEN
      CLOSE c2;
    END IF;
    IF chk_st_gsm_cur%ISOPEN THEN
      CLOSE chk_st_gsm_cur;
    END IF;
    IF c3%ISOPEN THEN
      CLOSE c3;
    END IF;
    op_error_code   := p_errorcode;
    op_errormessage := p_errormessage;
    -- CR14714 End kacosta 11/17/2010
  --
  WHEN OTHERS THEN
    --
    -- CR14714 Start kacosta 11/17/2010
    --p_errorcode    := '99';
    --P_ERRORMESSAGE := 'Unexpected error: ' || SQLERRM;
    IF c1%ISOPEN THEN
      CLOSE c1;
    END IF;
    IF c2%ISOPEN THEN
      CLOSE c2;
    END IF;
    IF chk_st_gsm_cur%ISOPEN THEN
      CLOSE chk_st_gsm_cur;
    END IF;
    IF c3%ISOPEN THEN
      CLOSE c3;
    END IF;
    op_error_code   := '99';
    op_errormessage := 'Unexpected error: ' || SQLERRM;
    -- CR14714 End kacosta 11/17/2010
  --
END activate_st_exchange;
/