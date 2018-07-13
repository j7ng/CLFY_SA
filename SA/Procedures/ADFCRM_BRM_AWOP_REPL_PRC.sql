CREATE OR REPLACE PROCEDURE sa."ADFCRM_BRM_AWOP_REPL_PRC"
(
  IP_LOGIN_NAME IN VARCHAR2
, IP_ESN IN VARCHAR2
, IP_WEB_USER_OBJID IN VARCHAR2
, IP_CONTACT_OBJID IN VARCHAR2
, IP_SP_ID IN VARCHAR2
, IP_TYPE IN VARCHAR2  -- AWOP,REPLACEMENT
, IP_REASON IN VARCHAR2
, IP_REF_ESN IN VARCHAR2
, IP_REF_PIN IN VARCHAR2
, IP_NOTES IN VARCHAR2
, IP_SERVICE_DAYS IN VARCHAR2
, IP_DATA_GB IN VARCHAR2
, OP_RED_CARD OUT VARCHAR2
, OP_ERROR_NO OUT VARCHAR2
, OP_ERROR_MSG OUT VARCHAR2
) AS


  -- THIS IS SPECIFICALLY FOR UNITS / COMPENSATION SERVICE PLAN CASES.
  -- FOR WORKFORCE TO GENERATE PINS
  -- USER INFO
  v_user_objid NUMBER;

  -- OUT INFO
  v_case_objid         NUMBER;
  v_case_id            varchar2(30);
  v_case_detail        varchar2(4000);
  v_error_no           VARCHAR2(200);
  v_error_str          VARCHAR2(200);
  v_pin_part_serial_no VARCHAR2(30);
  v_esn_objid          NUMBER;
  v_hist_ret           BOOLEAN;
  v_activity           VARCHAR2(500);
  p_seq_name           VARCHAR2(30):='x_merch_ref_id';
  o_next_value         NUMBER;
  o_format             VARCHAR2(100);
  p_status             VARCHAR2(10);
  p_msg                VARCHAR2(200);
  v_new_pi_objid       NUMBER;
  v_esn                VARCHAR2(30);
  v_card_status        varchar2(10);
  v_repl_part_number   varchar2(30);
  v_case_details       VARCHAR2(1000);

  CURSOR ESN_cur
  IS
    SELECT objid,
      part_serial_no,
      x_part_inst2contact
    FROM table_part_inst
    WHERE part_serial_no = ip_esn
    AND x_domain         = 'PHONES';
  esn_rec esn_cur%rowtype;

  CURSOR CONTACT_cur
  IS
    SELECT objid
    FROM table_contact
    WHERE objid = ip_contact_objid;

  CONTACT_rec CONTACT_cur%rowtype;

  CURSOR Mod_Cur(v_part_number IN VARCHAR2)
  IS
    SELECT m2.objid
    FROM table_mod_level m2,
      table_part_num pn2
    WHERE 1                   =1
    AND pn2.part_number       = v_part_number
    AND m2.part_info2part_num = pn2.objid
    ORDER BY m2.eff_date DESC;
  mod_rec mod_cur%rowtype;
  CURSOR CC_INV_CUR (res_id VARCHAR2)
  IS
    SELECT x_red_card_number,
      X_SMP
    FROM Table_X_CC_Red_Inv
    WHERE x_reserved_id = res_id ;
  CC_INV_REC CC_INV_CUR%rowtype;
  CURSOR INV_BIN_CUR
  IS
    SELECT table_inv_bin.objid
    FROM table_inv_bin,
      table_inv_role,
      table_inv_locatn,
      table_site
    WHERE table_inv_role.inv_role2site     = table_site.objid
    AND table_inv_role.inv_role2inv_locatn = table_inv_locatn.objid
    AND table_inv_bin.inv_bin2inv_locatn   = table_inv_locatn.objid
    AND table_site.site_id                 = '7882';
  INV_BIN_REC INV_BIN_CUR%rowtype;
  CURSOR code_CUR (p_code varchar2)
  IS
    SELECT objid FROM table_x_code_table WHERE x_code_number = p_code;
  code_REC code_CUR%rowtype;

BEGIN
  OP_RED_CARD  := NULL;
  OP_ERROR_NO := '0';
  OP_ERROR_MSG := 'SUCCESS';

  --
  --get part number for replacement pin
  --
  v_repl_part_number:= get_serv_plan_value(IP_SP_ID,'REPLACEMENT_PART_NUMBER');

  if v_repl_part_number is null then
    op_error_msg := 'ERROR - Repl Part Number not found for Service Plan: '||IP_SP_ID;
    OP_ERROR_NO := '25';
    return;
  end if;

  -- GET THE RESERVED PIN FOR THE ESN REQUESTED --------------------------------
  -- IF YES RETURN PIN, NO CASE REQUIRED

  BEGIN
    SELECT pin.x_red_code
    INTO OP_RED_CARD
    FROM table_part_inst pin,
      table_part_inst esn,
      table_part_num pn_pin,
      table_mod_level ml_pin
    WHERE 1                       =1
    AND pin.x_part_inst_status    = '40' -- RESERVED
    AND pin.part_to_esn2part_inst = esn.objid
    AND ml_pin.part_info2part_num = pn_pin.objid
    AND pin.n_part_inst2part_mod  = ml_pin.objid
    AND esn.part_serial_no        = IP_ESN
    AND pn_pin.part_number        = v_repl_part_number
    AND rownum                    <2;
    RETURN;
  EXCEPTION
  WHEN OTHERS THEN
    dbms_output.put_line('NO PIN RESERVED UNDER '||v_repl_part_number);
  END;
  -- NO PIN RESERVED - CONTINUE ------------------------------------------------
  -- COLLECT ESN OBJID
  v_activity := 'OBTAINING ESN INFO';


IF ip_esn IS NOT NULL THEN
  OPEN esn_cur;
  FETCH esn_cur INTO esn_rec;
  IF esn_cur%notfound THEN
    CLOSE esn_cur;
    OP_ERROR_NO := '50';
    op_error_msg := 'ERROR - Serial Number not found: '||TO_CHAR(ip_esn);
    RETURN;
    v_esn        := null;
    v_card_status:='42';
  ELSE
    CLOSE esn_cur;
    v_esn        := ip_esn;
    v_card_status:='40';
  END IF;

ELSE
  v_card_status:='42';
  v_esn := null;
END IF;

IF ip_contact_objid IS NOT NULL THEN
    OPEN contact_cur;
    FETCH contact_cur INTO contact_rec;
    IF contact_cur%notfound THEN
      CLOSE contact_cur;
      OP_ERROR_NO := '115';
      op_error_msg := 'ERROR - Contact not found: '||TO_CHAR(ip_contact_objid);
      RETURN;
    END IF;
    CLOSE contact_cur;
ELSE
   OP_ERROR_NO := '115';
   op_error_msg := 'ERROR - Contact not found';
   RETURN;
END IF;


    v_activity := 'GETTING PART NUMBER MOD LEVEL';
  OPEN mod_cur(v_repl_part_number);
  FETCH mod_cur INTO mod_rec;
  IF mod_cur%notfound THEN
    CLOSE mod_cur;
    OP_ERROR_NO := '110';
    op_error_msg := 'ERROR - mod level not found: '||v_repl_part_number;
    RETURN;
  END IF;
  CLOSE mod_cur;
    v_activity := 'GETTING INVENTORY BIN';
  OPEN inv_bin_cur;
  FETCH inv_bin_cur INTO inv_bin_rec;
  IF inv_bin_cur%notfound THEN
    CLOSE inv_bin_cur;
    OP_ERROR_NO := '120';
    op_error_msg := 'ERROR - inv_bin value not found. ';
    RETURN;
  END IF;
  CLOSE inv_bin_cur;
    v_activity := 'GETTING REVERVED CODE OBJID';
  OPEN code_cur (v_card_status);
  FETCH code_cur INTO code_rec;
  IF code_cur%notfound THEN
    CLOSE code_cur;
    OP_ERROR_NO := '130';
    op_error_msg := 'ERROR - code_table value not found.';
    RETURN;
  END IF;
  CLOSE code_cur;
  v_activity := 'OBTAINING PIN INFO';
  sa.NEXT_ID( P_SEQ_NAME => P_SEQ_NAME, O_NEXT_VALUE => O_NEXT_VALUE, O_FORMAT => O_FORMAT );
  sa.sp_reserve_app_card ( p_reserve_id => O_NEXT_VALUE, p_total => 1, p_domain => NULL, p_status => p_status, p_msg => p_msg);
  OPEN cc_inv_cur (O_NEXT_VALUE);
  FETCH cc_inv_cur INTO cc_inv_rec;
  IF cc_inv_cur%notfound THEN
    CLOSE cc_inv_cur;
    OP_ERROR_NO := '140';
    op_error_msg := 'ERROR - pin inventory depleted';
    RETURN;
  END IF;
  CLOSE cc_inv_cur;
  -- GET THE USER OBJID
  v_activity := 'GETTING USER OBJID';
  SELECT objid
  INTO v_user_objid
  FROM table_user
  WHERE s_login_name = upper(ip_login_name);
  SELECT sa.seq('part_inst') INTO v_new_pi_objid FROM dual;
  /* insert into table_part_inst */
    v_activity := 'INSERTING RED CARD PART_INST';
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
      part_to_esn2part_inst
    )
    VALUES
    (
      v_new_pi_objid,
      TO_DATE('01/01/1753 00:00:00', 'mm/dd/yyyy hh24:mi:ss'),
      TO_DATE('01/01/1753 00:00:00', 'mm/dd/yyyy hh24:mi:ss') ,
      TO_DATE('01/01/1753 00:00:00', 'mm/dd/yyyy hh24:mi:ss') ,
      TO_DATE('01/01/1753 00:00:00', 'mm/dd/yyyy hh24:mi:ss'),
      TO_DATE('01/01/1753 00:00:00', 'mm/dd/yyyy hh24:mi:ss') ,
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
      cc_inv_rec.x_red_card_number,
      cc_inv_rec.X_SMP,
      v_card_status,
      inv_bin_rec.objid,
      v_user_objid,
      code_rec.objid,
      mod_rec.objid,
      decode(ip_esn,'BYOP',null,esn_rec.objid)
    ) ;

  OP_RED_CARD := cc_inv_rec.x_red_card_number;
  -- UPDATE RED CARD PI HIST ---------------------------------------------------
  v_activity := 'INSERTING HISTORY';
  v_hist_ret := toss_util_pkg.insert_pi_hist_fun (ip_part_serial_no => v_pin_part_serial_no, ip_domain => NULL, -- DEAD PARAM
  ip_action => 'WORKFORCE PIN', ip_prog_caller => NULL                                                          -- DEAD PARAM
  );
  -- CREATE AND CLOSE UNITS CASE
  -- CREATE THE CASE
  v_activity := 'CREATING CASE';
   v_case_details:='DATA_UNITS||'||IP_DATA_GB||
  '||SERVICE_DAYS||'||IP_SERVICE_DAYS||
  '||SERVICE_PLAN||'||IP_SP_ID||
  '||REFERENCE_ESN||'||IP_REF_ESN||
  '||REFERENCE_PIN||'||IP_REF_PIN||
  '||SUPER_LOGIN||'||ip_login_name;

  sa.CLARIFY_CASE_PKG.CREATE_CASE(
                P_TITLE => 'Replacement Service Plan',
                P_CASE_TYPE => 'Units',
                P_STATUS => 'Solving',
                P_PRIORITY => 'High',
                P_ISSUE => ip_reason,
                P_SOURCE => 'TAS',
                P_POINT_CONTACT => NULL,
                P_CREATION_TIME => sysdate,
                P_TASK_OBJID => NULL,
                P_CONTACT_OBJID => nvl(contact_rec.objid,esn_rec.x_part_inst2contact),
                P_USER_OBJID => v_user_objid,
                P_ESN => v_esn,
                P_PHONE_NUM => NULL,
                P_FIRST_NAME => NULL,
                P_LAST_NAME => NULL,
                P_E_MAIL => null,
                P_DELIVERY_TYPE => null,
                P_ADDRESS => NULL,
                P_CITY => NULL,
                P_STATE => NULL,
                P_ZIPCODE => NULL,
                P_REPL_UNITS => null,
                P_FRAUD_OBJID => null,
                P_CASE_DETAIL => v_case_details,
                P_PART_REQUEST => NULL,
                P_ID_NUMBER => v_case_id,
                P_CASE_OBJID => v_case_objid,
                P_ERROR_NO => v_error_no,
                P_ERROR_STR => v_error_str
              );

--  clarify_case_pkg.create_case (p_title => 'Compensation Service Plan', p_case_type => 'Units', p_status => 'Solving', p_priority => 'High', p_issue => ip_reason, p_source => 'TAS', p_point_contact => NULL, p_creation_time => sysdate, p_task_objid => NULL, p_contact_objid => v_contact_objid, p_user_objid => v_user_objid, p_esn => ip_esn, p_phone_num => NULL, p_first_name => NULL, p_last_name => NULL, p_e_mail => NULL, p_delivery_type => NULL, p_address => NULL, p_city => NULL, p_state => NULL, p_zipcode => NULL, p_repl_units => NULL, p_fraud_objid => NULL, p_case_detail => NULL, p_part_request => NULL, p_id_number => v_case_id, p_case_objid => v_case_objid, p_error_no => v_error_no, p_error_str => v_error_str);
  dbms_output.put_line('OP_RED_CARD = ' || OP_RED_CARD);
  dbms_output.put_line('P_ID_NUMBER = ' || v_case_id);
  dbms_output.put_line('P_CASE_OBJID = ' || v_case_objid);
  dbms_output.put_line('P_ERROR_NO = ' || v_error_no);
  dbms_output.put_line('P_ERROR_STR = ' || v_error_str);

  -- ADD NOTES TO CASE -------------------------------------------------------
  v_activity := 'LOGGING NOTES';
  clarify_case_pkg.log_notes (p_case_objid => v_case_objid, p_user_objid => v_user_objid, p_notes => ip_notes||CHR(10)||' GENERATED AWOP/REPL PN: '||v_repl_part_number, p_action_type => NULL, p_error_no => v_error_no, p_error_str => v_error_str);
  -- CLOSE THE CASE ----------------------------------------------------------
  v_activity := 'CLOSING CASE';
  clarify_case_pkg.close_case(p_case_objid => v_case_objid, p_user_objid => v_user_objid, p_source => 'TAS', p_resolution => 'Closed', p_status => 'Closed', p_error_no => v_error_no, p_error_str => v_error_str);
  dbms_output.put_line('P_ERROR_NO = ' || v_error_no);
  dbms_output.put_line('P_ERROR_STR = ' || v_error_str);
EXCEPTION
WHEN OTHERS THEN
  op_error_msg := 'ERROR - '||v_activity;
  OP_ERROR_NO := '200';

END ADFCRM_BRM_AWOP_REPL_PRC;
/