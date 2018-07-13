CREATE OR REPLACE TRIGGER sa."TRG_X_PARAM_HIST_BIUD"
BEFORE INSERT OR UPDATE OR DELETE ON sa.TABLE_X_PARAMETERS
REFERENCING NEW AS NEW OLD AS OLD
FOR EACH ROW
DECLARE
 v_action VARCHAR2(1);
 v_osuser  varchar2(50);
 v_userid varchar2(30);
 v_text      VARCHAR2(4000);
 common_text varchar2(70) := 'Tracfone Apps Configuration Parameter ';
 dtNtime varchar2(20):= to_char(sysdate,'DD-MON-RR HH24:MI:SS');
 v_email_req_flag varchar2(1):= 'N';

BEGIN
      IF INSERTING  THEN
         v_action := 'I' ;
      ELSIF  UPDATING THEN
         v_action := 'U' ;
      ELSE
         v_action := 'D' ;
      END IF;


               select 'Parameter '||:old.X_PARAM_NAME||' Changed from '||:old.X_PARAM_VALUE||' to '
  ||:new.X_PARAM_VALUE || ' AT '|| dtNtime
               into v_text
               from dual;

               v_email_req_flag := 'Y';


BEGIN
      select objid,
             sys_context('USERENV','OS_USER')
      into  v_userid,
            v_osuser
      from table_user where upper(login_name) = upper('user');
EXCEPTION
  WHEN OTHERS THEN
         select sys_context('USERENV','SESSION_USERID'),sys_context('USERENV','OS_USER')
 into  v_userid,v_osuser
         from dual;

END;


      INSERT INTO sa.X_PARAMETERS_HIST
                  (OBJID,
   DEV,
   X_PARAM_NAME,
   X_PARAM_VALUE,
   X_NOTES,
   X_PARAM_HIST2PARAM,
   X_TEXT,
   X_PARAM_HIST2USER,
   X_CHANGE_DATE,
   OSUSER,
   EMAIL_REQUIRE_FLAG,
   EMAIL_DATE,
   TRIGGERING_RECORD_TYPE)
           VALUES ( SEQU_X_PARAM_HIST.nextval,
                    decode(v_action,'I',:new.DEV,:old.DEV),
                    decode(v_action,'I',:new.X_PARAM_NAME,:old.X_PARAM_NAME),
                    decode(v_action,'I',:new.X_PARAM_VALUE,:old.X_PARAM_VALUE),
                    decode(v_action,'I',:new.X_NOTES,:old.X_NOTES),
                    decode(v_action,'I',:old.OBJID),
                    v_text,
                    v_userid,
                    sysdate,
                    v_osuser,
                    'Y',
                    null,
                    decode(v_action,'I','INSERT','U','UPDATE','D','DELETE')) ;
EXCEPTION
   WHEN OTHERS THEN
          insert_error_tab_proc ( 'Exception caught '||sqlerrm,
                                 '' ,
                                 'TRG_X_PARAMETER_BIUD');
END;
/