CREATE OR REPLACE TRIGGER sa.TSTAHIS_TRG_X_ZERO_OUT_MAX
BEFORE INSERT OR UPDATE OR DELETE ON sa.TABLE_X_ZERO_OUT_MAX
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
      INSERT INTO sa.TSTAHIS_TABLE_X_ZERO_OUT_MAX
                  ( OBJID,
X_ESN,
X_REQ_DATE_TIME,
X_REAC_DATE_TIME,
X_MAX_DATE_TIME,
X_SOURCESYSTEM,
X_DEPOSIT,
X_TRANSACTION_TYPE,
X_ZERO_OUT2USER,
X_SMS_DEPOSIT,
X_DATA_DEPOSIT,
X_MTT_FLAG,
                    X_ZO_MAX_HIST2X_ZERO_OUT_MAX,
                    X_ZERO_OUT_MAX_HIS2USER,
                    X_CHANGE_DATE,
                    OSUSER,
                    TRIGGERING_RECORD_TYPE )
           VALUES ( sa.SEQ_TSTAHIS_X_ZERO_OUT_MAX.nextval,
decode(v_action,'I',:new.X_ESN,:old.X_ESN),
decode(v_action,'I',:new.X_REQ_DATE_TIME,:old.X_REQ_DATE_TIME),
decode(v_action,'I',:new.X_REAC_DATE_TIME,:old.X_REAC_DATE_TIME),
decode(v_action,'I',:new.X_MAX_DATE_TIME,:old.X_MAX_DATE_TIME),
decode(v_action,'I',:new.X_SOURCESYSTEM,:old.X_SOURCESYSTEM),
decode(v_action,'I',:new.X_DEPOSIT,:old.X_DEPOSIT),
decode(v_action,'I',:new.X_TRANSACTION_TYPE,:old.X_TRANSACTION_TYPE),
decode(v_action,'I',:new.X_ZERO_OUT2USER,:old.X_ZERO_OUT2USER),
decode(v_action,'I',:new.X_SMS_DEPOSIT,:old.X_SMS_DEPOSIT),
decode(v_action,'I',:new.X_DATA_DEPOSIT,:old.X_DATA_DEPOSIT),
decode(v_action,'I',:new.X_MTT_FLAG,:old.X_MTT_FLAG),
                     decode(v_action,'I',:new.OBJID,:old.OBJID), --OBJID OF TABLE_X_ZERO_OUT_MAX
                    v_userid,         --OBJID OF TABLE_USER
                    SYSDATE,
                    v_osuser,
                    decode(v_action,'I','INSERT','U','UPDATE','D','DELETE'));

EXCEPTION
   WHEN OTHERS THEN
          insert_error_tab_proc ( 'Exception caught '||sqlerrm,
                                 '' ,
                                 'TSTAHIS_TRG_X_ZERO_OUT_MAX');
END;
/