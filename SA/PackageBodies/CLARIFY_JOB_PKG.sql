CREATE OR REPLACE PACKAGE BODY sa."CLARIFY_JOB_PKG"
AS
  /************************************************************************************************
  PURPOSE:  Manage the table jobs, used for backend activations of warehouse exchanges
  1.0   04/01/2011  nguada  Initial Revision
  |************************************************************************************************/
  ---------------------------------------------------------------------------------------------
  --$RCSfile: CLARIFY_JOB_PKG_BODY.sql,v $
  --$Revision: 1.7 $
  --$Author: jarza $
  --$Date: 2015/01/06 16:17:08 $
  --$ $Log: CLARIFY_JOB_PKG_BODY.sql,v $
  --$ Revision 1.7  2015/01/06 16:17:08  jarza
  --$ CR30528 - Added a new parameter to 2 procedures
  --$
  --$ Revision 1.6  2012/01/06 19:45:27  lsatuluri
  --$ Checking in latest code from Natalio on jan 6th 2012
  --$
  --$ Revision 1.5  2011/11/30 20:58:21  lsatuluri
  --$ *** empty log message ***
  --$
  --$ Revision 1.3  2011/11/07 18:55:21  akhan
  --$ Checking in latest code from Natalio
  --$
  ---------------------------------------------------------------------------------------------
PROCEDURE create_job(
    ip_title          IN VARCHAR2,
    ip_case_objid     IN NUMBER,
    Ip_User_Objid     IN NUMBER,
    ip_old_esn        IN VARCHAR2,
    Ip_Esn            IN VARCHAR2,
    Ip_Min            IN VARCHAR2,
    Ip_Program_Objid  IN NUMBER,
    Ip_Web_User_Objid IN NUMBER,
    ip_contact_objid  IN NUMBER,
    Ip_Zip            IN VARCHAR2,
    ip_iccid          IN VARCHAR2,
    op_job_objid OUT NUMBER,
    op_error_no OUT VARCHAR2,
    op_error_str OUT VARCHAR2)
AS
  CURSOR status_curs
  IS
    SELECT elm.objid,
      elm.title
    FROM table_gbst_elm elm,
      table_gbst_lst lst
    WHERE GBST_ELM2GBST_LST = lst.objid
    AND lst.title           = 'Open'
    AND elm.title           = 'Pending';
  status_rec status_curs%rowtype;
  CURSOR user_curs
  IS
    SELECT login_name FROM table_user WHERE objid = ip_user_objid;
  user_rec user_curs%ROWTYPE;
  CURSOR case_curs
  IS
    SELECT * FROM table_case WHERE objid = ip_case_objid;
  case_rec case_curs%rowtype;
  job_objid            NUMBER;
  condition_objid      NUMBER;
  job_history          VARCHAR2(1000);
  P_REPL_PART          VARCHAR2(30);
  P_REPL_TECH          VARCHAR2(30);
  P_SIM_PROFILE        VARCHAR2(30);
  P_PART_SERIAL_NO     VARCHAR2(30);
  P_Msg                VARCHAR2(200);
  P_Pref_Parent        VARCHAR2(200);
  P_Pref_Carrier_Objid VARCHAR2(30);
  nap_verify_result    NUMBER;
BEGIN
  SELECT sa.seq('job') INTO job_objid FROM dual;
  OPEN status_curs;
  FETCH status_curs INTO status_rec;
  IF status_curs%notfound THEN
    CLOSE status_curs;
    op_error_no :='JOB:010';
    op_error_str:='Status reference not found';
    RETURN;
  ELSE
    CLOSE status_curs;
  END IF;
  OPEN case_curs;
  FETCH case_curs INTO case_rec;
  IF case_curs%notfound THEN
    CLOSE case_curs;
    op_error_no :='JOB:020';
    op_error_str:='Case reference not found';
    RETURN;
  ELSE
    CLOSE case_curs;
  END IF;
  OPEN user_curs;
  FETCH user_curs INTO user_rec;
  IF user_curs%notfound THEN
    CLOSE user_curs;
    op_error_no :='JOB:030';
    op_error_str:='User reference not found';
    RETURN;
  ELSE
    CLOSE user_curs;
  END IF;
  Job_History:=TO_CHAR(Sysdate,'yyyy-mm-dd hh:mi PM')||' '||Ip_Title||' job created by '||User_Rec.Login_Name||Chr(10);
  sa.Nap_Digital( P_Zip => Ip_Zip, P_Esn => Ip_Esn, P_Commit => 'N', P_Language => 'English', P_Sim => Ip_Iccid, P_Source => 'WEBCSR', P_Upg_Flag => 'N', P_Repl_Part => P_Repl_Part, P_Repl_Tech => P_Repl_Tech, P_Sim_Profile => P_Sim_Profile, P_Part_Serial_No => P_Part_Serial_No, P_Msg => P_Msg, P_Pref_Parent => P_Pref_Parent, P_Pref_Carrier_Objid => P_Pref_Carrier_Objid );
  -- Verify if NAP sugested carrier matches the carrier associated to the line
  SELECT COUNT(*)
  INTO Nap_Verify_Result
  FROM Table_Part_Inst
  WHERE Part_Serial_No      = Ip_Min
  AND x_domain              = 'LINES'
  AND Part_Inst2carrier_Mkt = To_Number(P_Pref_Carrier_Objid);
  IF Nap_Verify_Result      >0 THEN -- Line belongs to carrier sugested by Nap
    INSERT
    INTO sa.Table_Job
      (
        Objid,
        Id_Number,
        Title,
        S_Title,
        Job_History,
        Job_Result2case,
        Job_Sts2gbst_Elm,
        Job_Originator2user,
        X_Esn,
        X_Min,
        X_Program_Objid,
        X_Web_User_Objid,
        X_Iccid,
        X_Zip,
        X_Contact_Objid,
        X_Old_Esn
        ,X_IDN_USER_CREATED
        ,X_DTE_CREATED
        ,X_IDN_USER_CHANGE_LAST
        ,X_DTE_CHANGE_LAST
      )
      VALUES
      (
        Job_Objid,
        Job_Objid,
        Ip_Title,
        Upper(Ip_Title),
        Job_History,
        Ip_Case_Objid,
        Status_Rec.Objid,
        Ip_User_Objid,
        Ip_Esn,
        Ip_Min,
        Ip_Program_Objid,
        Ip_Web_User_Objid,
        ip_iccid,
        ip_zip,
        ip_contact_objid,
        ip_old_esn
        ,Ip_User_Objid    --,X_IDN_USER_CREATED
        ,SYSDATE          --X_DTE_CREATED
        ,Ip_User_Objid    --X_IDN_USER_CHANGE_LAST
        ,SYSDATE          --X_DTE_CHANGE_LAST
      );
    op_job_objid:=job_objid;
    op_error_no :='0';
    Op_Error_Str:='';
    COMMIT;
  ELSE
    Op_Error_No :='JOB:040';
    Op_Error_Str:='Nap Verify Failed';
    RETURN;
  END IF;
EXCEPTION
WHEN OTHERS THEN
  ROLLBACK;
  op_error_no :='JOB:050';
  op_error_str:=sqlerrm;
  RETURN;
END;
PROCEDURE change_status
  (
    ip_job_objid  NUMBER,
    ip_job_status VARCHAR2,
    ip_comment    VARCHAR2,
    IP_IDN_USER_CHANGE_LAST     IN sa.TABLE_JOB.X_IDN_USER_CHANGE_LAST%TYPE,
    op_error_no OUT VARCHAR2,
    op_error_str OUT VARCHAR2
  )
AS
  CURSOR job_curs
  IS
    SELECT * FROM table_job WHERE objid = ip_job_objid;
  job_rec job_curs%rowtype;
  CURSOR status_curs
  IS
    SELECT elm.objid,
      elm.title
    FROM table_gbst_elm elm,
      table_gbst_lst lst
    WHERE GBST_ELM2GBST_LST = lst.objid
    AND lst.title           = 'Open'
    AND elm.title           = ip_job_status;
  status_rec status_curs%rowtype;
BEGIN
  op_error_no :='0';
  op_error_str:='';
  OPEN job_curs;
  FETCH job_curs INTO job_rec;
  IF job_curs%notfound THEN
    CLOSE job_curs;
    op_error_no :='JOB:050';
    op_error_str:='Job reference not found';
    RETURN;
  ELSE
    CLOSE job_curs;
  END IF;
  OPEN status_curs;
  FETCH Status_Curs INTO Status_Rec;
  IF status_curs%notfound THEN
    CLOSE status_curs;
    op_error_no :='JOB:060';
    op_error_str:='Status reference not found';
    RETURN;
  ELSE
    CLOSE status_curs;
  END IF;
  UPDATE table_job
  SET job_sts2gbst_elm=status_rec.objid
      , X_IDN_USER_CHANGE_LAST = IP_IDN_USER_CHANGE_LAST
      , X_DTE_CHANGE_LAST = SYSDATE
  WHERE objid         = ip_job_objid;
  COMMIT;
EXCEPTION
WHEN OTHERS THEN
  ROLLBACK;
  op_error_no :='JOB:040';
  op_error_str:=sqlerrm;
  RETURN;
END;
PROCEDURE close_job(
    ip_job_objid NUMBER,
    IP_IDN_USER_CHANGE_LAST     IN sa.TABLE_JOB.X_IDN_USER_CHANGE_LAST%TYPE,
    op_error_no OUT VARCHAR2,
    op_error_str OUT VARCHAR2)
AS
  CURSOR job_curs
  IS
    SELECT * FROM table_job WHERE objid = ip_job_objid;
  job_rec job_curs%rowtype;
  CURSOR status_curs
  IS
    SELECT elm.objid,
      elm.title
    FROM table_gbst_elm elm,
      table_gbst_lst lst
    WHERE GBST_ELM2GBST_LST = lst.objid
    AND lst.title           = 'Closed'
    AND elm.title           = 'Closed';
  status_rec status_curs%rowtype;
BEGIN
  op_error_no :='0';
  op_error_str:='';
  OPEN job_curs;
  FETCH job_curs INTO job_rec;
  IF job_curs%notfound THEN
    CLOSE job_curs;
    op_error_no :='JOB:050';
    op_error_str:='Job reference not found';
    RETURN;
  ELSE
    CLOSE job_curs;
  END IF;
  OPEN status_curs;
  FETCH Status_Curs INTO Status_Rec;
  IF status_curs%notfound THEN
    CLOSE status_curs;
    op_error_no :='JOB:060';
    op_error_str:='Status reference not found';
    RETURN;
  ELSE
    CLOSE status_curs;
  END IF;
  UPDATE table_job
  SET job_sts2gbst_elm=status_rec.objid
      , X_IDN_USER_CHANGE_LAST = IP_IDN_USER_CHANGE_LAST
      , X_DTE_CHANGE_LAST = SYSDATE
  WHERE objid         = ip_job_objid;
  COMMIT;
EXCEPTION
WHEN OTHERS THEN
  ROLLBACK;
  op_error_no :='JOB:040';
  op_error_str:=sqlerrm;
  RETURN;
END;
END CLARIFY_JOB_PKG;
/