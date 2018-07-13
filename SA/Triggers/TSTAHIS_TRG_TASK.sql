CREATE OR REPLACE TRIGGER sa.TSTAHIS_TRG_TASK
BEFORE INSERT OR UPDATE OR DELETE ON sa.TABLE_TASK
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
      INSERT INTO sa.TSTAHIS_TABLE_TASK
                  ( OBJID,
TITLE,
S_TITLE,
NOTES,
START_DATE,
DUE_DATE,
COMP_DATE,
ACTIVE,
TASK_ID,
S_TASK_ID,
ARCH_IND,
DEV,
TASK_STS2GBST_ELM,
TASK_PRIORITY2GBST_ELM,
TYPE_TASK2GBST_ELM,
SM_TASK2OPPORTUNITY,
TASK_ORIGINATOR2USER,
TASK_OWNER2USER,
TASK2CONTACT,
TASK_GEN2CLS_FACTORY,
TASK_FOR2BUS_ORG,
TASK_STATE2CONDITION,
TASK_WIP2WIPBIN,
TASK_CURRQ2QUEUE,
TASK_PREVQ2QUEUE,
SM_TASK2CONTRACT,
TASK2LEAD,
TASK2LIT_REQ,
TASK2TASK_DESC,
UPDATE_STAMP,
X_ACCOUNT_NUM,
X_ACTIVATION_TIMEFRAME,
X_CURRENT_METHOD,
X_EXPEDITE,
X_FAX_FILE,
X_ORIGINAL_METHOD,
X_QUEUED_FLAG,
X_TASK2SITE_PART,
X_TASK2X_CALL_TRANS,
X_TASK2X_ORDER_TYPE,
X_TASK2X_TOPP_ERR_CODES,
X_TRANS_LOGIN,
X_RATE_PLAN,
X_OTA_TYPE,
                    TASK_HIST2TASK,
                    TASK_HIS2USER,
                    X_CHANGE_DATE,
                    OSUSER,
                    TRIGGERING_RECORD_TYPE )
           VALUES ( sa.SEQ_TSTAHIS_TASK.nextval,
decode(v_action,'I',:new.TITLE,:old.TITLE),
decode(v_action,'I',:new.S_TITLE,:old.S_TITLE),
'NOTES',--decode(v_action,'I',:new.NOTES,:old.NOTES),
decode(v_action,'I',:new.START_DATE,:old.START_DATE),
decode(v_action,'I',:new.DUE_DATE,:old.DUE_DATE),
decode(v_action,'I',:new.COMP_DATE,:old.COMP_DATE),
decode(v_action,'I',:new.ACTIVE,:old.ACTIVE),
decode(v_action,'I',:new.TASK_ID,:old.TASK_ID),
decode(v_action,'I',:new.S_TASK_ID,:old.S_TASK_ID),
decode(v_action,'I',:new.ARCH_IND,:old.ARCH_IND),
decode(v_action,'I',:new.DEV,:old.DEV),
decode(v_action,'I',:new.TASK_STS2GBST_ELM,:old.TASK_STS2GBST_ELM),
decode(v_action,'I',:new.TASK_PRIORITY2GBST_ELM,:old.TASK_PRIORITY2GBST_ELM),
decode(v_action,'I',:new.TYPE_TASK2GBST_ELM,:old.TYPE_TASK2GBST_ELM),
decode(v_action,'I',:new.SM_TASK2OPPORTUNITY,:old.SM_TASK2OPPORTUNITY),
decode(v_action,'I',:new.TASK_ORIGINATOR2USER,:old.TASK_ORIGINATOR2USER),
decode(v_action,'I',:new.TASK_OWNER2USER,:old.TASK_OWNER2USER),
decode(v_action,'I',:new.TASK2CONTACT,:old.TASK2CONTACT),
decode(v_action,'I',:new.TASK_GEN2CLS_FACTORY,:old.TASK_GEN2CLS_FACTORY),
decode(v_action,'I',:new.TASK_FOR2BUS_ORG,:old.TASK_FOR2BUS_ORG),
decode(v_action,'I',:new.TASK_STATE2CONDITION,:old.TASK_STATE2CONDITION),
decode(v_action,'I',:new.TASK_WIP2WIPBIN,:old.TASK_WIP2WIPBIN),
decode(v_action,'I',:new.TASK_CURRQ2QUEUE,:old.TASK_CURRQ2QUEUE),
decode(v_action,'I',:new.TASK_PREVQ2QUEUE,:old.TASK_PREVQ2QUEUE),
decode(v_action,'I',:new.SM_TASK2CONTRACT,:old.SM_TASK2CONTRACT),
decode(v_action,'I',:new.TASK2LEAD,:old.TASK2LEAD),
decode(v_action,'I',:new.TASK2LIT_REQ,:old.TASK2LIT_REQ),
decode(v_action,'I',:new.TASK2TASK_DESC,:old.TASK2TASK_DESC),
decode(v_action,'I',:new.UPDATE_STAMP,:old.UPDATE_STAMP),
decode(v_action,'I',:new.X_ACCOUNT_NUM,:old.X_ACCOUNT_NUM),
decode(v_action,'I',:new.X_ACTIVATION_TIMEFRAME,:old.X_ACTIVATION_TIMEFRAME),
decode(v_action,'I',:new.X_CURRENT_METHOD,:old.X_CURRENT_METHOD),
decode(v_action,'I',:new.X_EXPEDITE,:old.X_EXPEDITE),
decode(v_action,'I',:new.X_FAX_FILE,:old.X_FAX_FILE),
decode(v_action,'I',:new.X_ORIGINAL_METHOD,:old.X_ORIGINAL_METHOD),
decode(v_action,'I',:new.X_QUEUED_FLAG,:old.X_QUEUED_FLAG),
decode(v_action,'I',:new.X_TASK2SITE_PART,:old.X_TASK2SITE_PART),
decode(v_action,'I',:new.X_TASK2X_CALL_TRANS,:old.X_TASK2X_CALL_TRANS),
decode(v_action,'I',:new.X_TASK2X_ORDER_TYPE,:old.X_TASK2X_ORDER_TYPE),
decode(v_action,'I',:new.X_TASK2X_TOPP_ERR_CODES,:old.X_TASK2X_TOPP_ERR_CODES),
decode(v_action,'I',:new.X_TRANS_LOGIN,:old.X_TRANS_LOGIN),
decode(v_action,'I',:new.X_RATE_PLAN,:old.X_RATE_PLAN),
decode(v_action,'I',:new.X_OTA_TYPE,:old.X_OTA_TYPE),
                     decode(v_action,'I',:new.OBJID,:old.OBJID), --OBJID OF TABLE_TASK
                    v_userid,         --OBJID OF TABLE_USER
                    SYSDATE,
                    v_osuser,
                    decode(v_action,'I','INSERT','U','UPDATE','D','DELETE'));
EXCEPTION
   WHEN OTHERS THEN
          insert_error_tab_proc ( 'Exception caught '||sqlerrm,
                                 '' ,
                                 'TSTAHIS_TRG_TASK');
END;
/