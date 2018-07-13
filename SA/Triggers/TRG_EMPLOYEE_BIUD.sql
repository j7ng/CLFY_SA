CREATE OR REPLACE TRIGGER sa."TRG_EMPLOYEE_BIUD"
BEFORE INSERT OR UPDATE OR DELETE ON sa.TABLE_EMPLOYEE
REFERENCING NEW AS NEW OLD AS OLD
FOR EACH ROW
DECLARE
 v_action VARCHAR2(1);
 v_osuser  varchar2(50);
 v_userid varchar2(30);

BEGIN
      IF INSERTING  THEN
         v_action := 'I' ;
      ELSIF  UPDATING THEN
         v_action := 'U' ;
      ELSE
         v_action := 'D' ;
      END IF;

      select objid,
             sys_context('USERENV','OS_USER')
      into  v_userid,
            v_osuser
      from table_user where upper(login_name) = upper(user);
      INSERT INTO x_EMPLOYEE_HIST
                  ( OBJID,
FIRST_NAME,
S_FIRST_NAME,
LAST_NAME,
S_LAST_NAME,
MAIL_STOP,
PHONE,
ALT_PHONE,
FAX,
BEEPER,
E_MAIL,
LABOR_RATE,
FIELD_ENG,
ACTING_SUPVR,
AVAILABLE,
AVAIL_NOTE,
EMPLOYEE_NO,
NORMAL_BIZ_HIGH,
NORMAL_BIZ_MID,
NORMAL_BIZ_LOW,
AFTER_BIZ_HIGH,
AFTER_BIZ_MID,
AFTER_BIZ_LOW,
WORK_GROUP,
WG_STRT_DATE,
SITE_STRT_DATE,
VOICE_MAIL_BOX,
LOCAL_LOGIN,
LOCAL_PASSWORD,
ALLOW_PROXY,
PRINTER,
ON_CALL_HW,
ON_CALL_SW,
CASE_THRESHOLD,
DEV,
EMPLOYEE2USER,
EMP_SUPVR2EMPLOYEE,
SUPP_PERSON_OFF2SITE,
CC_LIST2BUG,
EMPL_HRS2BIZ_CAL_HDR,
EMPLOYEE2CONTACT,
X_DASHBOARD,
X_ERROR_CODE_MAINT,
X_ORDER_TYPES,
X_Q_MAINT,
X_SELECT_TRANS_PROF,
X_UPDATE_SET,
X_ALLOW_SCRIPT,
X_ALLOW_ROADSIDE,
SALUTATION,
TITLE,
EMPLOYEE_HIST2EMPLOYEE,
EMPLOYEE_HIST2USER,
X_CHANGE_DATE,
OSUSER,
TRIGGERING_RECORD_TYPE)
           VALUES ( SEQU_X_EMP_HIST.nextval,
                    decode(v_action,'I',:new.FIRST_NAME,:old.FIRST_NAME),
                    decode(v_action,'I',:new.S_FIRST_NAME,:old.S_FIRST_NAME),
                    decode(v_action,'I',:new.LAST_NAME,:old.LAST_NAME),
                    decode(v_action,'I',:new.S_LAST_NAME,:old.S_LAST_NAME),
                    decode(v_action,'I',:new.MAIL_STOP,:old.MAIL_STOP),
                    decode(v_action,'I',:new.PHONE,:old.PHONE),
                    decode(v_action,'I',:new.ALT_PHONE,:old.ALT_PHONE),
                    decode(v_action,'I',:new.FAX,:old.FAX),
                    decode(v_action,'I',:new.BEEPER,:old.BEEPER),
                    decode(v_action,'I',:new.E_MAIL,:old.E_MAIL),
                    decode(v_action,'I',:new.LABOR_RATE,:old.LABOR_RATE),
                    decode(v_action,'I',:new.FIELD_ENG,:old.FIELD_ENG),
                    decode(v_action,'I',:new.ACTING_SUPVR,:old.ACTING_SUPVR),
                    decode(v_action,'I',:new.AVAILABLE,:old.AVAILABLE),
                    decode(v_action,'I',:new.AVAIL_NOTE,:old.AVAIL_NOTE),
                    decode(v_action,'I',:new.EMPLOYEE_NO,:old.EMPLOYEE_NO),
                    decode(v_action,'I',:new.NORMAL_BIZ_HIGH,:old.NORMAL_BIZ_HIGH),
                    decode(v_action,'I',:new.NORMAL_BIZ_MID,:old.NORMAL_BIZ_MID),
                    decode(v_action,'I',:new.NORMAL_BIZ_LOW,:old.NORMAL_BIZ_LOW),
                    decode(v_action,'I',:new.AFTER_BIZ_HIGH,:old.AFTER_BIZ_HIGH),
                    decode(v_action,'I',:new.AFTER_BIZ_MID,:old.AFTER_BIZ_MID),
                    decode(v_action,'I',:new.AFTER_BIZ_LOW,:old.AFTER_BIZ_LOW),
                    decode(v_action,'I',:new.WORK_GROUP,:old.WORK_GROUP),
                    decode(v_action,'I',:new.WG_STRT_DATE,:old.WG_STRT_DATE),
                    decode(v_action,'I',:new.SITE_STRT_DATE,:old.SITE_STRT_DATE),
                    decode(v_action,'I',:new.VOICE_MAIL_BOX,:old.VOICE_MAIL_BOX),
                    decode(v_action,'I',:new.LOCAL_LOGIN,:old.LOCAL_LOGIN),
                    decode(v_action,'I',:new.LOCAL_PASSWORD,:old.LOCAL_PASSWORD),
                    decode(v_action,'I',:new.ALLOW_PROXY,:old.ALLOW_PROXY),
                    decode(v_action,'I',:new.PRINTER,:old.PRINTER),
                    decode(v_action,'I',:new.ON_CALL_HW,:old.ON_CALL_HW),
                    decode(v_action,'I',:new.ON_CALL_SW,:old.ON_CALL_SW),
                    decode(v_action,'I',:new.CASE_THRESHOLD,:old.CASE_THRESHOLD),
                    decode(v_action,'I',:new.DEV,:old.DEV),
                    decode(v_action,'I',:new.EMPLOYEE2USER,:old.EMPLOYEE2USER),
                    decode(v_action,'I',:new.EMP_SUPVR2EMPLOYEE,:old.EMP_SUPVR2EMPLOYEE),
                    decode(v_action,'I',:new.SUPP_PERSON_OFF2SITE,:old.SUPP_PERSON_OFF2SITE),
                    decode(v_action,'I',:new.CC_LIST2BUG,:old.CC_LIST2BUG),
                    decode(v_action,'I',:new.EMPL_HRS2BIZ_CAL_HDR,:old.EMPL_HRS2BIZ_CAL_HDR),
                    decode(v_action,'I',:new.EMPLOYEE2CONTACT,:old.EMPLOYEE2CONTACT),
                    decode(v_action,'I',:new.X_DASHBOARD,:old.X_DASHBOARD),
                    decode(v_action,'I',:new.X_ERROR_CODE_MAINT,:old.X_ERROR_CODE_MAINT),
                    decode(v_action,'I',:new.X_ORDER_TYPES,:old.X_ORDER_TYPES),
                    decode(v_action,'I',:new.X_Q_MAINT,:old.X_Q_MAINT),
                    decode(v_action,'I',:new.X_SELECT_TRANS_PROF,:old.X_SELECT_TRANS_PROF),
                    decode(v_action,'I',:new.X_UPDATE_SET,:old.X_UPDATE_SET),
                    decode(v_action,'I',:new.X_ALLOW_SCRIPT,:old.X_ALLOW_SCRIPT),
                    decode(v_action,'I',:new.X_ALLOW_ROADSIDE,:old.X_ALLOW_ROADSIDE),
                    decode(v_action,'I',:new.SALUTATION,:old.SALUTATION),
                    decode(v_action,'I',:new.TITLE,:old.TITLE),
                    :old.OBJID,       --OBJID OF TABLE_EMPLOYEE
                    v_userid,         --OBJID OF TABLE_USER
                    SYSDATE,
                    v_osuser,
                    decode(v_action,'I','INSERT','U','UPDATE','D','DELETE'));
EXCEPTION
   WHEN OTHERS THEN
          insert_error_tab_proc ( 'Exception caught '||sqlerrm,
                                 '' ,
                                 'TRG_EMPLOYEE_BIUD');
END;
/