CREATE OR REPLACE PACKAGE BODY sa.ACTIVE_SAFELINK_REPL_PHONES
AS
PROCEDURE SP_active_safelink_phones(
    P_case_id IN VARCHAR2 ,
    P_OLD_ESN IN VARCHAR2,
    P_NEW_ESN IN VARCHAR2,
    P_REPL_UNITS OUT VARCHAR2,
    P_REQUEST_PLAN OUT VARCHAR2,
    P_LID OUT VARCHAR2,
    P_CONT_PART_INST OUT VARCHAR2,
    P_MIN OUT VARCHAR2,
    P_ACTIVE_ESN OUT VARCHAR2,
    p_active_esn_status OUT VARCHAR2,
    P_LOGIN_NAME OUT VARCHAR2,
    P_WEB_USER_ID OUT VARCHAR2,
    P_STATE OUT VARCHAR2,
    P_FLAG OUT VARCHAR2,
    P_OBJID OUT VARCHAR2,
    p_carrier_flag OUT VARCHAR2,
    P_ERROR_NO OUT VARCHAR2,
    P_ERROR_STR OUT VARCHAR2 )
AS
  CURSOR NEW_PART_INST_C(P_NEW_ESN VARCHAR2)
  IS
    SELECT PI.* ,
      TABLE_PART_NUM.X_TECHNOLOGY
    FROM TABLE_PART_INST PI ,
      TABLE_MOD_LEVEL ,
      TABLE_PART_NUM
    WHERE PART_SERIAL_NO     = P_NEW_ESN
    AND N_PART_INST2PART_MOD = TABLE_MOD_LEVEL.OBJID
    AND PART_INFO2PART_NUM   = TABLE_PART_NUM.OBJID;
  REC_NEW_PART_INST_C NEW_PART_INST_C%ROWTYPE;
  CURSOR get_exp_dt(p_old_esn VARCHAR2)
  IS
    SELECT x_expire_dt
    FROM
      (SELECT X_EXPIRE_DT,
        dense_rank() over(partition BY x_service_id order by DECODE(part_status,'Active',1,'Inactive',2,3), install_date DESC, objid DESC) x_rank
      FROM table_site_part
      WHERE X_SERVICE_ID =p_old_esn
      )
  WHERE x_rank = 1;
  rec_get_exp_dt get_exp_dt%ROWTYPE;
  CURSOR get_objid(request_plan VARCHAR2)
  IS
    SELECT objid FROM x_program_parameters WHERE x_program_name=request_plan;
  rec_get_objid get_objid%ROWTYPE;
  CURSOR Get_esn_details(P_case_id VARCHAR2,p_old_esn VARCHAR2)
  IS
    SELECT tc.X_ESN,
      tc.ID_NUMBER,
      --tc.X_REPLACEMENT_UNITS, --CR39512
       case when (tc.X_REPLACEMENT_UNITS = 0
              or tc.X_REPLACEMENT_UNITS is null) then
               NVL((select x_value from
                table_x_case_detail t1
                where t1.Detail2case=tc.objid
                and x_name='UNITS_TO_TRANSFER'),0)
              else
              to_char(tc.X_REPLACEMENT_UNITS)
              end X_REPLACEMENT_UNITS,
           sls.X_REQUESTED_PLAN,
      sls.LID ,
      WU.WEB_USER2CONTACT X_CONTACT_PART_INST2CONTACT,
      tc.X_MIN,
      DECODE(phone.X_PART_INST_STATUS,'52','ACTIVE','INACTIVE') old_Esn_status,
      phone.X_PART_INST_STATUS,
      wu.LOGIN_NAME,
      wu.OBJID web_user_objid,
      sls.STATE
    FROM table_case tc,
      x_sl_currentvals cv,
      x_sl_subs sls,
      table_Part_inst phone,
      table_web_user wu
    WHERE cv.X_CURRENT_ESN   = tc.X_ESN
    AND phone.PART_SERIAL_NO = cv.X_CURRENT_ESN
    AND sls.LID              = cv.LID
      -- AND tc.CASE_TYPE_LVL2                 = 'SAFELINK'
    AND SLS.SL_SUBS2WEB_USER = WU.OBJID
    AND tc.id_number         = P_case_id
    AND tc.x_esn             = p_old_esn;
  REC_Get_esn_details Get_esn_details%ROWTYPE;
  CURSOR Get_ship_esn_details(p_ship_esn VARCHAR2)
  IS
    SELECT sls.X_REQUESTED_PLAN,
      sls.LID ,
      WU.WEB_USER2CONTACT X_CONTACT_PART_INST2CONTACT,
      phone.X_PART_INST_STATUS old_Esn_status,
      wu.LOGIN_NAME,
      wu.OBJID web_user_objid,
      sls.STATE
    FROM x_sl_currentvals cv,
      x_sl_subs sls,
      table_Part_inst phone,
      table_web_user wu
    WHERE phone.PART_SERIAL_NO = cv.X_CURRENT_ESN
    AND sls.LID                = cv.LID
    AND SLS.SL_SUBS2WEB_USER   = WU.OBJID
    AND phone.PART_SERIAL_NO   =P_SHIP_ESN;
  REC_Get_ship_esn_details Get_ship_esn_details%ROWTYPE;
  CURSOR SHIP_CHECK(P_case_id VARCHAR2)
  IS
    SELECT X_PART_SERIAL_NO,
      X_PART_INST_STATUS,
      SH_FLAG,
      X_REPLACEMENT_UNITS,
      x_min
    FROM
      (SELECT p.X_PART_SERIAL_NO,
        pi.X_PART_INST_STATUS,
        DECODE(pi.X_PART_INST_STATUS,'52','ACTIVE','INACTIVE') SH_FLAG,
       -- tc.X_REPLACEMENT_UNITS, --CR39512
        case when (tc.X_REPLACEMENT_UNITS = 0
              or tc.X_REPLACEMENT_UNITS is null) then
               NVL((select x_value from
                table_x_case_detail t1
                where t1.Detail2case=tc.objid
                and x_name='UNITS_TO_TRANSFER'),0)
              else
              to_char(tc.X_REPLACEMENT_UNITS)
              end  X_REPLACEMENT_UNITS,
        tc.x_min,
        DENSE_RANK() OVER(PARTITION BY TC.ID_NUMBER ORDER BY P.X_SHIP_DATE DESC, P.OBJID DESC) PR_RANK
      FROM table_x_part_request p,
        table_case tc,
        table_part_inst pi
      WHERE pi.PART_SERIAL_NO = p.X_PART_SERIAL_NO
      AND p.REQUEST2CASE      = tc.OBJID
      AND tc.id_number        = P_case_id
      )
  WHERE PR_RANK = 1;
  REC_SHIP_CHECK SHIP_CHECK%ROWTYPE;
  V_FLAG            VARCHAR2(200);
  V_OBJID           NUMBER;
  v_exp_date        DATE;
  v_old_esn_carrier NUMBER;
  v_new_esn_carrier NUMBER;
  v_carrier_flag    NUMBER        :=0;
  V_SHIP_FLAG       VARCHAR2(100) :=0;
  V_ERROR_NO number;
  V_ERROR_STR varchar2(100);
BEGIN
  dbms_output.put_line('inside the package');
  dbms_output.put_line('P_case_id'||P_case_id);
  dbms_output.put_line('P_OLD_ESN'||P_OLD_ESN);
  dbms_output.put_line('P_NEW_ESN'||P_NEW_ESN);
  P_ERROR_NO     := '0';
  P_ERROR_STR    := 'SUCCESS';
  p_carrier_flag := 'SAME';
  OPEN get_exp_dt(p_old_esn);
  FETCH get_exp_dt INTO rec_get_exp_dt;
  IF get_exp_dt%found THEN
    dbms_output.put_line('get_exp_dt Found');
    v_exp_date := rec_get_exp_dt.X_EXPIRE_DT;
  END IF;
  CLOSE get_exp_dt;
  -----------------------SHIPPED ESN CHECK------------------------
  OPEN SHIP_CHECK(P_case_id);
  FETCH SHIP_CHECK INTO REC_SHIP_CHECK;
  IF SHIP_CHECK%found THEN
    dbms_output.put_line('ship found');
    V_SHIP_FLAG := '1';
  END IF;
  CLOSE SHIP_CHECK;
  dbms_output.put_line('V_SHIP_FLAG'||V_SHIP_FLAG);
  OPEN Get_esn_details(P_case_id ,p_old_esn);
  FETCH Get_esn_details INTO REC_Get_esn_details;
  IF GET_ESN_DETAILS%NOTFOUND THEN
    dbms_output.put_line('GET_ESN_DETAILS not found ');
    IF V_SHIP_FLAG ='0' THEN
      P_ERROR_NO  := '1';
      P_ERROR_STR := 'CASE ESN NOT FOUND';
    END IF;
  END IF;
  CLOSE GET_ESN_DETAILS;
  -------------------------IF CASE ESN IS ACTIVE AND DUE DATE IS FUTURE THEN OLd ESN DETAILS---------------------------
  dbms_output.put_line('REC_Get_esn_details.old_Esn_status'||REC_Get_esn_details.old_Esn_status);
  dbms_output.put_line('v_exp_date'||TRUNC(v_exp_date));
  dbms_output.put_line('TRUNC(SYSDATE)'||TRUNC(SYSDATE));
  BEGIN
    SELECT DECODE(x_part_inst_status,'52','ACTIVE','INACTIVE')
    INTO V_FLAG
    FROM table_Part_inst
    WHERE PART_SERIAL_NO=P_OLD_ESN;
  EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('SQLERRM'||SQLERRM);
  END;
  dbms_output.put_line('V_FLAG'||V_FLAG);
  IF (V_FLAG ='ACTIVE' AND TRUNC(v_exp_date) > TRUNC(SYSDATE)) THEN
    dbms_output.put_line('1');
    OPEN get_objid(REC_Get_esn_details.X_REQUESTED_PLAN);
    FETCH get_objid INTO rec_get_objid;
    IF get_objid%found THEN
      P_OBJID := rec_get_objid.objid;
    END IF;
    CLOSE get_objid;
    dbms_output.put_line('P_OBJID'||P_OBJID);
    P_REPL_UNITS        :=REC_Get_esn_details.X_REPLACEMENT_UNITS;
    P_REQUEST_PLAN      :=REC_Get_esn_details.X_REQUESTED_PLAN;
    P_LID               :=REC_Get_esn_details.LID;
    P_CONT_PART_INST    :=REC_Get_esn_details.X_CONTACT_PART_INST2CONTACT;
    P_MIN               :=REC_Get_esn_details.X_MIN;
    P_ACTIVE_ESN        :=REC_Get_esn_details.X_ESN;
    p_active_esn_status := REC_Get_esn_details.X_PART_INST_STATUS;
    P_LOGIN_NAME        :=REC_Get_esn_details.LOGIN_NAME;
    P_WEB_USER_ID       :=REC_Get_esn_details.web_user_objid;
    P_STATE             :=REC_Get_esn_details.STATE;
    P_FLAG              :='ACTIVE';
    dbms_output.put_line('P_REPL_UNITS'||P_REPL_UNITS);
    dbms_output.put_line('P_REQUEST_PLAN'||P_REQUEST_PLAN);
    dbms_output.put_line('P_LID'||P_LID);
    dbms_output.put_line('P_CONT_PART_INST'||P_CONT_PART_INST);
    dbms_output.put_line('P_MIN'||P_MIN);
    dbms_output.put_line('P_ACTIVE_ESN'||P_ACTIVE_ESN);
    dbms_output.put_line('p_active_esn_status'||p_active_esn_status);
    dbms_output.put_line('P_LOGIN_NAME'||P_LOGIN_NAME);
    dbms_output.put_line('P_WEB_USER_ID'||P_WEB_USER_ID);
    dbms_output.put_line('P_STATE'||P_STATE);
    dbms_output.put_line('P_FLAG'||P_FLAG);
  END IF;
  dbms_output.put_line('outside 1');
    dbms_output.put_line('outside 1');
  IF V_SHIP_FLAG ='0' THEN-- OR REC_Get_esn_details.active_esn  IS NULL THEN
    IF (V_FLAG   ='ACTIVE' AND TRUNC(v_exp_date) < TRUNC(SYSDATE)) OR (V_FLAG ='INACTIVE' AND TRUNC(v_exp_date) < TRUNC(SYSDATE)) THEN
      dbms_output.put_line('2');
      p_flag :='INACTIVE';
      dbms_output.put_line('p_flag'||p_flag);
    END IF;
    IF (V_FLAG='INACTIVE' AND TRUNC(v_exp_date) > TRUNC(SYSDATE)) THEN
      dbms_output.put_line('3');
      p_flag :='ACTIVE';
      dbms_output.put_line('p_flag'||p_flag);
    END IF;
  END IF;
  dbms_output.put_line('Before 4');
  dbms_output.put_line('V_SHIP_FLAG'||V_SHIP_FLAG);
  dbms_output.put_line('V_FLAG'||V_FLAG);
  IF V_SHIP_FLAG='1' THEN-- IF REC_Get_esn_details.active_esn    IS NOT NULL THEN
    IF (V_FLAG  ='ACTIVE' AND TRUNC(v_exp_date) < TRUNC(SYSDATE)) OR (V_FLAG ='INACTIVE' AND TRUNC(v_exp_date) > TRUNC(SYSDATE)) OR (V_FLAG ='INACTIVE' AND TRUNC(v_exp_date) < TRUNC(SYSDATE)) THEN
      dbms_output.put_line('4');
      OPEN SHIP_CHECK(P_case_id);
      FETCH SHIP_CHECK INTO REC_SHIP_CHECK;
      IF SHIP_CHECK%found THEN
        V_SHIP_FLAG := '1';
      END IF;
      CLOSE SHIP_CHECK;
      OPEN Get_ship_esn_details(REC_SHIP_CHECK.X_PART_SERIAL_NO);
      FETCH Get_ship_esn_details INTO REC_Get_ship_esn_details;
      IF Get_ship_esn_details%NOTFOUND THEN
        dbms_output.put_line('Get_ship_esn_details not found');
        P_ERROR_NO  := '1';
        P_ERROR_STR := 'SHIP ESN NOT FOUND';
      END IF;
      CLOSE Get_ship_esn_details;
      OPEN get_objid(REC_Get_ship_esn_details.X_REQUESTED_PLAN);
      FETCH get_objid INTO rec_get_objid;
      IF get_objid%found THEN
        P_OBJID := rec_get_objid.objid;
      END IF;
      CLOSE get_objid;
      dbms_output.put_line('P_OBJID'||P_OBJID);
      P_REPL_UNITS        :=REC_SHIP_CHECK.X_REPLACEMENT_UNITS;
      P_REQUEST_PLAN      :=REC_Get_ship_esn_details.X_REQUESTED_PLAN;
      P_LID               :=REC_Get_ship_esn_details.LID;
      P_CONT_PART_INST    :=REC_Get_ship_esn_details.X_CONTACT_PART_INST2CONTACT;
      P_MIN               :=REC_SHIP_CHECK.X_MIN;
      P_ACTIVE_ESN        :=REC_SHIP_CHECK.X_PART_SERIAL_NO;
      p_active_esn_status := REC_SHIP_CHECK.X_PART_INST_STATUS;
      P_LOGIN_NAME        :=REC_Get_ship_esn_details.LOGIN_NAME;
      P_WEB_USER_ID       :=REC_Get_ship_esn_details.web_user_objid;
      P_STATE             :=REC_Get_ship_esn_details.STATE;
      P_FLAG              :=REC_SHIP_CHECK.SH_FLAG;
      dbms_output.put_line('P_REPL_UNITS'||P_REPL_UNITS);
      dbms_output.put_line('P_REQUEST_PLAN'||P_REQUEST_PLAN);
      dbms_output.put_line('P_LID'||P_LID);
      dbms_output.put_line('P_CONT_PART_INST'||P_CONT_PART_INST);
      dbms_output.put_line('P_MIN'||P_MIN);
      dbms_output.put_line('P_ACTIVE_ESN'||P_ACTIVE_ESN);
      dbms_output.put_line('p_active_esn_status'||p_active_esn_status);
      dbms_output.put_line('P_LOGIN_NAME'||P_LOGIN_NAME);
      dbms_output.put_line('P_WEB_USER_ID'||P_WEB_USER_ID);
      dbms_output.put_line('P_STATE'||P_STATE);
      dbms_output.put_line('P_FLAG'||P_FLAG);
    END IF;
  END IF;
  dbms_output.put_line('outside 4');
  dbms_output.put_line('before 5');
  dbms_output.put_line('V_SHIP_FLAG'||V_SHIP_FLAG);
  dbms_output.put_line('V_FLAG'||V_FLAG);
  IF V_SHIP_FLAG ='0' THEN-- IF REC_Get_esn_details.active_esn  IS NULL THEN
    IF (V_FLAG   ='ACTIVE' AND TRUNC(v_exp_date) < TRUNC(SYSDATE)) OR (V_FLAG ='INACTIVE' AND TRUNC(v_exp_date) > TRUNC(SYSDATE)) OR (V_FLAG ='INACTIVE' AND TRUNC(v_exp_date) < TRUNC(SYSDATE)) THEN
      dbms_output.put_line('5');
      OPEN get_objid(REC_Get_esn_details.X_REQUESTED_PLAN);
      FETCH get_objid INTO rec_get_objid;
      IF get_objid%found THEN
        P_OBJID := rec_get_objid.objid;
      END IF;
      CLOSE get_objid;
      dbms_output.put_line('P_OBJID'||P_OBJID);
      P_REPL_UNITS        :=REC_Get_esn_details.X_REPLACEMENT_UNITS;
      P_REQUEST_PLAN      :=REC_Get_esn_details.X_REQUESTED_PLAN;
      P_LID               :=REC_Get_esn_details.LID;
      P_CONT_PART_INST    :=REC_Get_esn_details.X_CONTACT_PART_INST2CONTACT;
      P_MIN               :=REC_Get_esn_details.X_MIN;
      P_ACTIVE_ESN        :=REC_Get_esn_details.X_ESN;
      p_active_esn_status := REC_Get_esn_details.X_PART_INST_STATUS;
      P_LOGIN_NAME        :=REC_Get_esn_details.LOGIN_NAME;
      P_WEB_USER_ID       :=REC_Get_esn_details.web_user_objid;
      P_STATE             :=REC_Get_esn_details.STATE;
      --P_FLAG              :='ACTIVE';
      dbms_output.put_line('P_REPL_UNITS'||P_REPL_UNITS);
      dbms_output.put_line('P_REQUEST_PLAN'||P_REQUEST_PLAN);
      dbms_output.put_line('P_LID'||P_LID);
      dbms_output.put_line('P_CONT_PART_INST'||P_CONT_PART_INST);
      dbms_output.put_line('P_MIN'||P_MIN);
      dbms_output.put_line('P_ACTIVE_ESN'||P_ACTIVE_ESN);
      dbms_output.put_line('p_active_esn_status'||p_active_esn_status);
      dbms_output.put_line('P_LOGIN_NAME'||P_LOGIN_NAME);
      dbms_output.put_line('P_WEB_USER_ID'||P_WEB_USER_ID);
      dbms_output.put_line('P_STATE'||P_STATE);
      dbms_output.put_line('P_FLAG'||P_FLAG);
    END IF;
  END IF;
  dbms_output.put_line('outside 5');
  OPEN NEW_PART_INST_C(P_NEW_ESN);
  FETCH NEW_PART_INST_C INTO REC_NEW_PART_INST_C;
  IF NEW_PART_INST_C%NOTFOUND THEN
    P_ERROR_NO  := '1';
    P_ERROR_STR := 'NEW ESN NOT FOUND';
    CLOSE NEW_PART_INST_C;
    RETURN;
  END IF;
  CLOSE NEW_PART_INST_C;
  dbms_output.put_line('V_FLAG'||V_FLAG);
  ---------------------------OTA PENDING----------------------

  ACTIVE_SAFELINK_REPL_PHONES.OTA_PENDING_PROCESS(P_ACTIVE_ESN,V_ERROR_NO,V_ERROR_STR);
  V_ERROR_NO := null;
  V_ERROR_STR:= null;
  -----------------OTA PENDING--------------
  ----------------------------------------FOR SHIPPED ESN-----------------------------------------------------
  IF P_FLAG='INACTIVE' THEN
    -----------------------------------RESERVE LINE TO NEW PHONE, ADD NEW PHONE, REMOVE DEFECTIVE ESN FROM ACCOUNT---------------------------------------------------------
    ACTIVE_SAFELINK_REPL_PHONES.SP_NON_ACTIVE_ESN_NO_SHIPED_PH ( P_case_id ,P_ACTIVE_ESN ,P_NEW_ESN ,P_ERROR_NO ,P_ERROR_STR );
    -------------------------CHANGES END HERE---------------------------------------------------------------------
  END IF;
  ---------------------------------additions end----------------------------------------------------------
  dbms_output.put_line('V_FLAG'||V_FLAG);
  IF (P_FLAG = 'ACTIVE' AND p_active_esn_status <> '52') THEN
    ACTIVE_SAFELINK_REPL_PHONES.SP_MOVE_RESERVED_LINE ( P_case_id ,P_ACTIVE_ESN ,P_NEW_ESN ,REC_NEW_PART_INST_C.OBJID ,P_ERROR_NO ,P_ERROR_STR );
  END IF;
  ---call procedure
EXCEPTION
WHEN OTHERS THEN
  ROLLBACK;
  RAISE;
END SP_active_safelink_phones;
------------------------------------------------------------RESERVE LINE TO NEW PHONE IF THERE WHERE A LINE RESERVED ON DEFECTIVE PHONE--------------------------------
PROCEDURE SP_MOVE_RESERVED_LINE(
    P_CASE_OBJID              IN VARCHAR2 ,
    P_OLD_ESN                 IN VARCHAR2 ,
    P_NEW_ESN                 IN VARCHAR2 ,
    P_NEW_ESN_PART_INST_OBJID IN sa.TABLE_PART_INST.OBJID%TYPE ,
    P_ERROR_NO OUT VARCHAR2 ,
    P_ERROR_STR OUT VARCHAR2 )
AS
  CURSOR LINE_RESERVED_CUR ( ESN VARCHAR2 )
  IS
    SELECT *
    FROM TABLE_PART_INST
    WHERE PART_TO_ESN2PART_INST IN
      (SELECT OBJID
      FROM TABLE_PART_INST
      WHERE PART_SERIAL_NO = ESN
      AND X_DOMAIN         = 'PHONES'
      )
  AND X_DOMAIN            = 'LINES'
  AND X_PART_INST_STATUS IN ('37' ,'39');
  LINE_RESERVED_REC LINE_RESERVED_CUR%ROWTYPE;
  L_V_PROCEDURE_STEP VARCHAR2(32767);
  L_B_DEBUG          BOOLEAN := TRUE;
BEGIN
  P_ERROR_NO         := '0';
  P_ERROR_STR        := 'SUCCESS';
  L_V_PROCEDURE_STEP := 'GET CASE ESN RESERVED LINE';
  IF L_B_DEBUG THEN
    DBMS_OUTPUT.PUT_LINE(L_V_PROCEDURE_STEP || ' ' || TO_CHAR(SYSDATE ,'MM/DD/YYYY HH:MI:SS PM'));
  END IF;
  OPEN LINE_RESERVED_CUR(P_OLD_ESN);
  FETCH LINE_RESERVED_CUR INTO LINE_RESERVED_REC;
  IF LINE_RESERVED_CUR%FOUND THEN
    CLOSE LINE_RESERVED_CUR;
    L_V_PROCEDURE_STEP := 'ASSOCIATE SHIPPED ESN WITH RESERVED LINE';
    IF L_B_DEBUG THEN
      DBMS_OUTPUT.PUT_LINE(L_V_PROCEDURE_STEP || ' ' || TO_CHAR(SYSDATE ,'MM/DD/YYYY HH:MI:SS PM'));
    END IF;
    UPDATE TABLE_PART_INST
    SET PART_TO_ESN2PART_INST = P_NEW_ESN_PART_INST_OBJID
    WHERE OBJID               = LINE_RESERVED_REC.OBJID;
  ELSE
    CLOSE LINE_RESERVED_CUR;
  END IF;
EXCEPTION
WHEN OTHERS THEN
  RAISE;
END SP_MOVE_RESERVED_LINE;
-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
------------------------------------------ADD NEW PHONE TO ACCOUNT AND REMOVE DEFECTIVE PHONE-------------------------------------------------------------
PROCEDURE SP_MANAGE_ACCT(
    P_CASE_OBJID              IN VARCHAR2 ,
    P_OLD_ESN                 IN VARCHAR2 ,
    P_NEW_ESN                 IN VARCHAR2 ,
    P_NEW_ESN_PART_INST_OBJID IN sa.TABLE_PART_INST.OBJID%TYPE ,
    P_ERROR_NO OUT VARCHAR2 ,
    P_ERROR_STR OUT VARCHAR2 )
AS
  L_V_PROCEDURE_STEP VARCHAR2(32767);
  L_B_DEBUG          BOOLEAN := TRUE;
  CURSOR BUS_ACC_ESN_CUR(ESN VARCHAR2)
  IS
    SELECT CPI.*
    FROM sa.TABLE_X_CONTACT_PART_INST CPI ,
      sa.TABLE_PART_INST PI
    WHERE PI.OBJID        = CPI.X_CONTACT_PART_INST2PART_INST
    AND PI.PART_SERIAL_NO = ESN;
  BUS_ACC_ESN_OLD_REC BUS_ACC_ESN_CUR%ROWTYPE;
BEGIN
  -- ADD NEW ESN TO BUSINESS ACCOUNT IF APPLICABLE
  L_V_PROCEDURE_STEP := 'GET BUSINESS ACCOUNT CONTACT INFORMATION';
  IF L_B_DEBUG THEN
    DBMS_OUTPUT.PUT_LINE(L_V_PROCEDURE_STEP || ' ' || TO_CHAR(SYSDATE ,'MM/DD/YYYY HH:MI:SS PM'));
  END IF;
  OPEN BUS_ACC_ESN_CUR(P_OLD_ESN);
  FETCH BUS_ACC_ESN_CUR INTO BUS_ACC_ESN_OLD_REC;
  IF BUS_ACC_ESN_CUR%FOUND THEN
    L_V_PROCEDURE_STEP := 'BUSINESS ACCOUNT CONTACT FOUND; ASSOCIATE NEW ESN WITH BUSINESS ACCOUNT CONTACT';
    IF L_B_DEBUG THEN
      DBMS_OUTPUT.PUT_LINE(L_V_PROCEDURE_STEP || ' ' || TO_CHAR(SYSDATE ,'MM/DD/YYYY HH:MI:SS PM'));
    END IF;
    INSERT
    INTO sa.TABLE_X_CONTACT_PART_INST
      (
        OBJID ,
        X_CONTACT_PART_INST2CONTACT ,
        X_CONTACT_PART_INST2PART_INST ,
        X_ESN_NICK_NAME ,
        X_IS_DEFAULT ,
        X_TRANSFER_FLAG ,
        X_VERIFIED
      )
      VALUES
      (
        sa.SEQ('X_CONTACT_PART_INST') ,
        BUS_ACC_ESN_OLD_REC.X_CONTACT_PART_INST2CONTACT,
        P_NEW_ESN_PART_INST_OBJID,
        NULL ,
        0 ,
        0 ,
        'Y'
      );
    --REMOVE DEFECTIVE ESN FROM THIS BUSINESS ACCOUNT
    DELETE sa.TABLE_X_CONTACT_PART_INST
    WHERE OBJID = BUS_ACC_ESN_OLD_REC.OBJID;
  END IF;
  CLOSE BUS_ACC_ESN_CUR;
  P_ERROR_NO  := '0';
  P_ERROR_STR := 'SUCCESS';
EXCEPTION
WHEN OTHERS THEN
  ROLLBACK;
  RAISE;
END SP_MANAGE_ACCT;
-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
PROCEDURE SP_NON_ACTIVE_ESN_NO_SHIPED_PH(
    P_CASE_OBJID IN VARCHAR2 ,
    P_OLD_ESN    IN VARCHAR2 ,
    P_NEW_ESN    IN VARCHAR2 ,
    P_ERROR_NO OUT VARCHAR2 ,
    P_ERROR_STR OUT VARCHAR2 )
AS
  --GET THE NEW ESN
  CURSOR NEW_PART_INST_C(P_ESN VARCHAR2)
  IS
    SELECT PI.* ,
      TABLE_PART_NUM.X_TECHNOLOGY
    FROM TABLE_PART_INST PI ,
      TABLE_MOD_LEVEL ,
      TABLE_PART_NUM
    WHERE PART_SERIAL_NO     = P_ESN
    AND N_PART_INST2PART_MOD = TABLE_MOD_LEVEL.OBJID
    AND PART_INFO2PART_NUM   = TABLE_PART_NUM.OBJID;
  REC_NEW_PART_INST_C NEW_PART_INST_C%ROWTYPE;
  L_V_PROCEDURE_STEP VARCHAR2(32767);
  L_B_DEBUG          BOOLEAN := TRUE;
BEGIN
  P_ERROR_NO  := '0';
  P_ERROR_STR := 'SUCCESS';
  OPEN NEW_PART_INST_C(P_NEW_ESN);
  FETCH NEW_PART_INST_C INTO REC_NEW_PART_INST_C;
  IF NEW_PART_INST_C%NOTFOUND THEN
    P_ERROR_NO  := '1';
    P_ERROR_STR := 'NEW ESN NOT FOUND';
    CLOSE NEW_PART_INST_C;
    DBMS_OUTPUT.PUT_LINE('FAILURE STEP: ' || L_V_PROCEDURE_STEP);
    DBMS_OUTPUT.PUT_LINE('P_ERROR_NO : ' || P_ERROR_NO);
    DBMS_OUTPUT.PUT_LINE('P_ERROR_STR : ' || P_ERROR_STR);
    RETURN;
  END IF;
  CLOSE NEW_PART_INST_C;
  --RESERVE LINE TO NEW PHONE IF THERE WERE A LINE RESERVED ON DEFECTIVE PHONE
  ACTIVE_SAFELINK_REPL_PHONES.SP_MOVE_RESERVED_LINE ( P_CASE_OBJID ,P_OLD_ESN ,P_NEW_ESN ,REC_NEW_PART_INST_C.OBJID ,P_ERROR_NO ,P_ERROR_STR );
  --ADD NEW PHONE TO ACCOUNT AND REMOVE DEFECTIVE ESN FROM THIS BUSINESS ACCOUNT
  ACTIVE_SAFELINK_REPL_PHONES.SP_MANAGE_ACCT ( P_CASE_OBJID ,P_OLD_ESN ,P_NEW_ESN ,REC_NEW_PART_INST_C.OBJID ,P_ERROR_NO ,P_ERROR_STR );
EXCEPTION
WHEN OTHERS THEN
  ROLLBACK;
  RAISE;
END SP_NON_ACTIVE_ESN_NO_SHIPED_PH;
PROCEDURE OTA_PENDING_PROCESS(
    P_ESN IN VARCHAR2,
    P_ERROR_NO OUT VARCHAR2 ,
    P_ERROR_STR OUT VARCHAR2)
AS
  hold1       VARCHAR2 (200) := NULL;
  hold2       VARCHAR2 (200) := NULL;
  total_codes NUMBER         := 0;
  l_max_days  NUMBER         := 15;
  CURSOR c1(P_ESN VARCHAR2)
  IS
    SELECT ota.*
    FROM table_x_ota_transaction ota
    WHERE 1          = 1
    AND ota.x_esn    = P_ESN
    AND ota.x_status = 'OTA PENDING';
  CURSOR c2(c_call_trans_objid IN NUMBER)
  IS
    SELECT ct.CALL_TRANS2SITE_PART,
      ct.x_result ct_result,
      (SELECT COUNT (objid) code_exists
      FROM sa.table_x_code_hist
      WHERE CODE_HIST2CALL_TRANS = ct.objid
      AND X_CODE_ACCEPTED
        || ''    = 'OTAPENDING'
      AND ROWNUM < 2
      ) code_exists
  FROM table_x_call_trans ct
  WHERE 1      = 1
  AND ct.objid = c_call_trans_objid;
BEGIN
 P_ERROR_NO  := '0';
  P_ERROR_STR := 'SUCCESS';
  FOR c1_rec IN c1(P_ESN)
  LOOP
    FOR c2_rec IN c2(c1_rec.X_OTA_TRANS2X_CALL_TRANS)
    LOOP
      IF c2_rec.code_exists = 1 THEN
        UPDATE TABLE_SITE_PART
        SET WARRANTY_DATE  = X_EXPIRE_DT
        WHERE X_SERVICE_ID = c1_rec.X_ESN
        AND PART_STATUS
          || '' = 'Active';
        COMMIT;
        INSERT
        INTO X_OTA_CLOSED_BP VALUES
          (
            c1_rec.X_ESN,
            c1_rec.X_MIN,
            c1_rec.X_OTA_TRANS2X_CALL_TRANS,
            c1_rec.X_TRANSACTION_DATE,
            SYSDATE,
            'SL_PRE_ACT'
          );
        COMMIT;
        sa.convert_bo_to_sql_pkg.otacodeacceptedupdate (c1_rec.X_OTA_TRANS2X_CALL_TRANS, hold1, hold2, P_ERROR_NO, P_ERROR_STR);
        sa.convert_bo_to_sql_pkg.OTAcompleteTransaction (c1_rec.X_ESN, c1_rec.X_OTA_TRANS2X_CALL_TRANS, c1_rec.X_MIN, total_codes, 'English', P_ERROR_NO, P_ERROR_STR);
      END IF;
      IF c2_rec.ct_result = 'OTA PENDING' THEN
        UPDATE table_x_call_trans
        SET x_result = 'Completed'
        WHERE objid  = c1_rec.X_OTA_TRANS2X_CALL_TRANS;
        COMMIT;
      END IF;
      DELETE
      FROM TABLE_X_PENDING_REDEMPTION
      WHERE REDEEM_IN2CALL_TRANS = c1_rec.X_OTA_TRANS2X_CALL_TRANS
      AND X_PEND_RED2SITE_PART   = c2_rec.CALL_TRANS2SITE_PART;
      COMMIT;
    END LOOP;
    IF c1_rec.x_status = 'OTA PENDING' THEN
      UPDATE table_x_ota_transaction
      SET x_status                   = 'Completed'
      WHERE x_ota_trans2x_call_trans = c1_rec.X_OTA_TRANS2X_CALL_TRANS;
      COMMIT;
    END IF;
    COMMIT;
  END LOOP;
  COMMIT;
  EXCEPTION
WHEN OTHERS THEN
  ROLLBACK;
  RAISE;
END OTA_PENDING_PROCESS;
END ACTIVE_SAFELINK_REPL_PHONES;
-- ANTHILL_TEST PLSQL/SA/PackageBodies/Active_safelink_repl_phone_pkb.sql  CR31107: 1.3
-- ANTHILL_TEST PLSQL/SA/PackageBodies/Active_safelink_repl_phone_pkb.sql  CR31107: 1.4
-- ANTHILL_TEST PLSQL/SA/PackageBodies/Active_safelink_repl_phone_pkb.sql  CR31107: 1.5
-- ANTHILL_TEST PLSQL/SA/PackageBodies/Active_safelink_repl_phone_pkb.sql  CR31107: 1.6
-- ANTHILL_TEST PLSQL/SA/PackageBodies/Active_safelink_repl_phone_pkb.sql  CR31107: 1.7
-- ANTHILL_TEST PLSQL/SA/PackageBodies/Active_safelink_repl_phone_pkb.sql  CR31107: 1.8
-- ANTHILL_TEST PLSQL/SA/PackageBodies/Active_safelink_repl_phone_pkb.sql  CR31107: 1.9
-- ANTHILL_TEST PLSQL/SA/PackageBodies/Active_safelink_repl_phone_pkb.sql  CR31107: 1.10
-- ANTHILL_TEST PLSQL/SA/PackageBodies/Active_safelink_repl_phone_pkb.sql  CR31107: 1.11
-- ANTHILL_TEST PLSQL/SA/PackageBodies/Active_safelink_repl_phone_pkb.sql  CR31107: 1.13
-- ANTHILL_TEST PLSQL/SA/PackageBodies/Active_safelink_repl_phone_pkb.sql  CR31107: 1.16
-- ANTHILL_TEST PLSQL/SA/PackageBodies/Active_safelink_repl_phone_pkb.sql
-- ANTHILL_TEST PLSQL/SA/PackageBodies/Active_safelink_repl_phone_pkb.sql 	CR33130: 1.21
/