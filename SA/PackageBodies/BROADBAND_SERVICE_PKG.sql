CREATE OR REPLACE PACKAGE BODY sa.BROADBAND_SERVICE_PKG
AS
PROCEDURE VALIDATE_VENDOR(
    P_VENDOR_ID   IN VARCHAR2,
    P_VENDOR_NAME IN VARCHAR2,
    p_is_successful OUT NUMBER)
IS
  /* Return 0=success 1=failure */
  CURSOR vendor_curs
  IS
    SELECT PI.*
    FROM sa.X_BB_VENDOR PI
    WHERE 1              = 1
    AND PI.X_VENDOR_ID   = P_VENDOR_ID
    AND PI.X_vendor_name = P_vendor_name;
  vendor_rec vendor_curs%rowtype;
BEGIN
  P_IS_SUCCESSFUL:=0;
  OPEN vendor_curs;
  FETCH vendor_curs INTO vendor_rec;
  IF VENDOR_CURS%NOTFOUND THEN
    P_IS_SUCCESSFUL:= 1;
    -- p_error_message := 'VENDOR NOT FOUND';
  END IF;
  CLOSE vendor_curs;
EXCEPTION
WHEN OTHERS THEN
  p_is_successful:=1;
END VALIDATE_VENDOR;
--CR47024 - SL Unlimited Changes
PROCEDURE p_get_source_dest_sp_group(
    in_esn        IN VARCHAR2,
    in_partnumber IN VARCHAR2,
    op_src_sp_grp OUT VARCHAR2,
    op_dest_sp_grp OUT VARCHAR2,
    op_err_num OUT NUMBER,
    op_err_msg OUT VARCHAR2 )
AS
  v_esn_sp_rec x_service_plan%rowtype;
  v_src_sp_grp x_serviceplanfeaturevalue_def.value_name%TYPE;
  l_sp_objid NUMBER;
  v_dest_sp_grp x_serviceplanfeaturevalue_def.value_name%TYPE;
BEGIN
  IF in_esn    IS NULL OR in_esn IS NULL THEN
    op_err_num := 1;
    op_err_msg := 'ESN/PARTNUMBER Cannot be NULL';
    RETURN;
  END IF;
  v_esn_sp_rec := SERVICE_PLAN.get_service_plan_by_esn(in_esn);
  dbms_output.put_line('service_plan_id ' || v_esn_sp_rec.objid);

  IF (v_esn_sp_rec.objid IS NULL OR v_esn_sp_rec.objid = 252) THEN
    v_src_sp_grp         := 'TF_DEFAULT';
  ELSE
    v_src_sp_grp := get_serv_plan_value(v_esn_sp_rec.objid, 'SERVICE_PLAN_GROUP');
  END IF;
  dbms_output.put_line('v_src_sp_grp: ' || v_src_sp_grp);

  BEGIN
    SELECT DECODE(sp_objid, NULL,'TF_DEFAULT',252,'TF_DEFAULT',sa.get_serv_plan_value(sp_objid, 'SERVICE_PLAN_GROUP'))
    INTO v_dest_sp_grp
    FROM ADFCRM_SERV_PLAN_CLASS_MATVIEW mv ,
      table_part_num pn
    WHERE PART_NUM2PART_CLASS = PART_CLASS_OBJID
    AND pn.part_number        = in_partnumber;
  EXCEPTION
  WHEN NO_DATA_FOUND THEN
    v_dest_sp_grp := 'TF_DEFAULT';
    dbms_output.put_line('No service plan found EXCEPTION v_dest_sp_grp: ' || v_dest_sp_grp);
  END;
  dbms_output.put_line('v_dest_sp_grp: ' || v_dest_sp_grp);

  op_src_sp_grp  := v_src_sp_grp;
  op_dest_sp_grp := v_dest_sp_grp;
  op_err_num     := 0;
  op_err_msg     := 'SUCCESS';
EXCEPTION
WHEN OTHERS THEN
  op_Err_Num := 1;
  op_err_Msg := 'UNHANDLED EXCEPTION: ' || SQLERRM;
END;
--CR39488 For inserting TF 350 MINUTE card into table_part_inst
PROCEDURE REFILL_TF_RED_CARD(
    P_ESN          IN VARCHAR2,
    p_part_num_pin IN VARCHAR2,
    p_sourcesystem IN VARCHAR2, ---default WEB
    P_AMOUNT       IN NUMBER,
    p_X_SMP OUT VARCHAR2,
    p_error_code OUT NUMBER,
    p_error_message OUT VARCHAR2 )
AS
  l_part_number    VARCHAR2 ( 200 ) ;
  l_part_status    VARCHAR2(200);
  l_plan_name      VARCHAR2(200);
  l_future_date    DATE;
  l_description    VARCHAR2(200);
  l_customer_price VARCHAR2(200);
  L_SITE_ID        VARCHAR2(30);
  l_step           VARCHAR2(100);
  --
  P_SEQ_NAME   VARCHAR2(200) := 'X_MERCH_REF_ID';
  O_NEXT_VALUE NUMBER;
  O_FORMAT     VARCHAR2(200);
  --P_RESERVE_ID NUMBER;
  P_TOTAL BINARY_INTEGER := 1;
  P_DOMAIN            VARCHAR2(200) := 'REDEMPTION CARDS';
  P_STATUS            VARCHAR2(200);
  P_MSG               VARCHAR2(200);
  op_call_trans_objid NUMBER;
  p_err_code          VARCHAR2(200);
  p_err_msg           VARCHAR2(200);
  CURSOR queue_card_days_curs
  IS
    SELECT NVL(SUM(x_redeem_days),0) queued_days
    FROM table_part_inst pi_esn,
      table_part_inst pi_qc,
      table_mod_level ml,
      table_part_num pn
    WHERE 1                         =1
    AND pi_esn.part_serial_no       = p_esn
    AND pi_esn.x_domain             = 'PHONES'
    AND pi_qc.part_to_esn2part_inst = pi_esn.objid
    AND pi_qc.x_part_inst_status    = '400'
    AND ml.objid                    = pi_qc.n_part_inst2part_mod
    AND pn.objid                    = ml.part_info2part_num;
  queue_card_days_rec queue_card_days_curs%rowtype;
  CURSOR pin_part_num_curs
  IS
    SELECT m.objid mod_level_objid,
      bo.org_id,
      PN.X_UPC,
      PN.PART_NUMBER,
      pn.x_redeem_days
    FROM table_part_num pn,
      table_mod_level m,
      table_bus_org bo
    WHERE 1                  =1
    AND pn.part_number       = p_part_num_pin
    AND m.part_info2part_num = pn.objid
    AND bo.objid             = pn.part_num2bus_org;
  pin_part_num_rec pin_part_num_curs%rowtype;
  CURSOR esn_curs
  IS
    SELECT pi_esn.part_serial_no esn,
      pi_esn.objid pi_esn_objid,
      pi_esn.part_inst2inv_bin, -- this need to change to the rtr machine dealer
      ib.bin_name site_id,
      sp.x_expire_dt
    FROM table_site_part sp,
      table_part_inst pi_esn,
      table_inv_bin ib
    WHERE 1                   =1
    AND sp.x_service_id       = p_esn
    AND sp.part_status        = 'Active'
    AND pi_esn.part_serial_no = sp.x_service_id
    AND ib.objid              = pi_esn.part_inst2inv_bin;
  esn_rec esn_curs%rowtype;
  CURSOR pin_curs(c_next_value IN NUMBER)
  IS
    SELECT * FROM table_x_cc_red_inv WHERE x_reserved_id = c_next_value;
  pin_rec pin_curs%rowtype;
  CURSOR user_curs
  IS
    SELECT objid,1 col2 FROM table_user WHERE s_login_name = USER
  UNION
  SELECT objid,2 col2 FROM table_user WHERE s_login_name = 'SA' ORDER BY col2;
  user_rec user_curs%rowtype;
  CURSOR dealer_curs
  IS
    SELECT s.site_id,
      ib.objid ib_objid
    FROM sa.table_inv_bin ib,
      sa.table_site s
    WHERE 1         =1
    AND IB.BIN_NAME = S.SITE_ID
    AND S.S_NAME    = 'MONEYGRAM PAYMENT SYSTEMS, INC'; --05152013
  -- and S.S_NAME like 'MONEYGRAM%';
  -- AND S.SITE_ID = '35347'; --dealer moneygram
  DEALER_REC DEALER_CURS%ROWTYPE;
  --CR47024
  v_esn_sp_rec x_service_plan%rowtype;
  v_plan_type x_serviceplanfeaturevalue_def.value_name%TYPE;
BEGIN
  P_ERROR_CODE := 0;
  L_STEP       := '1';
  p_x_smp      := ' ';
  OPEN queue_card_days_curs;
  FETCH queue_card_days_curs INTO queue_card_days_rec;
  IF queue_card_days_curs%notfound THEN
    queue_card_days_rec.queued_days := 0;
  END IF;
  CLOSE queue_card_days_curs;
  OPEN dealer_curs;
  FETCH dealer_curs INTO dealer_rec;
  IF dealer_curs%notfound THEN
    CLOSE dealer_curs;
    p_error_code    := 1;
    p_error_message := 'INVALID DEALER';
    RETURN;
  END IF;
  CLOSE dealer_curs;
  OPEN user_curs;
  FETCH user_curs INTO user_rec;
  CLOSE user_curs;
  OPEN esn_curs;
  FETCH esn_curs INTO esn_rec;
  CLOSE esn_curs;
  OPEN pin_part_num_curs;
  FETCH pin_part_num_curs INTO pin_part_num_rec;
  CLOSE pin_part_num_curs;
  l_future_date := esn_rec.x_expire_dt +pin_part_num_rec.x_redeem_days + queue_card_days_rec.queued_days;
  sa.NEXT_ID( P_SEQ_NAME, O_NEXT_VALUE, O_FORMAT);
  DBMS_OUTPUT.PUT_LINE('O_NEXT_VALUE = ' || O_NEXT_VALUE);
  DBMS_OUTPUT.PUT_LINE('O_FORMAT = ' || O_FORMAT);
  --SP_RESERVE_APP_CARD( O_NEXT_VALUE, P_TOTAL, P_DOMAIN, P_STATUS, P_MSG);
 SP_RESERVE_APP_CARD( p_reserve_id => O_NEXT_VALUE,
 p_total =>P_TOTAL,
 p_domain =>P_DOMAIN,
 p_status =>P_STATUS,
 p_msg =>P_MSG); --CR42260

  DBMS_OUTPUT.PUT_LINE('P_STATUS = ' || P_STATUS);
  DBMS_OUTPUT.PUT_LINE('P_MSG = ' || P_MSG);
  IF p_msg          != 'Completed' THEN
    p_error_code    := 4;
    p_error_message := 'SP_RESERVE_APP_CARD'||':'||p_status||':'||p_msg;
    RETURN;
  END IF;
  OPEN pin_curs(o_next_value);
  FETCH pin_curs INTO pin_rec;
  IF pin_curs%notfound THEN
    p_error_code    := 5;
    p_error_message := 'PIN CODE NOT FOUND';
    CLOSE pin_curs;
    RETURN;
  END IF;
  CLOSE pin_curs;
  INSERT
  INTO table_part_inst
    (
      objid,
      last_pi_date,
      last_cycle_ct,
      next_cycle_ct,
      last_mod_time,
      last_trans_time,
      date_in_serv,
      repair_date,
      warr_end_date,
      x_cool_end_date,
      part_status,
      hdr_ind,
      x_sequence,
      x_insert_date,
      x_creation_date,
      x_domain,
      x_deactivation_flag,
      x_reactivation_flag,
      x_red_code,
      part_serial_no,
      x_part_inst_status,
      part_inst2inv_bin,
      created_by2user,
      status2x_code_table,
      n_part_inst2part_mod,
      part_to_esn2part_inst,
      x_ext
    )
    VALUES
    (
      (
        seq('part_inst')
      )
      ,
      sysdate,
      TO_DATE('01/01/1753 00:00:00', 'mm/dd/yyyy hh24:mi:ss') ,
      TO_DATE('01/01/1753 00:00:00', 'mm/dd/yyyy hh24:mi:ss') ,
      sysdate,
      sysdate,
      TO_DATE('01/01/1753 00:00:00', 'mm/dd/yyyy hh24:mi:ss') ,
      TO_DATE('01/01/1753 00:00:00', 'mm/dd/yyyy hh24:mi:ss') ,
      TO_DATE('01/01/1753 00:00:00', 'mm/dd/yyyy hh24:mi:ss') ,
      TO_DATE('01/01/1753 00:00:00', 'mm/dd/yyyy hh24:mi:ss'),
      'Active',
      0,
      0,
      SYSDATE,
      SYSDATE,
      'REDEMPTION CARDS',
      0,
      0,
      pin_rec.x_red_card_number,
      pin_rec.X_SMP,
      '40',
      dealer_rec.ib_objid,
      user_rec.objid,
      (SELECT objid
      FROM table_x_code_table
      WHERE x_code_number = '40'
      ) ,
      pin_part_num_rec.mod_level_objid,
      esn_rec.pi_esn_objid,
      NVL(
      (SELECT MAX(TO_NUMBER(x_ext) + 1)
      FROM table_part_inst
      WHERE part_to_esn2part_inst = esn_rec.pi_esn_objid
      AND x_domain                = 'REDEMPTION CARDS'
      ) ,1)
    ) ;
  p_x_smp := pin_rec.X_SMP;
  COMMIT;
EXCEPTION
WHEN OTHERS THEN
  ROLLBACK;
  p_error_code    := 9;
  P_ERROR_MESSAGE := SQLERRM;
  L_STEP          := L_STEP||':'||SQLCODE||':'||SQLERRM;
  INSERT
  INTO ERROR_TABLE
    (
      ERROR_TEXT,
      ERROR_DATE ,
      ACTION,
      KEY,
      PROGRAM_NAME
    )
    VALUES
    (
      L_STEP,
      SYSDATE,
      'REFILL_TF_RED_CARD',
      P_ESN,
      'REFILL_TF_RED_CARD'
    );
END REFILL_TF_RED_CARD;
PROCEDURE MONEYTRANSFER
  (
    P_REQUEST_TYPE IN VARCHAR2,
    P_MIN          IN VARCHAR2,
    P_PAYCODE      IN NUMBER,
    P_DENOMINATION IN NUMBER,
    P_REFER        IN VARCHAR2,
    P_FIRST_NAME_S IN VARCHAR2,
    P_LASTNAME_S   IN VARCHAR2,
    P_ADDRESS_S    IN VARCHAR2,
    P_CITY_S       IN VARCHAR2,
    P_STATE_S      IN VARCHAR2,
    P_COUNTRY_S    IN VARCHAR2,
    P_ZIP_S        IN VARCHAR2,
    P_PHONE_S      IN VARCHAR2,
    P_ERROR_CODE OUT NUMBER,
    P_ERROR_MSG OUT VARCHAR2,
    P_MG_VALID OUT VARCHAR2,
    P_MG_RESPONSE_CODE OUT VARCHAR2,
    P_MG_ERROR_MSG OUT VARCHAR2,
    P_TF_REF_NO OUT VARCHAR2
  )
IS
  /* Return 0=success 1=failure */
  /*
  New Transaction Log table for logging all VALIDATION hits (as per Validation Request and Response XML files) -- New table
  Transaction Header table for logging all MONEY TRANSFER hits (as per MoneyTransfer Request and Response XML files) -- Already exists, schema changes due
  */
  CURSOR LID_CURS
  IS
    SELECT cv.lid,
      SP.X_MIN,
      SP.PART_STATUS SITE_PART_STATUS,
      PI.X_PART_INST_STATUS,
      S.X_REQUESTED_PLAN,
      sp.x_service_id ESN,
      bo.org_id,
      NVL(PI.X_PART_INST2CONTACT, S.SL_SUBS2TABLE_CONTACT) CONTACT_OBJID,
      s.zip zip,
      pn.part_number part_number
    FROM sa.table_site_part sp,
      sa.x_sl_currentvals cv,
      sa.x_sl_subs s,
      sa.table_part_inst pi,
      sa.table_mod_level ml,
      sa.table_part_num pn,
      sa.table_bus_org bo
    WHERE sp.x_min              = P_MIN
    AND sp.x_service_id         = cv.x_current_esn
    AND cv.lid                  = s.lid
    AND sp.x_service_id         = pi.part_serial_no
    AND pi.X_DOMAIN             = 'PHONES'
    AND pi.n_part_inst2part_mod = ml.objid
    AND ml.part_info2part_num   = pn.objid
    AND pn.part_num2bus_org     = bo.objid
    ORDER BY DECODE(sp.part_status,'Active',1,'Inactive',2,3) ASC,
      sp.install_date DESC,
      sp.objid DESC;
  LID_REC LID_CURS%ROWTYPE;
  CURSOR PAYCODE_curs (v_plan IN VARCHAR2)
  IS
    SELECT PI.*,
      ROUND(PI.X_DENOCODE/1.05,2) TOTAL_BASE_AMOUNT
    FROM sa.x_BB_DENO_CODES PI
    WHERE 1           = 1
    AND PI.X_PAYCODE  = P_PAYCODE
    AND PI.X_REQ_PLAN = V_PLAN
    AND PI.X_DENOCODE = P_DENOMINATION ;
  PAYCODE_REC PAYCODE_CURS%ROWTYPE;
  CURSOR CASE_EXIST_CURS (v_esn IN VARCHAR2)
  IS
    SELECT C.case_type_lvl2 case_l2
    FROM sa.table_case c
    WHERE 1     = 1
    AND C.X_ESN = V_ESN
    AND C.TITLE = 'SafeLink BroadBand Shipment'
    AND C.X_CASE_TYPE
      ||'' = 'Warehouse';
  CASE_EXIST_rec CASE_EXIST_CURS%ROWTYPE;
  CURSOR MG_ERROR_CURS (V_TF_ERROR_CODE IN NUMBER)
  IS
    SELECT *
    FROM sa.X_MONEYGRAM_ERROR_CODES MGE
    WHERE 1               = 1
    AND MGE.TF_ERROR_CODE = V_TF_ERROR_CODE;
  MG_ERROR_REC MG_ERROR_CURS%ROWTYPE;
  CURSOR DUP_PAYMENT_CURS
  IS
    SELECT MG.*
    FROM X_MG_TRANSACTIONS MG
    WHERE 1                      = 1
    AND MG.X_MG_REFERENCE_NUMBER = P_REFER
    AND MG.X_DATE_TRANS+0       >= SYSDATE-1;
  DUP_PAYMENT_REC DUP_PAYMENT_CURS%ROWTYPE;
  L_STEP        VARCHAR2(100);
  P_CASE_ID     NUMBER;
  V_ERROR_CODE2 NUMBER;
  p_X_SMP       VARCHAR2(30);
  V_TAXRATE     NUMBER;
  v_dest_sp_grp  x_serviceplanfeaturevalue_def.value_name%TYPE;
  /* CR29021 changes starts */
  CURSOR cur_esn_details(in_esn IN VARCHAR2)
  IS
    SELECT pgm.x_program_name,
      pgm.objid prog_param_objid,
      pe.pgm_enroll2web_user web_user_id
    FROM x_program_enrolled pe,
      x_program_parameters pgm
    WHERE 1                    = 1
    AND pgm.objid              = pe.pgm_enroll2pgm_parameter
    AND pgm.x_prog_class       = 'LIFELINE'
    AND pe.x_sourcesystem      = 'VMBC'
    AND pgm.x_is_recurring     = 1
    AND pe.x_esn               = in_esn
    AND pe.x_enrollment_status = 'ENROLLED'
	UNION --Added for CR47024 - SL Unlimited
	SELECT pgm.x_program_name,
      pgm.objid prog_param_objid,
      pe.pgm_enroll2web_user web_user_id
    FROM x_program_enrolled pe,
      x_program_parameters pgm
    WHERE 1                    = 1
    AND pgm.objid              = pe.pgm_enroll2pgm_parameter
    AND pgm.x_prog_class       = 'LIFELINE'
    AND pe.x_sourcesystem      = 'VMBC'
    AND pgm.x_is_recurring     = 1
    AND pe.x_esn               = in_esn
	AND pe.x_enrollment_status <> 'ENROLLED'
    AND pe.x_enrolled_date = (SELECT MAX(i_pe.x_enrolled_date) FROM x_program_enrolled i_pe,x_program_parameters i_pgm
							WHERE i_pe.X_ESN = pe.x_esn
							AND i_pgm.objid = i_pe.pgm_enroll2pgm_parameter
							AND i_pgm.x_prog_class = 'LIFELINE'
							AND i_pgm.x_is_recurring = 1
							)
    AND not exists (SELECT 1 FROM x_program_enrolled i_pe,x_program_parameters i_pgm
							WHERE i_pe.X_ESN = pe.x_esn
							AND i_pgm.objid = i_pe.pgm_enroll2pgm_parameter
							AND i_pgm.x_prog_class = 'LIFELINE'
							AND i_pgm.x_is_recurring = 1
							AND i_pe.x_enrollment_status = 'ENROLLED' )
    AND v_dest_sp_grp = 'TFSL_UNLIMITED';

  rec_esn_details cur_esn_details%rowtype;
  --byop AR START
  CURSOR cur_monergram_lookup
  IS
    SELECT * FROM X_MONEYGRAM_LOOKUP WHERE X_PAYCODE = P_PAYCODE;
  rec_monergram_lookup cur_monergram_lookup%rowtype;
  CURSOR check_deno_curs (v_plan IN VARCHAR2)
  IS
    SELECT 1
    FROM sa.x_BB_DENO_CODES PI
    WHERE 1           = 1
    AND PI.X_PAYCODE  = P_PAYCODE
    AND PI.X_REQ_PLAN = V_PLAN;
  check_deno_rec check_deno_curs%rowtype;
  --byop AR END
  lv_quantity pls_integer;
  lv_denomination_err pls_integer ;
  lv_denomination_allowed pls_integer;
  lv_e911_unit_amount NUMBER;
  /* CR29021 changes ends */
  --byop AR START
  lv_actiontype VARCHAR2(100);
  lv_enroll_zip table_x_zip_code.x_zip%type;
  lv_web_user_id   NUMBER;
  lv_lid           NUMBER;
  lv_esn           VARCHAR2(200);
  lv_contact_objid NUMBER;
  lv_refcursor sys_refcursor;
  lv_payment_type x_mg_transactions.x_payment_type%type;
  ln_combstaxamt    NUMBER;
  ln_e911amt        NUMBER := NULL;
  ln_usfamt         NUMBER := NULL;
  ln_rcrfamt        NUMBER := NULL;
  ln_subtotalamount NUMBER;
  ln_totaltaxamount NUMBER;
  ln_totalcharges   NUMBER;
  ln_combstaxrate   NUMBER;
  ln_e911rate       NUMBER;
  ln_usfrate        NUMBER;
  ln_rcrfrate       NUMBER;
  lv_plan x_program_parameters.x_program_name%type;
  v_esn_sp_rec x_service_plan%rowtype;
  v_src_sp_grp   x_serviceplanfeaturevalue_def.value_name%TYPE;
  l_sp_objid  NUMBER;

  --byop AR END
BEGIN
  P_ERROR_CODE  :=0;
  P_CASE_ID     := NULL;
  V_ERROR_CODE2 :=0;
  P_X_SMP       := ' ';
  L_STEP        := '1';
  V_TAXRATE     :=0;
  OPEN cur_monergram_lookup;
  FETCH cur_monergram_lookup INTO REC_monergram_lookup;
  IF cur_monergram_lookup%NOTFOUND THEN
    CLOSE cur_monergram_lookup;
    raise_application_error(-20270, 'sa.safelink_validations_pkg.calculate_taxes_prc'|| 'failed ..p_error_code='||p_error_code ||', ERR='||P_ERROR_MSG );
  END IF;
  CLOSE cur_monergram_lookup;
  OPEN DUP_PAYMENT_CURS;
  FETCH DUP_PAYMENT_CURS INTO DUP_PAYMENT_REC;
  IF DUP_PAYMENT_CURS%FOUND THEN
    P_TF_REF_NO       := DUP_PAYMENT_REC.X_TF_REFERENCE_NUMBER;
    P_ERROR_CODE      := 221;
    P_ERROR_MSG       := 'Duplicate Transfer for MG Ref: '||P_REFER;
    P_MG_VALID        := DUP_PAYMENT_REC.x_status;
    P_MG_RESPONSE_CODE:=
    CASE
    WHEN DUP_PAYMENT_REC.x_status = 'FAIL' THEN
      '01409'
    END;
    P_MG_ERROR_MSG:=
    CASE
    WHEN DUP_PAYMENT_REC.x_status = 'FAIL' THEN
      'Other Reject'
    END;
  ELSE
    OPEN LID_CURS;
    FETCH LID_CURS INTO LID_REC;
    IF LID_CURS%FOUND THEN
      L_STEP := '2';
      --CR47024 Changes
      p_get_source_dest_sp_group(lid_rec.esn,rec_monergram_lookup.X_PART_NUMBER,v_src_sp_grp,	v_dest_sp_grp,P_ERROR_CODE,P_ERROR_MSG);

      DBMS_OUTPUT.PUT_LINE('X_PROVISION_FLAG '||rec_monergram_lookup.X_PROVISION_FLAG);
      DBMS_OUTPUT.PUT_LINE('X_STATE ' ||UPPER(rec_monergram_lookup.X_STATE));
      DBMS_OUTPUT.PUT_LINE('.....' ||'LIFELINE - '||rec_monergram_lookup.X_STATE||' - [H,B]?UNL1$');
      DBMS_OUTPUT.PUT_LINE('X_PART_NUMBER ' ||rec_monergram_lookup.X_PART_NUMBER);
      DBMS_OUTPUT.PUT_LINE('lid_rec.esn ' ||lid_rec.esn);
      DBMS_OUTPUT.PUT_LINE('v_src_sp_grp ' ||v_src_sp_grp);
      DBMS_OUTPUT.PUT_LINE('v_dest_sp_grp ' ||v_dest_sp_grp);

      IF REC_monergram_lookup.X_PROVISION_FLAG IN (1, 2, 3) THEN --byop AR
        -- if (p_paycode = lc_e911_paycode) then
	       OPEN cur_esn_details (lid_rec.esn);
        FETCH cur_esn_details INTO rec_esn_details;
        IF cur_esn_details%FOUND THEN --byop AR
         DBMS_OUTPUT.PUT_LINE('x_program_name ' ||UPPER(rec_esn_details.x_program_name));

	 IF (rec_monergram_lookup.X_PROVISION_FLAG IN (1) AND NOT REGEXP_LIKE(UPPER(rec_esn_details.x_program_name), 'LIFELINE - '||rec_monergram_lookup.X_STATE||'^?')) OR
      (rec_monergram_lookup.X_PROVISION_FLAG IN (2, 3) AND NOT ( REGEXP_LIKE(UPPER(rec_esn_details.x_program_name), 'LIFELINE - .. - [H,B]?UNL1$')
                                                              OR REGEXP_LIKE(UPPER(rec_esn_details.x_program_name), 'LIFELINE - .. - T[1,2]'))) THEN --CR54116 Configure Tribal for Moneygram
            IF NOT(v_src_sp_grp = 'TFSL_UNLIMITED' OR v_dest_sp_grp = 'TFSL_UNLIMITED') THEN  --CR47024 Changes
				P_ERROR_CODE := 9;
				P_ERROR_MSG  := 'Customer plan is not Lifeline - '||rec_monergram_lookup.x_state;
				V_ERROR_CODE2:=100; -- Fail MoneyTransfer
			END IF;
          END IF;
        ELSE
          P_ERROR_CODE := 9;
          P_ERROR_MSG  := 'The requested customer plan is not Enrolled to: '|| LID_REC.X_REQUESTED_PLAN;
          V_ERROR_CODE2:=100; -- Fail MoneyTransfer
        END IF;
        CLOSE cur_esn_details;
        -- if UPPER(rec_esn_details.x_program_name) NOT like 'LIFELINE - AL%' then
        -- P_ERROR_CODE := 9;
        -- P_ERROR_MSG := 'Customer plan is not Lifeline - AL';
        -- V_ERROR_CODE2:=100; -- Fail MoneyTransfer
        -- end if;
      END IF;                                                    --REC_monergram_lookup.X_PROVISION_FLAG IN (1, 2, 3)
      IF rec_monergram_lookup.x_provision_flag IN (1, 2, 3) THEN --byop AR
        -- if (p_paycode = lc_e911_paycode) then
        lv_plan := rec_esn_details.x_program_name;
        OPEN PAYCODE_CURS(lv_plan);
      ELSE
        lv_plan := LID_REC.X_REQUESTED_PLAN;
        OPEN PAYCODE_CURS(lv_plan);
      END IF;
      FETCH PAYCODE_CURS INTO PAYCODE_REC;
      IF PAYCODE_CURS%FOUND THEN
        L_STEP := '3';
        /* CR29021 changes starts */
        IF rec_monergram_lookup.x_provision_flag = 1 THEN
          IF lv_e911_unit_amount                IS NULL THEN
            lv_e911_unit_amount                 := sa.sp_taxes.computee911surcharge2(lid_rec.zip);
          END IF;
          IF NVL(lv_e911_unit_amount,0) = 0 THEN
            -- lv_e911_unit_amount := rec_monergram_lookup.x_e911_unit_amount; --byop AR
            -- lv_e911_unit_amount := 1.75 ;
            p_error_code := -88; -- this is database configuration error code
            p_error_msg  := 'E911 fee is zero or Null. ';
            raise_application_error(-20180, 'sa.broadband_service_pkg.moneytransfer'|| 'failed ..p_error_code='||p_error_code
            ---||', ERR='||p_error_msg
            );
          END IF;
        END IF; --if rec_monergram_lookup.x_provision_flag = 1
        DBMS_OUTPUT.PUT_LINE('PAYCODE_REC.X_RECEIVE_CODE :'||PAYCODE_REC.X_RECEIVE_CODE);
        DBMS_OUTPUT.PUT_LINE('LID_REC.ORG_ID :'||LID_REC.ORG_ID);
        DBMS_OUTPUT.PUT_LINE('PAYCODE_REC.X_DENOCODE :'||PAYCODE_REC.X_DENOCODE);
        DBMS_OUTPUT.PUT_LINE('LID_REC.SITE_PART_STATUS :'||LID_REC.SITE_PART_STATUS);
        DBMS_OUTPUT.PUT_LINE('LID_REC.X_PART_INST_STATUS :'||LID_REC.X_PART_INST_STATUS);
        -- PAYCODE_REC.X_RECEIVE_CODE = 'RED' AND LID_REC.ORG_ID = 'TRACFONE' AND PAYCODE_REC.X_DENOCODE = P_DENOMINATION AND LID_REC.SITE_PART_STATUS='Active' AND LID_REC.X_PART_INST_STATUS='52'
        IF paycode_rec.x_receive_code = rec_monergram_lookup.x_receive_code AND rec_monergram_lookup.x_provision_flag = 1 THEN
          -- IF (PAYCODE_REC.X_RECEIVE_CODE = lc_e911_receivecode AND p_paycode = lc_e911_paycode)then
          BEGIN
            ---check maximum denomination that is allowed
            ---validate how much payment customer can make.
            sa.safelink_validations_pkg.p_get_valid_e911_txn_allowed ( ip_lid => lid_rec.lid, ip_program_objid => rec_esn_details.prog_param_objid, ip_part_number => rec_monergram_lookup.x_part_number, op_txns_allowed => lv_quantity, op_err_num => p_error_code, op_err_string => p_error_msg );
            DBMS_OUTPUT.PUT_LINE('-----lv_quantity='||lv_quantity || ', safelink_validations_pkg error_code='||p_error_code);
            IF p_error_code   = 0 THEN
              IF lv_quantity  = 0 THEN
                p_error_code := 7;
              ELSE
                IF p_denomination > lv_quantity * lv_e911_unit_amount THEN
                  ---p_error_code := 6;
                  p_error_code := rec_monergram_lookup.x_moneygram_error_codes_start                                                                       + lv_quantity; --3/5/2015
                  p_error_msg  := 'Exceeding the limit of maximum amount to be paid.' || ' actual amt='||p_denomination || ', expected amt='|| lv_quantity * lv_e911_unit_amount;
                ELSE
                  VALIDATE_DENOCODE ( P_PAYCODE => P_PAYCODE, P_DENOMINATION => P_DENOMINATION, P_RECEIVE_CODE => rec_monergram_lookup.x_receive_code, P_ERROR_CODE => p_error_code, p_error_msg => p_error_msg );
                  -- VALIDATE_DENOCODE (
                  -- P_PAYCODE => P_PAYCODE,
                  -- P_DENOMINATION => P_DENOMINATION,
                  -- P_RECEIVE_CODE => lc_e911_receivecode,
                  -- P_ERROR_CODE => p_error_code,
                  -- p_error_msg => p_error_msg
                  -- );
                  IF p_error_code = 0 THEN
                    p_error_msg  := 'E911SUCCESS';
                  ELSE
                    p_error_code := 6;
                    p_error_msg  := 'trying to make payment in Incorrect denomination.' || ' actual amt='||p_denomination;
                  END IF;
                END IF;
              END IF;
            elsIf p_error_code = -1 THEN
              p_error_code    := 7;
            ELSE
              raise_application_error(-20199, 'sa.safelink_validations_pkg.p_get_valid_e911_txn_allowed'|| 'failed ..p_error_code='||p_error_code
              ---||', ERR='||p_error_msg
              );
            END IF;
          END;
          /* CR29021 changes ends */
          --IF (PAYCODE_REC.X_RECEIVE_CODE = 'ACT' AND LID_REC.ORG_ID = 'TRACFONE'--CR29021
        ELSIF (PAYCODE_REC.X_RECEIVE_CODE = 'ACT' AND LID_REC.ORG_ID = 'TRACFONE' --CR29021
          AND PAYCODE_REC.X_DENOCODE      = P_DENOMINATION) THEN
          OPEN CASE_EXIST_CURS(lid_rec.esn);
          FETCH CASE_EXIST_CURS INTO CASE_EXIST_REC;
          L_STEP := '7';
          IF CASE_EXIST_CURS%FOUND THEN ---exist case pending
            P_ERROR_CODE := 7;
            P_ERROR_MSG  := 'Only one phone per customer is allowed';
            V_ERROR_CODE2:=100; -- Fail MoneyTransfer
          ELSE
            L_STEP          := '8';
            P_ERROR_CODE    := 0;
            P_ERROR_MSG     := 'Validation success for initial payment';
            IF P_REQUEST_TYPE='MONEYTRANSFER' THEN
              L_STEP        := '9';
              P_TF_REF_NO   := 'TFMGI'||TO_CHAR(SYSDATE,'yyyymmdd')||sa.SEQU_X_MG_REFERENCE.NEXTVAL;
              L_STEP        := '10';
              INITIAL_BB(LID_REC.LID, LID_REC.ESN, P_MIN, PAYCODE_REC.X_PN_PH1, PAYCODE_REC.X_PN_PINA, LID_REC.CONTACT_OBJID, P_CASE_ID, P_ERROR_CODE, P_ERROR_MSG);
            END IF;
          END IF;
          CLOSE CASE_EXIST_CURS;
        ELSIF ((PAYCODE_REC.X_RECEIVE_CODE = REC_MONERGRAM_LOOKUP.X_RECEIVE_CODE AND P_PAYCODE = REC_MONERGRAM_LOOKUP.X_PAYCODE) AND REC_MONERGRAM_LOOKUP.x_provision_flag IN (2,3)) AND PAYCODE_REC.X_DENOCODE = P_DENOMINATION AND LID_REC.SITE_PART_STATUS='Active' AND LID_REC.X_PART_INST_STATUS='52' THEN
          SAFELINK_VALIDATIONS_PKG.P_VALIDATE_MIN( IP_KEY => 'MIN', IP_VALUE => P_MIN, IP_SOURCE_SYSTEM => 'MG', OP_ACTIONTYPE => LV_ACTIONTYPE, OP_ENROLL_ZIP => LV_ENROLL_ZIP, OP_WEB_USER_ID => LV_WEB_USER_ID, OP_LID => LV_LID, OP_ESN => LV_ESN, OP_CONTACT_OBJID => LV_CONTACT_OBJID, OP_REFCURSOR => LV_REFCURSOR , OP_ERR_NUM => P_ERROR_CODE, OP_ERR_STRING => P_ERROR_MSG );
          IF P_ERROR_CODE    = 0 AND lv_actiontype = 'ILDONLY' AND REC_MONERGRAM_LOOKUP.X_PROVISION_FLAG = 2 THEN
            P_ERROR_CODE    := 22;
            P_ERROR_MSG     := 'Exceeding the limit of data card purchase.';
            V_ERROR_CODE2   :=100; -- Fail MoneyTransfer
          ELSIF P_ERROR_CODE = 0 THEN
            SAFELINK_VALIDATIONS_PKG. CALCULATE_TAXES_PRC( IP_ZIPCODE => LID_REC.ZIP, IP_PARTNUMBERS => LID_REC.PART_NUMBER, IP_ESN => LID_REC.ESN, IP_CC_ID => NULL, IP_PROMO => NULL, IP_BRAND_NAME => LID_REC.ORG_ID, IP_TRANSACTION_TYPE => NULL, IP_SOURCESYSTEM => 'WEB', OP_COMBSTAXAMT => LN_COMBSTAXAMT, OP_E911AMT => LN_E911AMT, OP_USFAMT => LN_USFAMT, OP_RCRFAMT => LN_RCRFAMT, OP_SUBTOTALAMOUNT => LN_SUBTOTALAMOUNT, OP_TOTALTAXAMOUNT => LN_TOTALTAXAMOUNT, OP_TOTALCHARGES => LN_TOTALCHARGES, OP_COMBSTAXRATE => LN_COMBSTAXRATE, OP_E911RATE => LN_E911RATE, OP_USFRATE => LN_USFRATE, OP_RCRFRATE => LN_RCRFRATE, OP_RESULT => P_ERROR_CODE, OP_MSG => P_ERROR_MSG );
            IF P_ERROR_CODE     = 0 THEN
			  --CR47024 - SL Unlimited Changes
			  IF v_src_sp_grp = 'TFSL_UNLIMITED' AND v_dest_sp_grp <> 'TFSL_UNLIMITED' THEN
				  P_ERROR_CODE                  := 35;
				  P_ERROR_MSG                   := 'Pay go cards cannot be purchased while receiving Unlimited benefits';
				  DBMS_OUTPUT.PUT_LINE('Paygo Card purchase While UNLIMTED - Validation request');
			  END IF;
             IF P_ERROR_CODE     = 0 THEN
			    P_ERROR_CODE     := 0;
                P_ERROR_MSG      := 'Validation success';
                 DBMS_OUTPUT.PUT_LINE('Validation success.........');
				 DBMS_OUTPUT.PUT_LINE('V_ERROR_CODE2'||V_ERROR_CODE2);
              IF P_REQUEST_TYPE ='MONEYTRANSFER' THEN
                L_STEP         := '13';
               -- P_TF_REF_NO    := 'TFMGM'||TO_CHAR(SYSDATE,'yyyymmdd')||SA.SEQU_X_MG_REFERENCE.NEXTVAL;
                DBMS_OUTPUT.PUT_LINE('LiD_REC.ESN'||LiD_REC.ESN);
                DBMS_OUTPUT.PUT_LINE('PAYCODE_REC.X_PN_PINM'||PAYCODE_REC.X_PN_PINM);

				IF v_src_sp_grp <> 'TFSL_UNLIMITED' AND v_dest_sp_grp = 'TFSL_UNLIMITED' THEN
					REFILL_TF_RED_CARD (LiD_REC.ESN, PAYCODE_REC.X_PN_PINM, 'WEB', ---default web
					P_DENOMINATION, P_X_SMP, P_ERROR_CODE, P_ERROR_MSG);
					P_TF_REF_NO    := 'TFMGM'||TO_CHAR(SYSDATE,'yyyymmdd')||sa.SEQU_X_MG_REFERENCE.NEXTVAL;
					DBMS_OUTPUT.PUT_LINE('UNLIMITED Card purchase - Calling REFILL_TF_RED_CARD');
					DBMS_OUTPUT.PUT_LINE('P_ERROR_MSG'||P_ERROR_MSG);
				ELSIF v_src_sp_grp = 'TFSL_UNLIMITED' AND v_dest_sp_grp <> 'TFSL_UNLIMITED' THEN
					  P_ERROR_CODE                  := 35;
					  P_ERROR_MSG                   := 'Pay go cards cannot be purchased while receiving Unlimited benefits';
					  V_ERROR_CODE2                 := 100; -- Fail MoneyTransfer
					  DBMS_OUTPUT.PUT_LINE('Paygo Card purchase While UNLIMTED- Money Transfer request ');
				ELSE
					REFILL_BB (LiD_REC.ESN, PAYCODE_REC.X_PN_PINM, 'WEB', ---default web
					P_DENOMINATION, P_X_SMP, P_ERROR_CODE, P_ERROR_MSG);
					P_TF_REF_NO    := 'TFMGM'||TO_CHAR(SYSDATE,'yyyymmdd')||sa.SEQU_X_MG_REFERENCE.NEXTVAL;
					DBMS_OUTPUT.PUT_LINE('P_ERROR_MSG'||P_ERROR_MSG);
					DBMS_OUTPUT.PUT_LINE('UNL to UNL Purchase (or) Paygo Card purchase as BAU - Calling REFILL_BB');
			    END IF;
              END IF;
             END IF;
			ELSIF P_ERROR_CODE <> 0 THEN
              raise_application_error(-20201, 'sa.safelink_validations_pkg.calculate_taxes_prc'|| 'failed ..p_error_code='||p_error_code ||', ERR='||P_ERROR_MSG );
            END IF;
          ELSIF P_ERROR_CODE <> 0 THEN
            raise_application_error(-20200, 'sa.safelink_validations_pkg.p_validate_min'|| 'failed ..p_error_code='||p_error_code ||', ERR='||P_ERROR_MSG );
          END IF;
        ELSIF (PAYCODE_REC.X_RECEIVE_CODE = 'RED' AND LID_REC.ORG_ID = 'NET10' AND PAYCODE_REC.X_DENOCODE = P_DENOMINATION AND LID_REC.SITE_PART_STATUS='Active' AND LID_REC.X_PART_INST_STATUS='52') THEN
          L_STEP                         := '12';
          P_ERROR_CODE                   := 0;
          P_ERROR_MSG                    := 'Validation success for monthly payment';
          IF P_REQUEST_TYPE               ='MONEYTRANSFER' THEN
            L_STEP                       := '13';
            P_TF_REF_NO                  := 'TFMGM'||TO_CHAR(SYSDATE,'yyyymmdd')||sa.SEQU_X_MG_REFERENCE.NEXTVAL;
            REFILL_BB (LiD_REC.ESN, PAYCODE_REC.X_PN_PINM, 'WEB', ---default web
            P_DENOMINATION, P_X_SMP, P_ERROR_CODE, P_ERROR_MSG);
          END IF;
          --CR39488 to allow $10 caards through MG by Srini
        ELSIF (PAYCODE_REC.X_RECEIVE_CODE = 'RED' AND LID_REC.ORG_ID = 'TRACFONE' AND PAYCODE_REC.X_DENOCODE = P_DENOMINATION AND LID_REC.SITE_PART_STATUS='Active' AND LID_REC.X_PART_INST_STATUS='52') THEN
          DBMS_OUTPUT.PUT_LINE('CHECKING');
          L_STEP           := '12';
		  IF v_src_sp_grp = 'TFSL_UNLIMITED' AND v_dest_sp_grp <> 'TFSL_UNLIMITED' THEN
			 P_ERROR_CODE                  := 35;
			 P_ERROR_MSG                   := 'Pay go cards cannot be purchased while receiving Unlimited benefits';
			 DBMS_OUTPUT.PUT_LINE('Paygo Card purchase While UNLIMTED - Validation request RED');
          ELSE
		     P_ERROR_CODE     := 0;
             P_ERROR_MSG      := 'Validation success for monthly payment';
          END IF;

		  IF P_REQUEST_TYPE ='MONEYTRANSFER' THEN
            L_STEP         := '13';
			IF v_src_sp_grp = 'TFSL_UNLIMITED' AND v_dest_sp_grp <> 'TFSL_UNLIMITED' THEN
			  P_ERROR_CODE                  := 35;
			  P_ERROR_MSG                   := 'Pay go cards cannot be purchased while receiving Unlimited benefits';
			  DBMS_OUTPUT.PUT_LINE('Paygo Card purchase While UNLIMTED - Money Transfer request RED');
			ELSE
             P_TF_REF_NO    := 'TFMGM'||TO_CHAR(SYSDATE,'yyyymmdd')||sa.SEQU_X_MG_REFERENCE.NEXTVAL;
             REFILL_TF_RED_CARD (LiD_REC.ESN, PAYCODE_REC.X_PN_PINM, 'WEB', ---default web
             P_DENOMINATION, P_X_SMP, P_ERROR_CODE, P_ERROR_MSG);
			END IF;

			IF P_ERROR_CODE <> 0 THEN
			   V_ERROR_CODE2                 :=100; -- Fail MoneyTransfer
			END IF;
          END IF; --END CR39488 by Srini
        ELSIF PAYCODE_REC.X_RECEIVE_CODE = 'ACT' AND LID_REC.ORG_ID = 'NET10' THEN
          P_ERROR_CODE                  := 4;
          P_ERROR_MSG                   := 'Expected receive code for monthly, received initial';
          V_ERROR_CODE2                 :=100; -- Fail MoneyTransfer
        ELSIF PAYCODE_REC.X_RECEIVE_CODE = 'RED' AND LID_REC.ORG_ID = 'TRACFONE' THEN
          P_ERROR_CODE                  := 5;
          P_ERROR_MSG                   := 'Expected receive code for initial, received monthly';
          V_ERROR_CODE2                 :=100; -- Fail MoneyTransfer
        ELSIF PAYCODE_REC.X_DENOCODE    != P_DENOMINATION THEN
          P_ERROR_CODE                  := 6;
          P_ERROR_MSG                   := 'Incorrect denomination for this plan';
          V_ERROR_CODE2                 :=100;                                                -- Fail MoneyTransfer
        ELSIF (LID_REC.SITE_PART_STATUS !='Active' OR LID_REC.X_PART_INST_STATUS!='52') THEN ---esn is not active
          l_step                        := '11';
          P_ERROR_CODE                  := 8;
          P_ERROR_MSG                   := 'Inactive ESN';
          V_ERROR_CODE2                 :=100; -- Fail MoneyTransfer
        ELSE
          P_ERROR_CODE := 9;
          P_ERROR_MSG  := 'Other validation failure';
          V_ERROR_CODE2:=100; -- Fail MoneyTransfer
        END IF;
        -- PAYCO_CURS IF
      ELSE
      DBMS_OUTPUT.PUT_LINE('PAYCODE_CURS else loop');
        L_STEP := '16';
        OPEN CHECK_DENO_CURS (lv_plan);
        FETCH CHECK_DENO_CURS INTO CHECK_DENO_REC;
        IF CHECK_DENO_CURS%FOUND THEN
          P_ERROR_CODE  := 6;
          P_ERROR_MSG   := 'Incorrect denomination for this plan';
          V_ERROR_CODE2 :=100;
          CLOSE CHECK_DENO_CURS;
        ELSE
        DBMS_OUTPUT.PUT_LINE('DENO_CURS else loop');
          CLOSE CHECK_DENO_CURS;
          IF p_paycode = rec_monergram_lookup.x_paycode AND rec_monergram_lookup.x_provision_flag IN (1, 2, 3) THEN
            IF LID_REC.X_REQUESTED_PLAN NOT LIKE 'Lifeline - '||rec_monergram_lookup.X_STATE||'%' THEN ---NEED TO CHECK ASHISH %
              P_ERROR_CODE := 9;
              P_ERROR_MSG  := 'Customer plan is not Lifeline - '||rec_monergram_lookup.X_STATE;
              V_ERROR_CODE2:=100; -- Fail MoneyTransfer
            ELSE
              P_ERROR_CODE := 2;
              P_ERROR_MSG  := 'Receive code not found PAYCODE_REC.X_RECEIVE_CODE: '||PAYCODE_REC.X_RECEIVE_CODE||' lc_e911_receivecode: '||rec_monergram_lookup.X_RECEIVE_CODE||' LID_REC.X_REQUESTED_PLAN: '||LID_REC.X_REQUESTED_PLAN;
              V_ERROR_CODE2:=100; -- Fail MoneyTransfer
            END IF;
            -- if (p_paycode = lc_e911_paycode)then
            -- IF LID_REC.X_REQUESTED_PLAN NOT LIKE 'Lifeline - AL%' THEN
            -- P_ERROR_CODE := 9;
            -- P_ERROR_MSG := 'Customer plan is not Lifeline - AL';
            -- V_ERROR_CODE2:=100; -- Fail MoneyTransfer
            -- ELSE
            -- P_ERROR_CODE := 2;
            -- P_ERROR_MSG := 'Receive code not found';
            -- V_ERROR_CODE2:=100; -- Fail MoneyTransfer
            -- END IF;
          ELSE
            IF LID_REC.X_REQUESTED_PLAN NOT LIKE '%BB%' THEN
              P_ERROR_CODE := 1;
              P_ERROR_MSG  := 'Customer plan is not SafeLink Broadband';
              V_ERROR_CODE2:=100; -- Fail MoneyTransfer
            ELSE
              P_ERROR_CODE := 2;
              P_ERROR_MSG  := 'Receive code not found';
              V_ERROR_CODE2:=100; -- Fail MoneyTransfer
            END IF;
          END IF ;
        END IF; --CHECK_DENO_CURS
      END IF;   --PAYCODE_CURS
      CLOSE PAYCODE_CURS;
      -- LID_CURS IF
    ELSE
      L_STEP      := '17';
      IF p_paycode = rec_monergram_lookup.X_paycode AND rec_monergram_lookup.x_provision_flag =1 THEN
        -- if (p_paycode = lc_e911_paycode) then
        P_ERROR_CODE := 9;
      ELSE
        P_ERROR_CODE := 3;
      END IF;
      P_ERROR_MSG  := 'MIN is not active or enrolled in SafeLink program';
      V_ERROR_CODE2:=100; -- Fail MoneyTransfer
    END IF;
    CLOSE LID_CURS;
    /*** check error *****/
    /** NEW CODE FOR MAPPING ERROR TRACFONE AND MONEYGRAM **/
    IF P_REQUEST_TYPE = 'VALIDATION' AND P_ERROR_CODE != 0 THEN
      L_STEP         := '20';
      OPEN MG_ERROR_CURS(P_ERROR_CODE);
      FETCH MG_ERROR_CURS INTO MG_ERROR_rec;
      IF MG_ERROR_CURS%FOUND THEN
        L_STEP            := '21';
        P_MG_VALID        :=MG_ERROR_rec.MG_VALID;
        P_MG_RESPONSE_CODE:=MG_ERROR_REC.MG_RESPONSE_CODE;
        P_MG_ERROR_MSG    :=MG_ERROR_rec.MG_ERROR_MSG;
      ELSE
        L_STEP            := '22';
        P_MG_VALID        :='FAIL';
        P_MG_RESPONSE_CODE:='OTHER';
        P_MG_ERROR_MSG    :='MGI_ERROR_CODE=1046MESSAGE=The request didnt pass validation process.';
      END IF;
	  DBMS_OUTPUT.PUT_LINE('P_ERROR_MSG'||P_ERROR_MSG);
	  DBMS_OUTPUT.PUT_LINE('P_MG_ERROR_MSG'||P_MG_ERROR_MSG);
      CLOSE MG_ERROR_CURS;
    ELSIF P_REQUEST_TYPE = 'VALIDATION' AND P_ERROR_CODE = 0 THEN
      L_STEP            := '23';
      P_MG_VALID        :='PASS';
      P_MG_RESPONSE_CODE:=NULL;
      P_MG_ERROR_MSG    :=NULL;
    ELSIF P_REQUEST_TYPE = 'MONEYTRANSFER' THEN
      L_STEP            := '23';
      DBMS_OUTPUT.PUT_LINE('V_ERROR_CODE2 '||V_ERROR_CODE2);
      P_MG_VALID        :=
      CASE
      WHEN V_ERROR_CODE2=100 THEN
        'FAIL'
      ELSE
        'PASS'
      END;
      P_MG_RESPONSE_CODE:=
      CASE
      WHEN V_ERROR_CODE2=100 THEN
        '01409'
      END;
      P_MG_ERROR_MSG:=
      CASE
      WHEN V_ERROR_CODE2=100 THEN
        'Other Reject'
      END;
      DBMS_OUTPUT.PUT_LINE('P_MG_ERROR_MSG'||P_MG_ERROR_MSG);
    ELSE
      L_STEP            := '24';
      P_ERROR_CODE      :=101;
      P_ERROR_MSG       := 'Invalid Request type, expecting VALIDATION or MONEYTRANSFER';
      P_MG_VALID        :='FAIL';
      P_MG_RESPONSE_CODE:='OTHER';
      P_MG_ERROR_MSG    :='MGI_ERROR_CODE=1046MESSAGE=The request didnt pass validation process.';
    END IF;
  END IF;
  CLOSE DUP_PAYMENT_CURS;
  IF p_paycode = rec_monergram_lookup.X_paycode AND rec_monergram_lookup.x_provision_flag =1 THEN
    -- IF p_paycode = lc_e911_paycode THEN
    lv_payment_type := 'SAFELINK E911';
  ELSIF p_paycode    = rec_monergram_lookup.X_paycode AND rec_monergram_lookup.x_provision_flag IN (2, 3) THEN
    -- elsif p_paycode IN (lc_ca_data_card_paycode, lc_ca_ild_paycode) THEN
    lv_payment_type := 'SAFELINK AIRTIME';
  ELSIF p_paycode    = '69985548' THEN --$10 card for 350 minute plan
    lv_payment_type := 'SAFELINK $10 RELEASE CARD';
  ELSE
    lv_payment_type := 'SAFELINK BB';
  END IF;
  /* CR29021 changes starts */
  IF p_paycode = rec_monergram_lookup.X_paycode AND rec_monergram_lookup.x_provision_flag =1 THEN
    --IF P_PAYCODE = lc_e911_paycode THEN
    DBMS_OUTPUT.PUT_LINE(' p_error_code='||p_error_code||',p_error_msg='||p_error_msg);
    IF P_REQUEST_TYPE = 'MONEYTRANSFER' AND p_error_msg = 'E911SUCCESS' THEN
      p_tf_ref_no    := 'TFE911'||TO_CHAR(sysdate,'yyyymmdd')||sa.sequ_x_mg_reference.nextval;
      INSERT
      INTO X_MG_TRANSACTIONs
        (
          OBJID,
          X_RQST_TYPE,
          X_VENDOR_ID ,
          X_VENDOR_NAME ,
          X_DATE_TRANS ,
          X_PAYCODE ,       --agentid
          X_MIN ,           --account number
          X_DENOMINATION , ---amount
          X_REFER ,         --agent referent
          X_FIRST_NAME_c ,
          x_LASTNAME_c ,
          x_ADDRESS_c ,
          X_CITY_c ,
          x_STATE_c ,
          x_COUNTRY_c ,
          X_ZIP_C ,
          X_PHONE_c,
          X_STATUS ,              --pass , fail, error in validation
          X_RESP_CODE ,           -- error code
          X_RESP_MESSAGE ,        -- error msg
          X_MG_REFERENCE_NUMBER , --mg reference,
          X_TF_REFERENCE_NUMBER , -- tf sequence for references
          X_BILL_CURRENT ,
          X_PAYMENT_TYPE, -- 'safelink BB/b2b/mobile_billing/any future)
          X_TAX_AMOUNT ,
          X_ACTUAL_AMOUNT ,
          X_ACTUAL_TAX_AMOUNT ,
          X_BILL_AMOUNT,
          X_LID,
          X_ESN ,
          X_CASE,
          X_SMP
        )
        VALUES
        (
          sa.SEQU_X_MG_TRANSACTIONS.NEXTVAL,
          P_REQUEST_TYPE,
          '1',
          'Moneygram',
          SYSDATE,
          P_PAYCODE,
          P_MIN,
          P_DENOMINATION,
          P_REFER,
          P_FIRST_NAME_S,
          P_LASTNAME_S,
          P_ADDRESS_S,
          P_CITY_S,
          P_STATE_S,
          P_COUNTRY_S,
          P_ZIP_S,
          P_PHONE_S,
          P_MG_VALID, --(decode(p_error_code,0,'PASS','FAIL')),
          P_ERROR_CODE,
          P_ERROR_MSG,
          P_REFER,
          P_TF_REF_NO,
          0,                  --X_BILL_CURRENT
          lv_payment_type,    --'SAFELINK E911', --X_PAYMENT_TYPE
          lv_e911_unit_amount,--X_TAX_AMOUNT
          0,                  --X_ACTUAL_AMOUNT
          P_DENOMINATION,     --X_ACTUAL_TAX_AMOUNT
          P_DENOMINATION,     --X_BILL_AMOUNT
          LID_REC.LID,
          lid_rec.esn,
          NULL, --X_CASE
          NULL  --X_SMP
        );
    elsIF p_error_msg       != 'E911SUCCESS' OR p_error_code <> 0 OR (P_REQUEST_TYPE = 'VALIDATION' AND p_error_msg = 'E911SUCCESS') THEN
      IF NOT (P_REQUEST_TYPE = 'VALIDATION' AND p_error_msg = 'E911SUCCESS') THEN
        IF p_error_code     <> 221 THEN
          OPEN MG_ERROR_CURS(P_ERROR_CODE);
          FETCH MG_ERROR_CURS INTO MG_ERROR_rec;
          IF MG_ERROR_CURS%FOUND THEN
            L_STEP            := '211';
            P_MG_VALID        :=MG_ERROR_rec.MG_VALID;
            P_MG_RESPONSE_CODE:=MG_ERROR_REC.MG_RESPONSE_CODE;
            P_MG_ERROR_MSG    :=MG_ERROR_rec.MG_ERROR_MSG;
          ELSE
            L_STEP            := '222';
            P_MG_VALID        :='FAIL';
            P_MG_RESPONSE_CODE:='OTHER';
            P_MG_ERROR_MSG    :='MGI_ERROR_CODE=1046MESSAGE=The request didnt pass validation process.';
          END IF;
        END IF;
      END IF;
      INSERT
      INTO X_MG_TRANSACTIONS_LOG
        (
          OBJID,
          X_RQST_TYPE,
          X_VENDOR_ID ,
          X_VENDOR_NAME ,
          X_DATE_TRANS ,
          X_PAYCODE ,       --agentid
          X_MIN ,           --account number
          X_DENOMINATION , ---amount
          X_FIRST_NAME_C ,
          x_LASTNAME_c ,
          x_ADDRESS_c ,
          X_CITY_c ,
          x_STATE_c ,
          x_COUNTRY_c ,
          X_ZIP_C ,
          X_PHONE_c,
          X_STATUS ,       --pass , fail, error in validation
          X_RESP_CODE ,    -- error code
          X_RESP_MESSAGE , -- error msg
          X_PAYMENT_TYPE,  -- 'safelink BB/b2b/mobile_billing/any future)
          X_LID,
          X_ESN
        )
        VALUES
        (
          sa.SEQU_X_MG_TRANSACTIONS_LOG.NEXTVAL,
          P_REQUEST_TYPE,
          '1',
          'Moneygram',
          SYSDATE,
          P_PAYCODE,
          P_MIN,
          P_DENOMINATION,
          P_FIRST_NAME_S,
          P_LASTNAME_S,
          P_ADDRESS_S,
          P_CITY_S,
          P_STATE_S,
          P_COUNTRY_S,
          P_ZIP_S,
          P_PHONE_S,
          P_MG_VALID, --(decode(p_error_code,0,'PASS','FAIL')),
          P_ERROR_CODE,
          P_ERROR_MSG,
          lv_payment_type,--X_PAYMENT_TYPE
          LID_REC.LID,
          LID_REC.ESN
        );
    END IF;
    /* CR29021 changes ends */
  ELSE
    IF P_REQUEST_TYPE = 'MONEYTRANSFER' AND P_ERROR_CODE!= 221 THEN
      L_STEP         := '18';
      --TO TAX ABSORB
      IF NVL(PAYCODE_REC.X_TAXABLE,'Y') = 'Y' THEN
        V_TAXRATE                      :=sa.sp_taxes.computetax2(LID_REC.ZIP,NULL);
      ELSE
        PAYCODE_REC.TOTAL_BASE_AMOUNT := PAYCODE_REC.X_DENOCODE;
      END IF;
      INSERT
      INTO X_MG_TRANSACTIONs
        (
          OBJID,
          X_RQST_TYPE,
          X_VENDOR_ID ,
          X_VENDOR_NAME ,
          X_DATE_TRANS ,
          X_PAYCODE ,       --agentid
          X_MIN ,           --account number
          X_DENOMINATION , ---amount
          X_REFER ,         --agent referent
          X_FIRST_NAME_c ,
          x_LASTNAME_c ,
          x_ADDRESS_c ,
          X_CITY_c ,
          x_STATE_c ,
          x_COUNTRY_c ,
          X_ZIP_C ,
          X_PHONE_c,
          X_STATUS ,              --pass , fail, error in validation
          X_RESP_CODE ,           -- error code
          X_RESP_MESSAGE ,        -- error msg
          X_MG_REFERENCE_NUMBER , --mg reference,
          X_TF_REFERENCE_NUMBER , -- tf sequence for references
          X_BILL_CURRENT ,
          X_PAYMENT_TYPE, -- 'safelink BB/b2b/mobile_billing/any future)
          X_TAX_AMOUNT ,
          X_ACTUAL_AMOUNT ,
          X_ACTUAL_TAX_AMOUNT ,
          X_BILL_AMOUNT,
          X_LID,
          X_ESN ,
          X_CASE,
          X_SMP,
          X_RCF, --byop requirement
          X_USF, --byop requirement
          X_E911
        ) --byop requirement
        VALUES
        (
          sa.SEQU_X_MG_TRANSACTIONS.NEXTVAL,
          P_REQUEST_TYPE,
          '1',
          'Moneygram',
          SYSDATE,
          P_PAYCODE,
          P_MIN,
          P_DENOMINATION,
          P_REFER,
          P_FIRST_NAME_S,
          P_LASTNAME_S,
          P_ADDRESS_S,
          P_CITY_S,
          P_STATE_S,
          P_COUNTRY_S,
          P_ZIP_S,
          P_PHONE_S,
          P_MG_VALID, --(decode(p_error_code,0,'PASS','FAIL')),
          P_ERROR_CODE,
          P_ERROR_MSG,
          P_REFER,
          P_TF_REF_NO,
          0,                                                            --X_BILL_CURRENT
          lv_payment_type,                                              --X_PAYMENT_TYPE
          ROUND(PAYCODE_REC.X_DENOCODE-PAYCODE_REC.TOTAL_BASE_AMOUNT,2),--X_TAX_AMOUNT
          ROUND(PAYCODE_REC.TOTAL_BASE_AMOUNT,2),                       --X_ACTUAL_AMOUNT
          ROUND(PAYCODE_REC.TOTAL_BASE_AMOUNT*V_TAXRATE,2),             --X_ACTUAL_TAX_AMOUNT
          ROUND(PAYCODE_REC.TOTAL_BASE_AMOUNT,2),                       --X_BILL_AMOUNT
          LID_REC.LID,
          LID_REC.ESN,
          P_CASE_ID,
          P_x_smp,
          LN_RCRFAMT, --byop requirement
          LN_USFAMT,  --byop requirement
          LN_E911AMT  --byop requirement
        );

    ELSE
      --
      -- insert into x_mg_transactions_log
      --
      L_STEP := '19';
      INSERT
      INTO X_MG_TRANSACTIONS_LOG
        (
          OBJID,
          X_RQST_TYPE,
          X_VENDOR_ID ,
          X_VENDOR_NAME ,
          X_DATE_TRANS ,
          X_PAYCODE ,       --agentid
          X_MIN ,           --account number
          X_DENOMINATION , ---amount
          X_FIRST_NAME_C ,
          x_LASTNAME_c ,
          x_ADDRESS_c ,
          X_CITY_c ,
          x_STATE_c ,
          x_COUNTRY_c ,
          X_ZIP_C ,
          X_PHONE_c,
          X_STATUS ,       --pass , fail, error in validation
          X_RESP_CODE ,    -- error code
          X_RESP_MESSAGE , -- error msg
          X_PAYMENT_TYPE,  -- 'safelink BB/b2b/mobile_billing/any future)
          X_LID,
          X_ESN
        )
        VALUES
        (
          sa.SEQU_X_MG_TRANSACTIONS_LOG.NEXTVAL,
          P_REQUEST_TYPE,
          '1',
          'Moneygram',
          SYSDATE,
          P_PAYCODE,
          P_MIN,
          P_DENOMINATION,
          P_FIRST_NAME_S,
          P_LASTNAME_S,
          P_ADDRESS_S,
          P_CITY_S,
          P_STATE_S,
          P_COUNTRY_S,
          P_ZIP_S,
          P_PHONE_S,
          P_MG_VALID, --(decode(p_error_code,0,'PASS','FAIL')),
          P_ERROR_CODE,
          P_ERROR_MSG,
          lv_payment_type,
          LID_REC.LID,
          LID_REC.ESN
        );
    END IF;
  END IF;
  COMMIT;
EXCEPTION
WHEN OTHERS THEN
  P_ERROR_CODE      :=99;
  P_ERROR_MSG       := 'When others errors moneytransfer';
  L_STEP            := L_STEP||':'||SQLCODE||':'||SQLERRM;
  P_MG_VALID        :='FAIL';
  P_MG_RESPONSE_CODE:=
  CASE
  WHEN P_REQUEST_TYPE = 'MONEYTRANSFER' THEN
    '01409'
  ELSE
    'OTHER'
  END;
  P_MG_ERROR_MSG:=
  CASE
  WHEN P_REQUEST_TYPE = 'MONEYTRANSFER' THEN
    'Other Rejec'
  ELSE
    'MGI_ERROR_CODE=1046MESSAGE=The request didnt pass validation process.'
  END;
  INSERT
  INTO ERROR_TABLE
    (
      ERROR_TEXT,
      ERROR_DATE ,
      ACTION,
      KEY,
      PROGRAM_NAME
    )
    VALUES
    (
      L_STEP,
      SYSDATE,
      'Monetransfer',
      P_MIN,
      'Moneytransfer'
    );
END moneytransfer;
PROCEDURE VALIDATE_DENOCODE
  (
    P_PAYCODE      IN VARCHAR2,
    P_DENOMINATION IN NUMBER,
    P_RECEIVE_CODE IN VARCHAR2,
    P_ERROR_CODE OUT NUMBER,
    p_error_msg OUT VARCHAR2
  )
IS
  /* Return 0=success 1=failure */
  CURSOR denocode_curs
  IS
    SELECT PI.*
    FROM sa.X_BB_deno_codes PI
    WHERE 1               = 1
    AND PI.X_PAYCODE      = P_PAYCODE
    AND PI.X_DENOCODE     = P_DENOMINATION
    AND PI.X_RECEIVE_CODE = p_receive_code;
  DENOCODE_REC DENOCODE_CURS%ROWTYPE;
  l_step VARCHAR2(100);
BEGIN
  P_ERROR_CODE :=0;
  l_step       :=1;
  OPEN denocode_curs;
  FETCH denocode_curs INTO denocode_rec;
  IF denocode_CURS%NOTFOUND THEN
    P_ERROR_CODE := 1;
    p_error_msg  := 'DENOMINATION AND CODE NOT FOUND';
  END IF;
  CLOSE denocode_curs;
EXCEPTION
WHEN OTHERS THEN
  P_ERROR_CODE :=98;
  P_ERROR_MSG  := 'when others errors validate_denocode';
  L_STEP       := L_STEP||':'||SQLCODE||':'||SQLERRM;
  INSERT
  INTO ERROR_TABLE
    (
      ERROR_TEXT,
      ERROR_DATE ,
      ACTION,
      KEY,
      PROGRAM_NAME
    )
    VALUES
    (
      L_STEP,
      SYSDATE,
      'VALIDATE_DENOCODE',
      P_PAYCODE,
      'VALIDATE_DENOCODE'
    );
END VALIDATE_DENOCODE;
PROCEDURE CREATE_ACCOUNT
  (
    P_LID           IN VARCHAR2,
    P_CONTACT_OBJID IN NUMBER,
    P_NEW_CONTACT_OBJID OUT NUMBER,
    P_ERROR_CODE OUT NUMBER,
    P_ERROR_MSG OUT VARCHAR2
  )
IS
  /* Return 0=success 1=failed */
  P_ESN               VARCHAR2(30);
  P_FIRST_NAME        VARCHAR2(100);
  P_LAST_NAME         VARCHAR2(100);
  P_MIDDLE_NAME       VARCHAR2(100);
  P_ADD1              VARCHAR2(200);
  P_ADD2              VARCHAR2(200);
  P_FAX               VARCHAR2(100);
  P_CITY              VARCHAR2(100);
  P_ST                VARCHAR2(100);
  P_ZIP               VARCHAR2(100);
  P_EMAIL             VARCHAR2(100);
  P_phone             VARCHAR2(100);
  P_EMAIL_STATUS      NUMBER;
  p_roadside_status   NUMBER;
  P_NO_NAME_FLAG      NUMBER;
  p_no_phone_flag     NUMBER;
  P_NO_ADDRESS_FLAG   NUMBER;
  P_SOURCESYSTEM      VARCHAR2(100);
  p_brand_name        VARCHAR2(100);
  P_DO_NOT_EMAIL      NUMBER;
  p_do_not_phone      NUMBER;
  p_do_not_mail       NUMBER;
  P_DO_NOT_SMS        NUMBER;
  P_SSN               VARCHAR2(100);
  p_dob               DATE;
  P_DO_NOT_MOBILE_ADS NUMBER;
  P_ERR_CODE          VARCHAR2(30);
  p_err_msg           VARCHAR2(100);
  CURSOR CONTACT_CURS
  IS
    SELECT C.OBJID OLD_OBJID,
      C.FIRST_NAME,
      C.LAST_NAME ,
      C.X_MIDDLE_INITIAL,
      C.PHONE,
      C.ADDRESS_1,
      C.ADDRESS_2,
      C.FAX_NUMBER,
      C.CITY,
      C.STATE,
      C.ZIPCODE,
      C.E_MAIL,
      C.X_EMAIL_STATUS,
      C.X_ROADSIDE_STATUS,
      C.X_NO_NAME_FLAG,
      C.X_NO_PHONE_FLAG,
      C.X_NO_ADDRESS_FLAG,
      ADC.OBJID OBJID_ADD,
      ADC.X_DO_NOT_EMAIL,
      ADC.X_DO_NOT_PHONE,
      ADC.X_DO_NOT_SMS,
      ADC.X_DO_NOT_MAIL,
      c.X_SS_NUMBER,
      ADC.X_DATEOFBIRTH,
      ADC.X_DO_NOT_MOBILE_ADS
    FROM TABLE_CONTACT C,
      TABLE_X_CONTACT_ADD_INFO ADC
    WHERE C.OBJID            = P_CONTACT_OBJID
    AND ADC.ADD_INFO2CONTACT = C.OBJID;
  --and c.objid = 890300272 ;
  contact_rec contact_curs%rowtype;
  CURSOR USER_CURS ( v_objid IN NUMBER)
  IS
    SELECT *
    FROM TABLE_WEB_USER
    WHERE WEB_USER2CONTACT IN
      ( SELECT OBJID FROM TABLE_CONTACT WHERE OBJID = v_objid
      );
  USER_REC USER_CURS%ROWTYPE;
  l_step VARCHAR2(100);
BEGIN
  P_ERROR_CODE :=0;
  l_step       :='1';
  OPEN CONTACT_CURS;
  FETCH CONTACT_CURS INTO CONTACT_REC;
  IF contact_CURS%NOTFOUND THEN
    P_ERROR_CODE := 1;
    P_ERROR_MSG  := 'contact NOT FOUND';
  ELSE
    /*** create new contact *****/
    P_ESN               := NULL;
    P_FIRST_NAME        := CONTACT_REC.FIRST_NAME;
    P_LAST_NAME         := CONTACT_REC.LAST_NAME ;
    P_MIDDLE_NAME       := contact_rec.x_middle_initial;
    P_PHONE             := CONTACT_REC.PHONE;
    P_ADD1              := CONTACT_REC.ADDRESS_1;
    P_ADD2              := contact_rec.address_2;
    P_FAX               := CONTACT_REC.FAX_NUMBER;
    P_CITY              := CONTACT_REC.CITY;
    P_ST                := CONTACT_REC.STATE;
    P_ZIP               :=CONTACT_REC.ZIPCODE;
    P_EMAIL             :=CONTACT_REC.E_MAIL;
    P_EMAIL_STATUS      := CONTACT_REC.X_EMAIL_STATUS;
    P_ROADSIDE_STATUS   := CONTACT_REC.X_ROADSIDE_STATUS;
    P_NO_NAME_FLAG      := CONTACT_REC.x_no_name_flag;
    P_NO_PHONE_FLAG     := CONTACT_REC.X_NO_PHONE_FLAG;
    P_NO_ADDRESS_FLAG   := CONTACT_REC.x_no_address_flag;
    P_SOURCESYSTEM      := 'WEB';
    P_BRAND_NAME        := 'NET10'; -- Ramu: NULL ESN is working
    P_DO_NOT_EMAIL      := CONTACT_REC.X_DO_NOT_EMAIL;
    P_DO_NOT_PHONE      := CONTACT_REC.X_DO_NOT_PHONE;
    P_DO_NOT_MAIL       := CONTACT_REC.x_do_not_mail;
    P_DO_NOT_SMS        := CONTACT_REC.x_do_not_sms;
    P_SSN               := CONTACT_REC.X_SS_NUMBER;
    P_DOB               := CONTACT_REC.X_DATEOFBIRTH;
    P_DO_NOT_MOBILE_ADS := contact_rec.x_do_not_mobile_ads;
    CONTACT_PKG.CREATECONTACT_PRC( P_ESN => P_ESN, P_FIRST_NAME => P_FIRST_NAME, P_LAST_NAME => P_LAST_NAME, P_MIDDLE_NAME => P_MIDDLE_NAME, P_PHONE => P_PHONE, P_ADD1 => P_ADD1, P_ADD2 => P_ADD2, P_FAX => P_FAX, P_CITY => P_CITY, P_ST => P_ST, P_ZIP => P_ZIP, P_EMAIL => P_EMAIL, P_EMAIL_STATUS => P_EMAIL_STATUS, P_ROADSIDE_STATUS => P_ROADSIDE_STATUS, P_NO_NAME_FLAG => P_NO_NAME_FLAG, P_NO_PHONE_FLAG => P_NO_PHONE_FLAG, P_NO_ADDRESS_FLAG => P_NO_ADDRESS_FLAG, P_SOURCESYSTEM => P_SOURCESYSTEM, P_BRAND_NAME => P_BRAND_NAME, P_DO_NOT_EMAIL => P_DO_NOT_EMAIL, P_DO_NOT_PHONE => P_DO_NOT_PHONE, P_DO_NOT_MAIL => P_DO_NOT_MAIL, P_DO_NOT_SMS => P_DO_NOT_SMS, P_SSN => P_SSN, P_DOB => P_DOB, P_DO_NOT_MOBILE_ADS => P_DO_NOT_MOBILE_ADS, P_CONTACT_OBJID => P_NEW_CONTACT_OBJID, P_ERR_CODE => P_ERR_CODE, P_ERR_MSG => P_ERR_MSG );
    DBMS_OUTPUT.PUT_LINE('P_NEW_CONTACT_OBJID = ' || P_NEW_CONTACT_OBJID);
    DBMS_OUTPUT.PUT_LINE('P_ERR_CODE = ' || P_ERR_CODE);
    DBMS_OUTPUT.PUT_LINE('P_ERR_MSG = ' || P_ERR_MSG);
    IF P_ERR_CODE = '0' THEN
      /*
      -- Ramu: Commented out as the NULL ESN is working for CONTACT_PKG.CREATECONTACT_PRC()
      UPDATE TABLE_X_CONTACT_ADD_INFO
      SET ADD_INFO2BUS_ORG = ( SELECT OBJID FROM TABLE_BUS_ORG WHERE ORG_ID = 'NET10')
      WHERE ADD_INFO2CONTACT = P_NEW_CONTACT_OBJID; --890400029 new contact
      UPDATE TABLE_BUS_SITE_ROLE
      SET BUS_SITE_ROLE2BUS_ORG = ( SELECT OBJID FROM TABLE_BUS_ORG WHERE ORG_ID = 'NET10')
      WHERE BUS_SITE_ROLE2SITE = ( SELECT objid
      FROM TABLE_SITE
      WHERE OBJID IN ( SELECT CONTACT_ROLE2SITE
      FROM TABLE_CONTACT_ROLE
      WHERE CONTACT_ROLE2CONTACT = P_CONTACT_OBJID));
      */
      OPEN user_curs(contact_rec.old_objid);
      FETCH USER_CURS INTO user_rec;
      IF user_curs%NOTFOUND THEN
        P_ERROR_CODE := 1;
        P_ERROR_MSG  := 'USER WEB NOT FOUND';
      ELSE
        INSERT
        INTO TABLE_WEB_USER
          (
            OBJID ,
            LOGIN_NAME ,
            S_LOGIN_NAME ,
            PASSWORD ,
            USER_KEY ,
            STATUS ,
            PASSWD_CHG ,
            DEV ,
            SHIP_VIA ,
            X_SECRET_QUESTN ,
            S_X_SECRET_QUESTN ,
            X_SECRET_ANS ,
            S_X_SECRET_ANS ,
            WEB_USER2USER ,
            WEB_USER2CONTACT ,
            WEB_USER2LEAD ,
            WEB_USER2BUS_ORG ,
            X_LAST_UPDATE_DATE ,
            X_VALIDATED ,
            X_VALIDATED_COUNTER ,
            NAMED_USERID
          )
          VALUES
          (
            sa.SEQ('WEB_USER') , -- OBJID NUMBER
            'BB'
            ||P_LID
            ||'@safelink3.com', -- USER_REC.LOGIN_NAME ,
            'BB'
            ||P_LID
            ||'@SAFELINK3.COM', -- USER_REC.S_LOGIN_NAME ,
            user_rec.PASSWORD ,
            user_rec.USER_KEY ,
            user_rec.STATUS ,
            user_rec.PASSWD_CHG ,
            user_rec.DEV ,
            user_rec.SHIP_VIA ,
            user_rec.X_SECRET_QUESTN ,
            user_rec.S_X_SECRET_QUESTN ,
            user_rec.X_SECRET_ANS ,
            user_rec.S_X_SECRET_ANS ,
            USER_REC.WEB_USER2USER ,
            P_NEW_CONTACT_OBJID, -- Ramu: P_CONTACT_OBJID , --new contact id
            USER_REC.WEB_USER2LEAD ,
            (SELECT OBJID FROM TABLE_BUS_ORG WHERE ORG_ID = 'NET10'
            ),
            user_rec.X_LAST_UPDATE_DATE ,
            USER_REC.X_VALIDATED ,
            USER_REC.X_VALIDATED_COUNTER,
            '' -- CR42489 Named user id
          );
      END IF;
      CLOSE USER_CURS;
    END IF;
  END IF;
  CLOSE CONTACT_CURS;
  COMMIT;
EXCEPTION
WHEN OTHERS THEN
  P_ERROR_CODE :=97;
  P_ERROR_MSG  := 'when others errors create account ';
  L_STEP       := L_STEP||':'||SQLCODE||':'||SQLERRM;
  INSERT
  INTO ERROR_TABLE
    (
      ERROR_TEXT,
      ERROR_DATE ,
      ACTION,
      KEY,
      PROGRAM_NAME
    )
    VALUES
    (
      L_STEP,
      SYSDATE,
      'create_account',
      P_LID,
      'create_account'
    );
END create_account;
PROCEDURE ADD_ESN_TO_MYACCOUNT
  (
    P_ESN     IN VARCHAR2,
    P_CONTACT IN NUMBER,
    P_ERROR_CODE OUT NUMBER,
    P_ERROR_MSG OUT VARCHAR2
  )
AS
  /* Return 0=success 1=failed */
  CURSOR PART_INST_CURS
  IS
    SELECT * FROM TABLE_PART_INST PI WHERE PI.PART_SERIAL_NO = P_ESN;
  PART_INST_REC PART_INST_CURS%rowtype;
  CURSOR CHECK_MYACCT_CURS (PI_OBJID IN NUMBER)
  IS
    SELECT *
    FROM TABLE_X_CONTACT_PART_INST
    WHERE X_CONTACT_PART_INST2PART_INST = PI_OBJID;
  CHECK_MYACCT_REC CHECK_MYACCT_CURS%rowtype;
  CURSOR CONTACT_ROLE_CURS
  IS
    SELECT contact_role2site
    FROM table_contact_role
    WHERE contact_role2contact = P_CONTACT;
  CONTACT_ROLE_REC CONTACT_ROLE_CURS%rowtype;
  l_step VARCHAR2(100);
BEGIN
  OPEN PART_INST_CURS;
  FETCH PART_INST_CURS INTO PART_INST_REC;
  IF PART_INST_curs%NOTFOUND THEN
    P_ERROR_CODE := 1;
    P_ERROR_MSG  := 'Invalid Serial No.';
  ELSE
    OPEN CHECK_MYACCT_CURS(PART_INST_REC.OBJID);
    FETCH CHECK_MYACCT_CURS INTO CHECK_MYACCT_REC;
    IF CHECK_MYACCT_CURS%FOUND THEN
      DELETE
      FROM sa.TABLE_X_CONTACT_PART_INST CPI
      WHERE CPI.OBJID = CHECK_MYACCT_REC.OBJID;
    END IF;
    CLOSE CHECK_MYACCT_CURS;
    P_ERROR_CODE := 0;
    l_step       := '1';
    INSERT
    INTO sa.TABLE_X_CONTACT_PART_INST
      (
        OBJID,
        X_CONTACT_PART_INST2CONTACT,
        X_CONTACT_PART_INST2PART_INST,
        X_ESN_NICK_NAME,
        X_IS_DEFAULT,
        X_TRANSFER_FLAG,
        X_VERIFIED
      )
      VALUES
      (
        sa.SEQU_X_CONTACT_PART_INST.nextval,
        P_CONTACT,
        PART_INST_REC.OBJID,
        NULL,
        0,
        0,
        'Y'
      );
    UPDATE table_part_inst
    SET x_part_inst2contact = P_CONTACT
    WHERE objid             = PART_INST_REC.OBJID;
    OPEN CONTACT_ROLE_CURS;
    FETCH CONTACT_ROLE_CURS INTO CONTACT_ROLE_REC;
    IF CONTACT_ROLE_CURS%FOUND THEN
      UPDATE table_site_part
      SET site_part2site = CONTACT_ROLE_REC.contact_role2site
      WHERE x_service_id = P_ESN
      AND part_status
        ||''='Active';
    END IF;
    CLOSE CONTACT_ROLE_CURS;
    COMMIT;
  END IF;
  CLOSE PART_INST_CURS;
EXCEPTION
WHEN OTHERS THEN
  P_ERROR_CODE :=96;
  P_ERROR_MSG  := 'when others errors add_esn_to_myaccount';
  L_STEP       := L_STEP||':'||SQLCODE||':'||SQLERRM;
  INSERT
  INTO ERROR_TABLE
    (
      ERROR_TEXT,
      ERROR_DATE ,
      ACTION,
      KEY,
      PROGRAM_NAME
    )
    VALUES
    (
      L_STEP,
      SYSDATE,
      ' ADD_ESN_TO_MYACCOUNT',
      P_ESN ,
      ' ADD_ESN_TO_MYACCOUNT'
    );
END ADD_ESN_TO_MYACCOUNT;
PROCEDURE BB_ENROLLMENT
  (
    P_ESN          IN VARCHAR2,
    P_PROGRAM_NAME IN VARCHAR2,
    p_contact      IN NUMBER,
    P_ERROR_CODE OUT NUMBER,
    P_ERROR_MSG OUT VARCHAR2
  )
IS
  -- Ramu
  l_enroll_seq        NUMBER;
  L_PURCH_HDR_SEQ     NUMBER;
  L_PURCH_HDR_DTL_SEQ NUMBER;
  L_PROGRAM_TRANS_SEQ NUMBER;
  l_step              VARCHAR2(100);
  CURSOR PROGRAM_CURS
  IS
    SELECT pp.*,
      sa.SP_METADATA.GETPRICE(PN.PART_NUMBER,'BILLING') AMOUNT
    FROM X_PROGRAM_PARAMETERS PP,
      TABLE_PART_NUM PN
    WHERE X_PROGRAM_NAME LIKE 'Lifeline%BB%'
    AND X_PROGRAM_NAME           = P_PROGRAM_NAME
    AND PROG_PARAM2PRTNUM_MONFEE = PN.OBJID;
  program_rec program_curs%rowtype;
  CURSOR ENROLL_CURS
  IS
    SELECT
      /*+ rule */
      cv.lid,
      sp.objid sp_objid,
      pi.objid pi_objid,
      SP.X_MIN,
      SP.PART_STATUS SITE_PART_STATUS,
      PI.X_PART_INST_STATUS,
      SUBSTR(S.X_REQUESTED_PLAN,1,19) x_plan,
      sp.x_service_id ESN,
      bo.org_id,
      NVL(PI.X_PART_INST2CONTACT, S.SL_SUBS2TABLE_CONTACT) CONTACT_OBJID
    FROM sa.table_site_part sp,
      sa.x_sl_currentvals cv,
      sa.x_sl_subs s,
      sa.table_part_inst pi,
      sa.table_mod_level ml,
      sa.table_part_num pn,
      sa.TABLE_BUS_ORG BO
    WHERE sp.x_service_id = P_ESN
    AND sp.PART_STATUS
      ||''               ='Active'
    AND cv.X_CURRENT_ESN = sp.X_SERVICE_ID
    AND pi.X_PART_INST_STATUS
      ||''                      ='52'
    AND cv.lid                  = s.lid
    AND sp.x_service_id         = pi.part_serial_no
    AND pi.X_DOMAIN             = 'PHONES'
    AND pi.n_part_inst2part_mod = ml.objid
    AND ml.part_info2part_num   = pn.objid
    AND PN.PART_NUM2BUS_ORG     = BO.OBJID
    ORDER BY sp.install_date DESC,
      sp.objid DESC;
  enroll_rec enroll_curs%rowtype;
  CURSOR WEB_CURS (V_CONTACT IN NUMBER)
  IS
    SELECT objid web_objid
    FROM TABLE_WEB_USER
    WHERE web_user2contact = v_contact ;
  WEB_REC WEB_CURS%ROWTYPE;
BEGIN
  P_ERROR_CODE :=0;
  l_step       :='1';
  OPEN PROGRAM_CURS;
  FETCH PROGRAM_CURS INTO PROGRAM_REC;
  IF program_CURS%FOUND THEN
    OPEN ENROLL_CURS;
    FETCH ENROLL_CURS INTO ENROLL_REC;
    IF ENROLL_CURS%FOUND THEN
      OPEN WEB_CURS(p_CONTACT ); --ENROLL_REC.CONTACT_OBJID
      FETCH WEB_CURS INTO WEB_REC;
      IF WEB_CURS%FOUND THEN
        -- Ramu: Insert into all Billing tables
        l_enroll_seq        := sa.billing_seq ('X_PROGRAM_ENROLLED');
        l_purch_hdr_seq     := sa.billing_seq ('X_PROGRAM_PURCH_HDR');
        l_purch_hdr_dtl_seq := sa.billing_seq ('X_PROGRAM_PURCH_DTL');
        l_program_trans_seq := sa.billing_seq ('X_PROGRAM_TRANS');
        -- Ramu: Insert into program enrolled
        INSERT
        INTO x_program_enrolled
          (
            objid,
            x_esn,
            x_amount,
            x_type,
            x_sourcesystem,
            x_insert_date,
            x_charge_date,
            x_enrolled_date,
            x_start_date,
            x_reason,
            x_delivery_cycle_number,
            x_enroll_amount,
            x_language,
            x_enrollment_status,
            x_is_grp_primary,
            x_next_delivery_date,
            x_update_stamp,
            x_update_user,
            pgm_enroll2pgm_parameter,
            pgm_enroll2site_part,
            pgm_enroll2part_inst,
            pgm_enroll2contact,
            pgm_enroll2web_user,
            x_termscond_accepted
          )
          VALUES
          (
            L_ENROLL_SEQ,
            ENROLL_REC.ESN,
            program_rec.amount, --amount initial enrollemnt
            'INDIVIDUAL',
            'VMBC',
            SYSDATE,
            SYSDATE,
            SYSDATE,
            SYSDATE,
            'First Time Enrollment',
            1,
            0,
            'ENGLISH',
            'ENROLLED',
            1,
            NULL,
            SYSDATE,
            'SYSTEM',
            PROGRAM_REC.OBJID,
            ENROLL_REC.SP_OBJID,
            ENROLL_REC.PI_OBJID,
            p_contact, --ENROLL_REC.CONTACT_OBJID,
            web_rec.web_objid,
            1
          );
        -- Ramu: Insert into Program Purch Hdr
        -- Need to check with Javier if LL_ENROLL is ok or not for payment type
        INSERT
        INTO x_program_purch_hdr
          (
            objid,
            x_rqst_source,
            x_rqst_type,
            x_rqst_date,
            x_merchant_ref_number,
            x_ignore_avs,
            x_ics_rcode,
            x_ics_rflag,
            x_ics_rmsg,
            x_auth_rcode,
            x_auth_rflag,
            x_auth_rmsg,
            x_bill_rcode,
            x_bill_rflag,
            x_bill_rmsg,
            x_customer_email,
            x_status,
            x_bill_country,
            x_amount,
            x_tax_amount,
            x_e911_tax_amount,
            x_user,
            prog_hdr2web_user,
            x_payment_type
          )
          VALUES
          (
            l_purch_hdr_seq,
            'VMBC',
            'LIFELINE_PURCH',
            SYSDATE,
            'BPSAFELINK',
            'YES',
            '1',
            'SOK',
            'Request was processed successfully.',
            '1',
            'SOK',
            'Request was processed successfully.',
            '1',
            'SOK',
            'Request was processed successfully.',
            'NULL@CYBERSOURCE.COM',
            'LIFELINEPROCESSED',
            'USA',
            program_rec.amount,
            0,
            0,
            'SYSTEM',
            web_rec.web_objid,
            'LL_ENROLL'
          );
        -- Ramu: Insert into Program Purch Dtl
        INSERT
        INTO x_program_purch_dtl
          (
            objid,
            x_esn,
            x_amount,
            x_tax_amount,
            x_e911_tax_amount,
            x_charge_desc,
            x_cycle_start_date,
            x_cycle_end_date,
            pgm_purch_dtl2pgm_enrolled,
            pgm_purch_dtl2prog_hdr
          )
          VALUES
          (
            L_PURCH_HDR_DTL_SEQ,
            ENROLL_REC.esn,
            program_rec.amount,
            0,
            0,
            'First Time Enrollment',
            TRUNC (SYSDATE),
            TRUNC (SYSDATE) + 30,
            l_enroll_seq,
            l_purch_hdr_seq
          );
        -- Ramu: Insert into Program trans
        INSERT
        INTO x_program_trans
          (
            objid,
            x_enrollment_status,
            x_enroll_status_reason,
            x_trans_date,
            x_action_text,
            x_action_type,
            x_reason,
            x_sourcesystem,
            x_esn,
            x_update_user,
            pgm_tran2pgm_entrolled,
            pgm_trans2web_user,
            pgm_trans2site_part
          )
          VALUES
          (
            l_program_trans_seq,
            'ENROLLED',
            'FIRST TIME ENROLLMENT',
            SYSDATE,
            'ENROLLMENT ATTEMPT',
            'ENROLLMENT',
            'First Time Enrollment',
            'SYSTEM',
            ENROLL_REC.ESN,
            'SYSTEM',
            L_ENROLL_SEQ,
            web_rec.web_objid,
            ENROLL_REC.SP_OBJID
          );
        -- Ramu: Insert into X_BILLING_LOG is not needed at this moment
        /**** insert into x_sl_hist code = 607 ****/
        /** ramu
        /*** TRIG_X_PROGRAM_ENROLLED create record with 607 ****/
      ELSE
        P_ERROR_CODE := 1;
        P_ERROR_MSG  := 'CONTACT NOT found in webuser table ';
      END IF;
      CLOSE web_curs;
    ELSE
      P_ERROR_CODE := 2;
      P_ERROR_MSG  := 'ESN is not an active and enrolled SafeLink';
    END IF;
    CLOSE ENROLL_CURS;
  ELSE
    P_ERROR_CODE := 3;
    P_ERROR_MSG  := 'NOT FOUND Program Parameter is not valid BB program';
  END IF;
  CLOSE PROGRAM_CURS;
  COMMIT;
EXCEPTION
WHEN OTHERS THEN
  P_ERROR_CODE :=96;
  P_ERROR_MSG  := 'when others errors bb_enrollment';
  L_STEP       := L_STEP||':'||SQLCODE||':'||SQLERRM;
  INSERT
  INTO ERROR_TABLE
    (
      ERROR_TEXT,
      ERROR_DATE ,
      ACTION,
      KEY,
      PROGRAM_NAME
    )
    VALUES
    (
      L_STEP,
      SYSDATE,
      'BB_ENROLLMENT',
      P_ESN ,
      'BB_ENROLLMENT'
    );
END BB_ENROLLMENT;
PROCEDURE CREATE_ticket
  (
    P_MIN               IN VARCHAR2,
    P_ESN               IN VARCHAR2,
    p_contact_objid     IN NUMBER,
    P_PHONE_PART        IN VARCHAR2,
    P_CARD_PART         IN VARCHAR2,
    P_NEW_CONTACT_OBJID IN NUMBER, -- Ramu 05/07/2013
    p_case_ID OUT NUMBER,
    P_ERROR_CODE OUT NUMBER,
    P_ERROR_MSG OUT VARCHAR2
  )
IS
  P_CASE_TYPE     VARCHAR2(30);
  P_CASE_TITLE    VARCHAR2(80);
  P_CASE_STATUS   VARCHAR2(30):= 'Pending';
  P_CASE_PRIORITY NUMBER;
  P_CASE_SOURCE   VARCHAR2(30):='Web2';
  p_case_issue    VARCHAR2(80);
  P_USER_OBJID    NUMBER;
  P_CASE_PART_REQ VARCHAR2(80);
  P_CASE_NOTES    VARCHAR2(80);
  V_ID_NUMBER     VARCHAR2(200);
  v_part_req      VARCHAR2(400);
  op_case_objid   NUMBER;
  op_error_no     VARCHAR2(200);
  op_error_str    VARCHAR2(200);
  op_out_msg      VARCHAR2(400);
  v_c_dtl_rslt    VARCHAR2(200);
  is_wh_case      NUMBER;
  w_cnt           NUMBER;
  P_CASE_DETAIL   VARCHAR2(400); -- Ramu
  V_LID           VARCHAR2(40);  -- Ramu
  V_REQ_PLAN      VARCHAR2(60);  -- Ramu
  l_step          VARCHAR2(100);
  CURSOR get_case_header
  IS
    SELECT CH.X_TITLE,
      CH.X_CASE_TYPE,
      'SafeLink BroadBand Shipment - Warehouse' REASON,
      'LIFELINE' POINT_CONTACT,
      'Web2' SOURCE,
      (SELECT OBJID FROM TABLE_USER WHERE S_LOGIN_NAME = 'SA' AND rownum < 2
      ) SA_USER
  FROM sa.TABLE_X_CASE_CONF_HDR CH
  WHERE CH.S_X_TITLE   = 'SAFELINK BROADBAND SHIPMENT'
  AND CH.S_X_CASE_TYPE = 'WAREHOUSE';
  get_case_header_rec get_case_header%ROWTYPE;
  CURSOR GET_ENROLL
  IS
    SELECT *
    FROM
      (SELECT sp.objid sp_objid,
        CV.LID,
        SP.X_MIN,
        SP.PART_STATUS,
        sp.x_service_id,
        S.X_REQUESTED_PLAN,
        RANK() OVER(PARTITION BY SP.X_SERVICE_ID ORDER BY DECODE(PART_STATUS,'Active',1,'Inactive',2,3) ASC, SP.INSTALL_DATE DESC, SP.X_ACTUAL_EXPIRE_DT DESC) X_RANK
      FROM TABLE_SITE_PART SP
      JOIN X_SL_CURRENTVALS CV
      ON CV.X_CURRENT_ESN = SP.X_SERVICE_ID
      JOIN X_SL_SUBS S
      ON S.LID       = CV.LID
      WHERE SP.X_MIN = P_MIN
      )
  WHERE X_RANK = 1;
  GET_ENROLL_REC GET_ENROLL%ROWTYPE;
  CURSOR GET_contact_curs
  IS
    SELECT C.FIRST_NAME V_F_NAME,
      C.LAST_NAME V_L_NAME,
      C.PHONE V_PHONE,
      C.E_MAIL V_EMAIL,
      SUBSTR(TA.ADDRESS,0,90)
      ||
      CASE
        WHEN TA.ADDRESS_2 IS NOT NULL
        THEN '||'
          ||SUBSTR(TA.ADDRESS_2,0,90)
      END V_ADDR, --Ramu 05/07/2013
      TA.CITY V_CITY,
      TA.STATE V_ST,
      TA.ZIPCODE V_ZIP
    FROM TABLE_SITE TS,
      TABLE_ADDRESS TA,
      TABLE_CONTACT_ROLE TCR,
      TABLE_CONTACT C
    WHERE TCR.CONTACT_ROLE2SITE  = TS.OBJID
    AND TS.CUST_PRIMADDR2ADDRESS = TA.OBJID
    AND C.OBJID                  = TCR.CONTACT_ROLE2CONTACT
    AND TCR.CONTACT_ROLE2CONTACT = P_CONTACT_OBJID;
  GET_contact_REC GET_contact_curs%ROWTYPE;
BEGIN
  L_STEP      := '1';
  P_ERROR_CODE:=0;
  p_case_id   :=0;
  OPEN get_case_header;
  FETCH GET_CASE_HEADER INTO GET_CASE_HEADER_REC;
  IF get_case_header%NOTFOUND THEN
    P_ERROR_CODE := '1';
    p_error_msg  := 'ERROR: Case Header No found';
    CLOSE get_case_header;
    RETURN;
  END IF;
  OPEN get_enroll;
  FETCH get_enroll INTO get_enroll_rec;
  IF get_enroll%NOTFOUND THEN
    P_ERROR_CODE := '2';
    p_error_msg  := 'ERROR: ESN is not Enrolled Not found';
    CLOSE get_enroll;
    RETURN;
  ELSE
    v_lid      := get_enroll_rec.LID;
    v_req_plan := get_enroll_rec.X_REQUESTED_PLAN;
  END IF;
  CLOSE GET_ENROLL;
  CLOSE get_case_header;
  -- Ramu : Populate all the needed values for case details table
  OPEN GET_CONTACT_CURS;
  FETCH GET_CONTACT_CURS INTO GET_CONTACT_REC;
  P_CASE_DETAIL := 'LIFELINEID||'||v_lid||'||NEW_PLAN||'||v_req_plan||'||NEW_CONTACT_ID||'||P_NEW_CONTACT_OBJID; -- Ramu 05/07/2013
  -- CREATE CASE
  BEGIN
    sa.clarify_case_pkg.create_case (P_TITLE => get_case_header_rec.X_TITLE, P_CASE_TYPE =>get_case_header_rec.X_CASE_TYPE, P_STATUS =>'Pending', P_PRIORITY => NULL, P_ISSUE => '', P_SOURCE => get_case_header_rec.source, P_POINT_CONTACT => p_contact_objid, P_CREATION_TIME => sysdate, P_TASK_OBJID => NULL, P_CONTACT_OBJID => P_CONTACT_OBJID, P_USER_OBJID => get_case_header_rec.sa_user, P_ESN => P_ESN, P_PHONE_NUM => GET_CONTACT_REC.V_PHONE, P_FIRST_NAME => GET_CONTACT_REC.V_F_NAME, P_LAST_NAME => GET_CONTACT_REC.V_L_NAME, P_E_MAIL => get_contact_rec.v_email, P_DELIVERY_TYPE => NULL, P_ADDRESS => GET_CONTACT_REC.V_ADDR, P_CITY => GET_CONTACT_REC.V_CITY, P_STATE => GET_CONTACT_REC.V_ST, P_ZIPCODE => get_contact_rec.v_zip, P_REPL_UNITS => NULL, P_FRAUD_OBJID => NULL, P_CASE_DETAIL => P_CASE_DETAIL, -- Ramu: Value populated above
    P_PART_REQUEST => P_PHONE_PART||'||'||P_CARD_PART,                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                -- PART NUMBERS FROM CONFIGURATION
    P_ID_NUMBER => v_id_number, P_CASE_OBJID => op_case_objid, P_ERROR_NO => op_error_no, P_ERROR_STR => OP_ERROR_STR);
    P_CASE_ID:= OP_CASE_OBJID;
    -- IF CASE CREATION IS SUCCESS, LOG NOTES
    -- IF UNABLE TO LOG NOTES OR DETAILS JUST RETURN THE CASE ID NUMBER
    CLOSE GET_CONTACT_CURS;
    IF v_id_number IS NOT NULL THEN
      -- LOG NOTES
      BEGIN
        CLARIFY_CASE_PKG.LOG_NOTES (P_CASE_OBJID => op_case_objid, P_USER_OBJID => p_user_objid, P_NOTES => '', P_ACTION_TYPE => 'Agent Added Notes : ', P_ERROR_NO => op_error_no, P_ERROR_STR => op_error_str);
        -- Ramu: Pending of dispatch (Is this needed ?)
        CLARIFY_CASE_PKG.DISPATCH_CASE (P_CASE_OBJID => op_case_objid, P_USER_OBJID => p_user_objid, P_QUEUE_NAME => 'Warehouse', P_ERROR_NO => op_error_no, P_ERROR_STR => op_error_str);
      EXCEPTION
      WHEN OTHERS THEN
        NULL;
      END;
    END IF;
  END;
EXCEPTION
WHEN OTHERS THEN
  P_ERROR_CODE :=95;
  P_ERROR_MSG  := 'when others errors create ticket';
  L_STEP       := L_STEP||':'||SQLCODE||':'||SQLERRM;
  INSERT
  INTO ERROR_TABLE
    (
      ERROR_TEXT,
      ERROR_DATE ,
      ACTION,
      KEY,
      PROGRAM_NAME
    )
    VALUES
    (
      L_STEP,
      SYSDATE,
      'CREATE_TICKET',
      P_MIN ,
      'CREATE_TICKET'
    );
END CREATE_TICKET;
PROCEDURE INITIAL_BB
  (
    P_LID           IN VARCHAR2,
    P_ESN           IN VARCHAR2,
    P_MIN           IN VARCHAR2,
    P_PHONE_PART    IN VARCHAR2,
    P_CARD_PART     IN VARCHAR2,
    P_CONTACT_OBJID IN NUMBER,
    P_CASE_ID OUT NUMBER,
    P_ERROR_CODE OUT NUMBER,
    P_ERROR_MSG OUT VARCHAR2
  )
IS
  P_NEW_CONTACT NUMBER;
  L_STEP        VARCHAR2(100);
BEGIN
  P_ERROR_CODE := 0;
  p_case_id    := 0;
  l_step       := '1';
  CREATE_ACCOUNT(P_LID, P_CONTACT_OBJID, P_new_CONTACT, P_ERROR_CODE, P_ERROR_MSG);
  CREATE_TICKET (P_MIN, P_ESN , p_contact_objid, P_PHONE_PART, P_CARD_PART, P_new_CONTACT, -- Ramu 05/07/2013
  p_case_id, P_ERROR_CODE, P_ERROR_MSG);
EXCEPTION
WHEN OTHERS THEN
  P_ERROR_CODE :=94;
  P_ERROR_MSG  := 'When others errors initial_bb';
  L_STEP       := L_STEP||':'||SQLCODE||':'||SQLERRM;
  INSERT
  INTO ERROR_TABLE
    (
      ERROR_TEXT,
      ERROR_DATE ,
      ACTION,
      KEY,
      PROGRAM_NAME
    )
    VALUES
    (
      L_STEP,
      SYSDATE,
      'INITIAL_BB',
      P_MIN ,
      'INITIAL_BB'
    );
END INITIAL_BB;
PROCEDURE REFILL_BB
  (
    P_ESN          IN VARCHAR2,
    p_part_num_pin IN VARCHAR2,
    p_sourcesystem IN VARCHAR2, ---default WEB
    P_AMOUNT       IN NUMBER,
    p_X_SMP OUT VARCHAR2,
    p_error_code OUT NUMBER,
    p_error_message OUT VARCHAR2
  )
AS
  l_part_number VARCHAR2
  (
    200
  )
  ;
  l_part_status    VARCHAR2(200);
  l_plan_name      VARCHAR2(200);
  l_future_date    DATE;
  l_description    VARCHAR2(200);
  l_customer_price VARCHAR2(200);
  L_SITE_ID        VARCHAR2(30);
  l_step           VARCHAR2(100);
  --
  P_SEQ_NAME   VARCHAR2(200) := 'X_MERCH_REF_ID';
  O_NEXT_VALUE NUMBER;
  O_FORMAT     VARCHAR2(200);
  --P_RESERVE_ID NUMBER;
  P_TOTAL BINARY_INTEGER := 1;
  P_DOMAIN            VARCHAR2(200) := 'REDEMPTION CARDS';
  P_STATUS            VARCHAR2(200);
  P_MSG               VARCHAR2(200);
  op_call_trans_objid NUMBER;
  p_err_code          VARCHAR2(200);
  p_err_msg           VARCHAR2(200);
  CURSOR queue_card_days_curs
  IS
    SELECT NVL(SUM(x_redeem_days),0) queued_days
    FROM table_part_inst pi_esn,
      table_part_inst pi_qc,
      table_mod_level ml,
      table_part_num pn
    WHERE 1                         =1
    AND pi_esn.part_serial_no       = p_esn
    AND pi_esn.x_domain             = 'PHONES'
    AND pi_qc.part_to_esn2part_inst = pi_esn.objid
    AND pi_qc.x_part_inst_status    = '400'
    AND ml.objid                    = pi_qc.n_part_inst2part_mod
    AND pn.objid                    = ml.part_info2part_num;
  queue_card_days_rec queue_card_days_curs%rowtype;
  CURSOR pin_part_num_curs
  IS
    SELECT m.objid mod_level_objid,
      bo.org_id,
      PN.X_UPC,
      PN.PART_NUMBER,
      pn.x_redeem_days
    FROM table_part_num pn,
      table_mod_level m,
      table_bus_org bo
    WHERE 1                  =1
    AND pn.part_number       = p_part_num_pin
    AND m.part_info2part_num = pn.objid
    AND bo.objid             = pn.part_num2bus_org;
  pin_part_num_rec pin_part_num_curs%rowtype;
  CURSOR esn_curs
  IS
    SELECT pi_esn.part_serial_no esn,
      pi_esn.objid pi_esn_objid,
      pi_esn.part_inst2inv_bin, -- this need to change to the rtr machine dealer
      ib.bin_name site_id,
      sp.x_expire_dt
    FROM table_site_part sp,
      table_part_inst pi_esn,
      table_inv_bin ib
    WHERE 1                   =1
    AND sp.x_service_id       = p_esn
    AND sp.part_status        = 'Active'
    AND pi_esn.part_serial_no = sp.x_service_id
    AND ib.objid              = pi_esn.part_inst2inv_bin;
  esn_rec esn_curs%rowtype;
  CURSOR pin_curs(c_next_value IN NUMBER)
  IS
    SELECT * FROM table_x_cc_red_inv WHERE x_reserved_id = c_next_value;
  pin_rec pin_curs%rowtype;
  CURSOR user_curs
  IS
    SELECT objid,1 col2 FROM table_user WHERE s_login_name = USER
  UNION
  SELECT objid,2 col2 FROM table_user WHERE s_login_name = 'SA' ORDER BY col2;
  user_rec user_curs%rowtype;
  CURSOR dealer_curs
  IS
    SELECT s.site_id,
      ib.objid ib_objid
    FROM sa.table_inv_bin ib,
      sa.table_site s
    WHERE 1         =1
    AND IB.BIN_NAME = S.SITE_ID
    AND S.S_NAME    = 'MONEYGRAM PAYMENT SYSTEMS, INC'; --05152013
  -- and S.S_NAME like 'MONEYGRAM%';
  -- AND S.SITE_ID = '35347'; --dealer moneygram
  DEALER_REC DEALER_CURS%ROWTYPE;
BEGIN
  P_ERROR_CODE := 0;
  L_STEP       := '1';
  p_x_smp      := ' ';
  OPEN queue_card_days_curs;
  FETCH queue_card_days_curs INTO queue_card_days_rec;
  IF queue_card_days_curs%notfound THEN
    queue_card_days_rec.queued_days := 0;
  END IF;
  CLOSE queue_card_days_curs;
  OPEN dealer_curs;
  FETCH dealer_curs INTO dealer_rec;
  IF dealer_curs%notfound THEN
    CLOSE dealer_curs;
    p_error_code    := 1;
    p_error_message := 'INVALID DEALER';
    RETURN;
  END IF;
  CLOSE dealer_curs;
  OPEN user_curs;
  FETCH user_curs INTO user_rec;
  CLOSE user_curs;
  OPEN esn_curs;
  FETCH esn_curs INTO esn_rec;
  CLOSE esn_curs;
  OPEN pin_part_num_curs;
  FETCH pin_part_num_curs INTO pin_part_num_rec;
  CLOSE pin_part_num_curs;
  l_future_date := esn_rec.x_expire_dt +pin_part_num_rec.x_redeem_days + queue_card_days_rec.queued_days;
  sa.NEXT_ID( P_SEQ_NAME, O_NEXT_VALUE, O_FORMAT);
  DBMS_OUTPUT.PUT_LINE('O_NEXT_VALUE = ' || O_NEXT_VALUE);
  DBMS_OUTPUT.PUT_LINE('O_FORMAT = ' || O_FORMAT);
  --SP_RESERVE_APP_CARD( O_NEXT_VALUE, P_TOTAL, P_DOMAIN, P_STATUS, P_MSG);
  SP_RESERVE_APP_CARD( p_reserve_id => O_NEXT_VALUE, p_total =>P_TOTAL, p_domain =>P_DOMAIN, p_status =>P_STATUS, p_msg =>P_MSG); --CR422260
  DBMS_OUTPUT.PUT_LINE('P_STATUS = ' || P_STATUS);
  DBMS_OUTPUT.PUT_LINE('P_MSG = ' || P_MSG);
  IF p_msg          != 'Completed' THEN
    p_error_code    := 4;
    p_error_message := 'SP_RESERVE_APP_CARD'||':'||p_status||':'||p_msg;
    RETURN;
  END IF;
  OPEN pin_curs(o_next_value);
  FETCH pin_curs INTO pin_rec;
  IF pin_curs%notfound THEN
    p_error_code    := 5;
    p_error_message := 'PIN CODE NOT FOUND';
    CLOSE pin_curs;
    RETURN;
  END IF;
  CLOSE pin_curs;
  INSERT
  INTO table_part_inst
    (
      objid,
      last_pi_date,
      last_cycle_ct,
      next_cycle_ct,
      last_mod_time,
      last_trans_time,
      date_in_serv,
      repair_date,
      warr_end_date,
      x_cool_end_date,
      part_status,
      hdr_ind,
      x_sequence,
      x_insert_date,
      x_creation_date,
      x_domain,
      x_deactivation_flag,
      x_reactivation_flag,
      x_red_code,
      part_serial_no,
      x_part_inst_status,
      part_inst2inv_bin,
      created_by2user,
      status2x_code_table,
      n_part_inst2part_mod,
      part_to_esn2part_inst,
      x_ext
    )
    VALUES
    (
      (
        seq('part_inst')
      )
      ,
      sysdate,
      TO_DATE('01/01/1753 00:00:00', 'mm/dd/yyyy hh24:mi:ss') ,
      TO_DATE('01/01/1753 00:00:00', 'mm/dd/yyyy hh24:mi:ss') ,
      sysdate,
      sysdate,
      TO_DATE('01/01/1753 00:00:00', 'mm/dd/yyyy hh24:mi:ss') ,
      TO_DATE('01/01/1753 00:00:00', 'mm/dd/yyyy hh24:mi:ss') ,
      TO_DATE('01/01/1753 00:00:00', 'mm/dd/yyyy hh24:mi:ss') ,
      TO_DATE('01/01/1753 00:00:00', 'mm/dd/yyyy hh24:mi:ss'),
      'Active',
      0,
      0,
      SYSDATE,
      SYSDATE,
      'REDEMPTION CARDS',
      0,
      0,
      pin_rec.x_red_card_number,
      pin_rec.X_SMP,
      '400',
      dealer_rec.ib_objid,
      user_rec.objid,
      (SELECT objid
      FROM table_x_code_table
      WHERE x_code_number = '400'
      ) ,
      pin_part_num_rec.mod_level_objid,
      esn_rec.pi_esn_objid,
      NVL(
      (SELECT MAX(TO_NUMBER(x_ext) + 1)
      FROM table_part_inst
      WHERE part_to_esn2part_inst = esn_rec.pi_esn_objid
      AND x_domain                = 'REDEMPTION CARDS'
      ) ,1)
    ) ;
  sa.convert_bo_to_sql_pkg.sp_create_call_trans(esn_rec.esn --ip_esn
  ,'401'                                                    --ip_action_type
  ,NVL(p_sourcesystem ,'WEB')                               --IP_SOURCESYSTEM
  ,pin_part_num_rec.org_id                                  --IP_BRAND_NAME,
  ,pin_rec.x_red_card_number                                --ip_reason
  ,'Completed'                                              --IP_RESULT
  ,NULL                                                     --ip_ota_req_type,
  ,'402'                                                    --IP_OTA_TYPE, -- CR15847 PM ST Steaking
  ,0                                                        --ip_total_units
  ,op_call_trans_objid ,p_err_code ,p_err_msg);
  UPDATE table_x_call_trans
  SET x_new_due_date = l_future_date
  WHERE OBJID        = OP_CALL_TRANS_OBJID;
  p_x_smp           := pin_rec.X_SMP;
  COMMIT;
EXCEPTION
WHEN OTHERS THEN
  ROLLBACK;
  p_error_code    := 9;
  P_ERROR_MESSAGE := SQLERRM;
  L_STEP          := L_STEP||':'||SQLCODE||':'||SQLERRM;
  INSERT
  INTO ERROR_TABLE
    (
      ERROR_TEXT,
      ERROR_DATE ,
      ACTION,
      KEY,
      PROGRAM_NAME
    )
    VALUES
    (
      L_STEP,
      SYSDATE,
      'REFILL_BB',
      P_ESN,
      'REFILL_BB'
    );
END REFILL_BB;
PROCEDURE BB_RECURRING
  (
    P_ESN          IN VARCHAR2,
    P_PROGRAM_NAME IN VARCHAR2,
    P_ERROR_CODE OUT NUMBER,
    P_ERROR_MSG OUT VARCHAR2
  )
IS
  -- Ramu
  l_purch_hdr_seq     NUMBER;
  l_purch_hdr_dtl_seq NUMBER;
  L_STEP              VARCHAR2(100);
  CURSOR ENROLL_PROGRAM_CURS
  IS
    SELECT PE.OBJID,
      PE.X_ESN,
      sa.SP_METADATA.GETPRICE(PN.PART_NUMBER,'BILLING') AMOUNT,
      pe.pgm_enroll2web_user web_user_objid,
      pe.x_charge_date --yrielis
    FROM X_PROGRAM_ENROLLED PE,
      X_PROGRAM_PARAMETERS PP,
      TABLE_SITE_PART SP,
      table_part_num pn
    WHERE PE.X_ESN = P_ESN
    AND PP.X_PROGRAM_NAME
      ||''                          = P_PROGRAM_NAME
    AND PE.X_ESN                    = SP.X_SERVICE_ID
    AND PE.PGM_ENROLL2PGM_PARAMETER = PP.OBJID
    AND PROG_PARAM2PRTNUM_MONFEE    = PN.OBJID
    AND PE.X_ENROLLMENT_STATUS      = 'ENROLLED'
    AND SP.PART_STATUS
      ||'' = 'Active'
    AND PP.X_PROGRAM_NAME LIKE 'Lifeline%BB%';
  ENROLL_PROGRAM_REC ENROLL_PROGRAM_CURS%rowtype;
BEGIN
  P_ERROR_CODE :=0;
  L_STEP       := '1';
  OPEN ENROLL_PROGRAM_CURS;
  FETCH ENROLL_PROGRAM_CURS INTO enroll_program_rec;
  IF ENROLL_PROGRAM_CURS%NOTFOUND THEN
    P_ERROR_CODE                                   := 1;
    P_ERROR_MSG                                    := 'ESN is not Enrolled into BB Program';
  ELSIF TRUNC(ENROLL_PROGRAM_REC.x_charge_date,'MM')=TRUNC(SYSDATE,'MM') THEN
    P_ERROR_CODE                                   := 2;
    P_ERROR_MSG                                    := 'Already charged this month';
  ELSE
    -- Ramu: Insert into all Billing tables
    l_purch_hdr_seq     := sa.billing_seq ('X_PROGRAM_PURCH_HDR');
    l_purch_hdr_dtl_seq := sa.billing_seq ('X_PROGRAM_PURCH_DTL');
    -- Ramu: Pending - Update program enrolled
    UPDATE x_program_enrolled
    SET x_delivery_cycle_number = NVL (x_delivery_cycle_number, 0) + 1,
      x_charge_date             = TRUNC (SYSDATE),
      x_next_delivery_date      = NULL
    WHERE objid                 = enroll_program_rec.OBJID;
    -- Ramu: Insert into Program Purch Hdr
    INSERT
    INTO x_program_purch_hdr
      (
        objid,
        x_rqst_source,
        x_rqst_type,
        x_rqst_date,
        x_merchant_ref_number,
        x_ignore_avs,
        x_ics_rcode,
        x_ics_rflag,
        x_ics_rmsg,
        x_auth_rcode,
        x_auth_rflag,
        x_auth_rmsg,
        x_bill_rcode,
        x_bill_rflag,
        x_bill_rmsg,
        x_customer_email,
        x_status,
        x_bill_country,
        x_amount,
        x_tax_amount,
        x_e911_tax_amount,
        x_user,
        prog_hdr2web_user,
        x_payment_type
      )
      VALUES
      (
        l_purch_hdr_seq,
        'VMBC',
        'LIFELINE_PURCH',
        SYSDATE,
        'BPSAFELINK',
        'YES',
        '1',
        'SOK',
        'Request was processed successfully.',
        '1',
        'SOK',
        'Request was processed successfully.',
        '1',
        'SOK',
        'Request was processed successfully.',
        'NULL@CYBERSOURCE.COM',
        'LIFELINEPROCESSED',
        'USA',
        ENROLL_PROGRAM_REC.amount,
        0,
        0,
        'SYSTEM', --yrielis
        ENROLL_PROGRAM_REC.web_user_objid,
        'LL_RECURRING'
      );
    -- Ramu: Insert into Program Purch Dtl
    INSERT
    INTO x_program_purch_dtl
      (
        objid,
        x_esn,
        x_amount,
        x_tax_amount,
        x_e911_tax_amount,
        x_charge_desc,
        x_cycle_start_date,
        x_cycle_end_date,
        pgm_purch_dtl2pgm_enrolled,
        pgm_purch_dtl2prog_hdr
      )
      VALUES
      (
        L_PURCH_HDR_DTL_SEQ,
        ENROLL_PROGRAM_REC.X_ESN,
        ENROLL_PROGRAM_REC.amount,
        0,
        0,
        'Monthly Payment Received',
        TRUNC (SYSDATE),
        TRUNC (SYSDATE) + 30,
        enroll_program_rec.OBJID,
        L_PURCH_HDR_SEQ
      );
    COMMIT;
  END IF;
  CLOSE ENROLL_PROGRAM_CURS;
EXCEPTION
WHEN OTHERS THEN
  P_ERROR_CODE :=93;
  P_ERROR_MSG  := 'when others errors bb_recurring';
  L_STEP       := L_STEP||':'||SQLCODE||':'||SQLERRM;
  INSERT
  INTO ERROR_TABLE
    (
      ERROR_TEXT,
      ERROR_DATE ,
      ACTION,
      KEY,
      PROGRAM_NAME
    )
    VALUES
    (
      L_STEP,
      SYSDATE,
      'BB_RECURRING',
      P_ESN,
      'BB_RECURRING'
    );
END BB_RECURRING;
PROCEDURE sp_get_pin_info
  (
    ip_tf_mg_ref IN VARCHAR2,
    ip_min       IN VARCHAR2,
    op_red_pin OUT NUMBER,
    op_zip OUT VARCHAR2,
    op_esn OUT VARCHAR2,
    op_iccid OUT VARCHAR2,
    op_contact_objid OUT NUMBER,
    op_err_num OUT NUMBER,
    op_err_msg OUT VARCHAR2
  )
AS
  CURSOR mg_trans_cur
  IS
    SELECT *
    FROM sa.X_MG_TRANSACTIONS
    WHERE X_TF_REFERENCE_NUMBER = ip_tf_mg_ref
    AND X_MIN                   = ip_min
    AND X_STATUS                = 'PASS';
  mg_trans_rec mg_trans_cur%ROWTYPE;
  -- customer type
  rs sa.customer_type;
  s sa.customer_type;
  cst sa.red_card_type := sa.red_card_type();
 --CR47024 Changes
  v_src_sp_grp   x_serviceplanfeaturevalue_def.value_name%TYPE;
  l_part_number  table_part_num.part_number%type;
  v_dest_sp_grp  x_serviceplanfeaturevalue_def.value_name%TYPE;
BEGIN
  IF ip_tf_mg_ref IS NULL OR ip_min IS NULL THEN
    op_err_num    := 1;
    op_err_msg    := 'TF REFERENCE NUMBER/MIN ARE MANADATORY';
    RETURN;
  END IF;
  OPEN mg_trans_cur;
  FETCH mg_trans_cur INTO mg_trans_rec;
  IF mg_trans_cur%FOUND THEN
    -- instantiate the customer_type with the esn
    rs := customer_type ( i_esn => mg_trans_rec.x_esn);
    -- calling the customer type retrieve method
    s := rs.retrieve;
    IF s.response NOT LIKE '%SUCCESS%' THEN
      op_err_num := 1;
      op_err_msg := s.response;
      RETURN;
    END IF;
    IF s.bus_org_id <> 'TRACFONE' THEN
      op_err_num    := 1;
      op_err_msg    := 'THE BRAND IS NOT IN TRACFONE';
      RETURN;
    END IF;
    -- Make sure the ESN is active
    IF s.esn_part_inst_status <> '52' THEN
      op_err_num              := 1;
      op_err_msg              := 'ESN is not Active';
      RETURN;
    END IF;
  --CR47024 Changes
   DBMS_OUTPUT.PUT_LINE('mg_trans_rec.x_paycode'||mg_trans_rec.x_paycode);

	select distinct x_part_number
	  into l_part_number
	  from X_MONEYGRAM_LOOKUP
	where x_paycode =mg_trans_rec.x_paycode;

    DBMS_OUTPUT.PUT_LINE('l_part_number'||l_part_number);

	p_get_source_dest_sp_group(mg_trans_rec.x_esn,l_part_number,v_src_sp_grp,	v_dest_sp_grp,op_err_num,op_err_msg);

	DBMS_OUTPUT.PUT_LINE('v_src_sp_grp'||v_src_sp_grp);
	DBMS_OUTPUT.PUT_LINE('v_dest_sp_grp'||v_dest_sp_grp);
	DBMS_OUTPUT.PUT_LINE('op_err_num'||op_err_num);

  IF op_err_num <> 0 THEN
    op_err_num := 1;
    op_err_msg := 'Error in Getting Service Plan Group';
    RETURN;
  END IF;

    op_zip           := s.zipcode;
    op_esn           := s.esn;
    op_iccid         := s.iccid;
    op_red_pin       := cst.convert_smp_to_pin (i_smp => mg_trans_rec.x_smp);
    op_contact_objid := s.contact_objid;

   --CR47024 Changes
    IF v_src_sp_grp = 'TFSL_UNLIMITED' AND v_dest_sp_grp = 'TFSL_UNLIMITED' THEN
		op_red_pin       := NULL;   -- NULL out the Soft PIN  -  leads to PIN in queue in benefits delivery.
	END IF;

	DBMS_OUTPUT.PUT_LINE('op_red_pin'||op_red_pin);

  	op_err_num       := 0;
    op_err_msg       := 'SUCCESS';
  ELSE
    op_err_num := 1;
    op_err_msg := 'FAILED';
    CLOSE mg_trans_cur;
    RETURN;
  END IF;
  CLOSE mg_trans_cur;
EXCEPTION
WHEN OTHERS THEN
  op_Err_Num := 1;
  op_err_Msg := 'UNHANDLED EXCEPTION: ' || SQLERRM;
END sp_get_pin_info;
END broadband_service_pkg;
/