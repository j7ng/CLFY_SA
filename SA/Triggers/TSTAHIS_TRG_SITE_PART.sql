CREATE OR REPLACE TRIGGER sa.TSTAHIS_TRG_SITE_PART
BEFORE INSERT OR UPDATE OR DELETE ON sa.TABLE_SITE_PART
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
      INSERT INTO sa.TSTAHIS_TABLE_SITE_PART
                  (
OBJID,
INSTANCE_NAME,
SERIAL_NO,
S_SERIAL_NO,
INVOICE_NO,
SHIP_DATE,
INSTALL_DATE,
WARRANTY_DATE,
QUANTITY,
MDBK,
STATE_CODE,
STATE_VALUE,
MODIFIED,
LEVEL_TO_PART,
SELECTED_PRD,
PART_STATUS,
COMMENTS,
LEVEL_TO_BIN,
BIN_OBJID,
SITE_OBJID,
INST_OBJID,
DIR_SITE_OBJID,
MACHINE_ID,
SERVICE_END_DT,
DEV,
X_SERVICE_ID,
X_MIN,
X_PIN,
X_DEACT_REASON,
X_MIN_CHANGE_FLAG,
X_NOTIFY_CARRIER,
X_EXPIRE_DT,
X_ZIPCODE,
SITE_PART2PRODUCTBIN,
SITE_PART2SITE,
SITE_PART2SITE_PART,
SITE_PART2PART_INFO,
SITE_PART2PRIMARY,
SITE_PART2BACKUP,
ALL_SITE_PART2SITE,
SITE_PART2PART_DETAIL,
SITE_PART2X_NEW_PLAN,
SITE_PART2X_PLAN,
X_MSID,
X_REFURB_FLAG,
CMMTMNT_END_DT,
INSTANCE_ID,
SITE_PART_IND,
STATUS_DT,
X_ICCID,
X_ACTUAL_EXPIRE_DT,
                    SITE_PART_HIST2SITE_PART,
                    SITE_PART_HIS2USER,
                    X_CHANGE_DATE,
                    OSUSER,
                    TRIGGERING_RECORD_TYPE )
           VALUES ( sa.SEQ_TSTAHIS_SITE_PART.nextval,
decode(v_action,'I',:new.INSTANCE_NAME,:old.INSTANCE_NAME),
decode(v_action,'I',:new.SERIAL_NO,:old.SERIAL_NO),
decode(v_action,'I',:new.S_SERIAL_NO,:old.S_SERIAL_NO),
decode(v_action,'I',:new.INVOICE_NO,:old.INVOICE_NO),
decode(v_action,'I',:new.SHIP_DATE,:old.SHIP_DATE),
decode(v_action,'I',:new.INSTALL_DATE,:old.INSTALL_DATE),
decode(v_action,'I',:new.WARRANTY_DATE,:old.WARRANTY_DATE),
decode(v_action,'I',:new.QUANTITY,:old.QUANTITY),
decode(v_action,'I',:new.MDBK,:old.MDBK),
decode(v_action,'I',:new.STATE_CODE,:old.STATE_CODE),
decode(v_action,'I',:new.STATE_VALUE,:old.STATE_VALUE),
decode(v_action,'I',:new.MODIFIED,:old.MODIFIED),
decode(v_action,'I',:new.LEVEL_TO_PART,:old.LEVEL_TO_PART),
decode(v_action,'I',:new.SELECTED_PRD,:old.SELECTED_PRD),
decode(v_action,'I',:new.PART_STATUS,:old.PART_STATUS),
decode(v_action,'I',:new.COMMENTS,:old.COMMENTS),
decode(v_action,'I',:new.LEVEL_TO_BIN,:old.LEVEL_TO_BIN),
decode(v_action,'I',:new.BIN_OBJID,:old.BIN_OBJID),
decode(v_action,'I',:new.SITE_OBJID,:old.SITE_OBJID),
decode(v_action,'I',:new.INST_OBJID,:old.INST_OBJID),
decode(v_action,'I',:new.DIR_SITE_OBJID,:old.DIR_SITE_OBJID),
decode(v_action,'I',:new.MACHINE_ID,:old.MACHINE_ID),
decode(v_action,'I',:new.SERVICE_END_DT,:old.SERVICE_END_DT),
decode(v_action,'I',:new.DEV,:old.DEV),
decode(v_action,'I',:new.X_SERVICE_ID,:old.X_SERVICE_ID),
decode(v_action,'I',:new.X_MIN,:old.X_MIN),
decode(v_action,'I',:new.X_PIN,:old.X_PIN),
decode(v_action,'I',:new.X_DEACT_REASON,:old.X_DEACT_REASON),
decode(v_action,'I',:new.X_MIN_CHANGE_FLAG,:old.X_MIN_CHANGE_FLAG),
decode(v_action,'I',:new.X_NOTIFY_CARRIER,:old.X_NOTIFY_CARRIER),
decode(v_action,'I',:new.X_EXPIRE_DT,:old.X_EXPIRE_DT),
decode(v_action,'I',:new.X_ZIPCODE,:old.X_ZIPCODE),
decode(v_action,'I',:new.SITE_PART2PRODUCTBIN,:old.SITE_PART2PRODUCTBIN),
decode(v_action,'I',:new.SITE_PART2SITE,:old.SITE_PART2SITE),
decode(v_action,'I',:new.SITE_PART2SITE_PART,:old.SITE_PART2SITE_PART),
decode(v_action,'I',:new.SITE_PART2PART_INFO,:old.SITE_PART2PART_INFO),
decode(v_action,'I',:new.SITE_PART2PRIMARY,:old.SITE_PART2PRIMARY),
decode(v_action,'I',:new.SITE_PART2BACKUP,:old.SITE_PART2BACKUP),
decode(v_action,'I',:new.ALL_SITE_PART2SITE,:old.ALL_SITE_PART2SITE),
decode(v_action,'I',:new.SITE_PART2PART_DETAIL,:old.SITE_PART2PART_DETAIL),
decode(v_action,'I',:new.SITE_PART2X_NEW_PLAN,:old.SITE_PART2X_NEW_PLAN),
decode(v_action,'I',:new.SITE_PART2X_PLAN,:old.SITE_PART2X_PLAN),
decode(v_action,'I',:new.X_MSID,:old.X_MSID),
decode(v_action,'I',:new.X_REFURB_FLAG,:old.X_REFURB_FLAG),
decode(v_action,'I',:new.CMMTMNT_END_DT,:old.CMMTMNT_END_DT),
decode(v_action,'I',:new.INSTANCE_ID,:old.INSTANCE_ID),
decode(v_action,'I',:new.SITE_PART_IND,:old.SITE_PART_IND),
decode(v_action,'I',:new.STATUS_DT,:old.STATUS_DT),
decode(v_action,'I',:new.X_ICCID,:old.X_ICCID),
decode(v_action,'I',:new.X_ACTUAL_EXPIRE_DT,:old.X_ACTUAL_EXPIRE_DT),
					 decode(v_action,'I',:new.OBJID,:old.OBJID), --OBJID OF TABLE_SITE_PART
                    v_userid,         --OBJID OF TABLE_USER
                    SYSDATE,
                    v_osuser,
                    decode(v_action,'I','INSERT','U','UPDATE','D','DELETE'));
EXCEPTION
   WHEN OTHERS THEN
          insert_error_tab_proc ( 'Exception caught '||sqlerrm,
                                 '' ,
                                 'TSTAHIS_TRG_SITE_PART');
END;
/