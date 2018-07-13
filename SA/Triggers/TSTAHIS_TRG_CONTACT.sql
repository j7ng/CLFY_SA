CREATE OR REPLACE TRIGGER sa.TSTAHIS_TRG_CONTACT
BEFORE INSERT OR UPDATE OR DELETE ON sa.TABLE_CONTACT
REFERENCING NEW AS NEW OLD AS OLD
FOR EACH ROW
DISABLE DECLARE
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

  select username, osuser
 into  v_userid,
            v_osuser
from v$session s
where s.audsid = userenv('sessionid');
      INSERT INTO sa.TSTAHIS_TABLE_CONTACT
                  ( OBJID,
FIRST_NAME,
S_FIRST_NAME,
LAST_NAME,
S_LAST_NAME,
PHONE,
FAX_NUMBER,
E_MAIL,
MAIL_STOP,
EXPERTISE_LEV,
TITLE,
HOURS,
SALUTATION,
MDBK,
STATE_CODE,
STATE_VALUE,
ADDRESS_1,
ADDRESS_2,
CITY,
STATE,
ZIPCODE,
COUNTRY,
STATUS,
ARCH_IND,
ALERT_IND,
DEV,
CALLER2USER,
CONTACT2X_CARRIER,
X_CUST_ID,
X_DATEOFBIRTH,
X_GENDER,
X_MIDDLE_INITIAL,
X_MOBILENUMBER,
X_NO_ADDRESS_FLAG,
X_NO_NAME_FLAG,
X_PAGERNUMBER,
X_SS_NUMBER,
X_NO_PHONE_FLAG,
UPDATE_STAMP,
X_NEW_ESN,
X_EMAIL_STATUS,
X_HTML_OK,
X_EMAIL_PROMPT_COUNT,
X_PHONE_PROMPT_COUNT,
X_ROADSIDE_STATUS,
X_AUTOPAY_UPDATE_FLAG,
MOBILE_PHONE,
X_PIN,
X_SERV_DT_REMIND_FLAG,
X_SIGN_REQD,
X_SPL_OFFER_FLG,
X_SPL_PROG_FLG,
                    CONTACT_HIST2CONTACT,
                    CONTACT_HIS2USER,
                    X_CHANGE_DATE,
                    OSUSER,
                    TRIGGERING_RECORD_TYPE )
           VALUES ( sa.SEQ_TSTAHIS_CONTACT.nextval,
decode(v_action,'I',:new.FIRST_NAME,:old.FIRST_NAME),
decode(v_action,'I',:new.S_FIRST_NAME,:old.S_FIRST_NAME),
decode(v_action,'I',:new.LAST_NAME,:old.LAST_NAME),
decode(v_action,'I',:new.S_LAST_NAME,:old.S_LAST_NAME),
decode(v_action,'I',:new.PHONE,:old.PHONE),
decode(v_action,'I',:new.FAX_NUMBER,:old.FAX_NUMBER),
decode(v_action,'I',:new.E_MAIL,:old.E_MAIL),
decode(v_action,'I',:new.MAIL_STOP,:old.MAIL_STOP),
decode(v_action,'I',:new.EXPERTISE_LEV,:old.EXPERTISE_LEV),
decode(v_action,'I',:new.TITLE,:old.TITLE),
decode(v_action,'I',:new.HOURS,:old.HOURS),
decode(v_action,'I',:new.SALUTATION,:old.SALUTATION),
decode(v_action,'I',:new.MDBK,:old.MDBK),
decode(v_action,'I',:new.STATE_CODE,:old.STATE_CODE),
decode(v_action,'I',:new.STATE_VALUE,:old.STATE_VALUE),
decode(v_action,'I',:new.ADDRESS_1,:old.ADDRESS_1),
decode(v_action,'I',:new.ADDRESS_2,:old.ADDRESS_2),
decode(v_action,'I',:new.CITY,:old.CITY),
decode(v_action,'I',:new.STATE,:old.STATE),
decode(v_action,'I',:new.ZIPCODE,:old.ZIPCODE),
decode(v_action,'I',:new.COUNTRY,:old.COUNTRY),
decode(v_action,'I',:new.STATUS,:old.STATUS),
decode(v_action,'I',:new.ARCH_IND,:old.ARCH_IND),
decode(v_action,'I',:new.ALERT_IND,:old.ALERT_IND),
decode(v_action,'I',:new.DEV,:old.DEV),
decode(v_action,'I',:new.CALLER2USER,:old.CALLER2USER),
decode(v_action,'I',:new.CONTACT2X_CARRIER,:old.CONTACT2X_CARRIER),
decode(v_action,'I',:new.X_CUST_ID,:old.X_CUST_ID),
decode(v_action,'I',:new.X_DATEOFBIRTH,:old.X_DATEOFBIRTH),
decode(v_action,'I',:new.X_GENDER,:old.X_GENDER),
decode(v_action,'I',:new.X_MIDDLE_INITIAL,:old.X_MIDDLE_INITIAL),
decode(v_action,'I',:new.X_MOBILENUMBER,:old.X_MOBILENUMBER),
decode(v_action,'I',:new.X_NO_ADDRESS_FLAG,:old.X_NO_ADDRESS_FLAG),
decode(v_action,'I',:new.X_NO_NAME_FLAG,:old.X_NO_NAME_FLAG),
decode(v_action,'I',:new.X_PAGERNUMBER,:old.X_PAGERNUMBER),
decode(v_action,'I',:new.X_SS_NUMBER,:old.X_SS_NUMBER),
decode(v_action,'I',:new.X_NO_PHONE_FLAG,:old.X_NO_PHONE_FLAG),
decode(v_action,'I',:new.UPDATE_STAMP,:old.UPDATE_STAMP),
decode(v_action,'I',:new.X_NEW_ESN,:old.X_NEW_ESN),
decode(v_action,'I',:new.X_EMAIL_STATUS,:old.X_EMAIL_STATUS),
decode(v_action,'I',:new.X_HTML_OK,:old.X_HTML_OK),
decode(v_action,'I',:new.X_EMAIL_PROMPT_COUNT,:old.X_EMAIL_PROMPT_COUNT),
decode(v_action,'I',:new.X_PHONE_PROMPT_COUNT,:old.X_PHONE_PROMPT_COUNT),
decode(v_action,'I',:new.X_ROADSIDE_STATUS,:old.X_ROADSIDE_STATUS),
decode(v_action,'I',:new.X_AUTOPAY_UPDATE_FLAG,:old.X_AUTOPAY_UPDATE_FLAG),
decode(v_action,'I',:new.MOBILE_PHONE,:old.MOBILE_PHONE),
decode(v_action,'I',:new.X_PIN,:old.X_PIN),
decode(v_action,'I',:new.X_SERV_DT_REMIND_FLAG,:old.X_SERV_DT_REMIND_FLAG),
decode(v_action,'I',:new.X_SIGN_REQD,:old.X_SIGN_REQD),
decode(v_action,'I',:new.X_SPL_OFFER_FLG,:old.X_SPL_OFFER_FLG),
decode(v_action,'I',:new.X_SPL_PROG_FLG,:old.X_SPL_PROG_FLG),
					 decode(v_action,'I',:new.OBJID,:old.OBJID), --OBJID OF TABLE_CONTACT
                    v_userid,         --OBJID OF TABLE_USER
                    SYSDATE,
                    v_osuser,
                    decode(v_action,'I','INSERT','U','UPDATE','D','DELETE'));
EXCEPTION
   WHEN OTHERS THEN
          insert_error_tab_proc ( 'Exception caught '||sqlerrm,
                                 '' ,
                                 'TSTAHIS_TRG_CONTACT');
END;
/