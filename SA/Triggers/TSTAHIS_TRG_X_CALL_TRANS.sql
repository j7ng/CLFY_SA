CREATE OR REPLACE TRIGGER sa.TSTAHIS_TRG_X_CALL_TRANS
BEFORE INSERT OR UPDATE OR DELETE ON sa.TABLE_X_CALL_TRANS
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
      INSERT INTO sa.TSTAHIS_TABLE_X_CALL_TRANS
                  ( OBJID,
CALL_TRANS2SITE_PART,
X_ACTION_TYPE,
X_CALL_TRANS2CARRIER,
X_CALL_TRANS2DEALER,
X_CALL_TRANS2USER,
X_LINE_STATUS,
X_MIN,
X_SERVICE_ID,
X_SOURCESYSTEM,
X_TRANSACT_DATE,
X_TOTAL_UNITS,
X_ACTION_TEXT,
X_REASON,
X_RESULT,
X_SUB_SOURCESYSTEM,
X_ICCID,
X_OTA_REQ_TYPE,
X_OTA_TYPE,
X_CALL_TRANS2X_OTA_CODE_HIST,
X_NEW_DUE_DATE,
UPDATE_STAMP,
                    X_CALL_TRANS_HIST2X_CALL_TRANS,
                    X_CALL_TRANS_HIS2USER,
                    X_CHANGE_DATE,
                    OSUSER,
                    TRIGGERING_RECORD_TYPE )
           VALUES ( sa.SEQ_TSTAHIS_X_CALL_TRANS.nextval,
decode(v_action,'I',:new.CALL_TRANS2SITE_PART,:old.CALL_TRANS2SITE_PART),
decode(v_action,'I',:new.X_ACTION_TYPE,:old.X_ACTION_TYPE),
decode(v_action,'I',:new.X_CALL_TRANS2CARRIER,:old.X_CALL_TRANS2CARRIER),
decode(v_action,'I',:new.X_CALL_TRANS2DEALER,:old.X_CALL_TRANS2DEALER),
decode(v_action,'I',:new.X_CALL_TRANS2USER,:old.X_CALL_TRANS2USER),
decode(v_action,'I',:new.X_LINE_STATUS,:old.X_LINE_STATUS),
decode(v_action,'I',:new.X_MIN,:old.X_MIN),
decode(v_action,'I',:new.X_SERVICE_ID,:old.X_SERVICE_ID),
decode(v_action,'I',:new.X_SOURCESYSTEM,:old.X_SOURCESYSTEM),
decode(v_action,'I',:new.X_TRANSACT_DATE,:old.X_TRANSACT_DATE),
decode(v_action,'I',:new.X_TOTAL_UNITS,:old.X_TOTAL_UNITS),
decode(v_action,'I',:new.X_ACTION_TEXT,:old.X_ACTION_TEXT),
decode(v_action,'I',:new.X_REASON,:old.X_REASON),
decode(v_action,'I',:new.X_RESULT,:old.X_RESULT),
decode(v_action,'I',:new.X_SUB_SOURCESYSTEM,:old.X_SUB_SOURCESYSTEM),
decode(v_action,'I',:new.X_ICCID,:old.X_ICCID),
decode(v_action,'I',:new.X_OTA_REQ_TYPE,:old.X_OTA_REQ_TYPE),
decode(v_action,'I',:new.X_OTA_TYPE,:old.X_OTA_TYPE),
decode(v_action,'I',:new.X_CALL_TRANS2X_OTA_CODE_HIST,:old.X_CALL_TRANS2X_OTA_CODE_HIST),
decode(v_action,'I',:new.X_NEW_DUE_DATE,:old.X_NEW_DUE_DATE),
decode(v_action,'I',:new.UPDATE_STAMP,:old.UPDATE_STAMP),
                     decode(v_action,'I',:new.OBJID,:old.OBJID), --OBJID OF TABLE_X_CALL_TRANS
                    v_userid,         --OBJID OF TABLE_USER
                    SYSDATE,
                    v_osuser,
                    decode(v_action,'I','INSERT','U','UPDATE','D','DELETE'));

EXCEPTION
   WHEN OTHERS THEN
          insert_error_tab_proc ( 'Exception caught '||sqlerrm,
                                 '' ,
                                 'TSTAHIS_TRG_X_CALL_TRANS');
END;
/