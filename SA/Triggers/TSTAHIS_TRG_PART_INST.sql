CREATE OR REPLACE TRIGGER sa.TSTAHIS_TRG_PART_INST
BEFORE INSERT OR UPDATE OR DELETE ON sa.TABLE_PART_INST
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
      INSERT INTO sa.TSTAHIS_TABLE_PART_INST
                  (
OBJID,
PART_GOOD_QTY,
PART_BAD_QTY,
PART_SERIAL_NO,
PART_MOD,
PART_BIN,
LAST_PI_DATE,
PI_TAG_NO,
LAST_CYCLE_CT,
NEXT_CYCLE_CT,
LAST_MOD_TIME,
LAST_TRANS_TIME,
TRANSACTION_ID,
DATE_IN_SERV,
WARR_END_DATE,
REPAIR_DATE,
PART_STATUS,
PICK_REQUEST,
GOOD_RES_QTY,
BAD_RES_QTY,
DEV,
X_INSERT_DATE,
X_SEQUENCE,
X_CREATION_DATE,
X_PO_NUM,
X_RED_CODE,
X_DOMAIN,
X_DEACTIVATION_FLAG,
X_REACTIVATION_FLAG,
X_COOL_END_DATE,
X_PART_INST_STATUS,
X_NPA,
X_NXX,
X_EXT,
X_ORDER_NUMBER,
PART_INST2INV_BIN,
N_PART_INST2PART_MOD,
FULFILL2DEMAND_DTL,
PART_INST2X_PERS,
PART_INST2X_NEW_PERS,
PART_INST2CARRIER_MKT,
CREATED_BY2USER,
STATUS2X_CODE_TABLE,
PART_TO_ESN2PART_INST,
X_PART_INST2SITE_PART,
X_LD_PROCESSED,
DTL2PART_INST,
ECO_NEW2PART_INST,
HDR_IND,
X_MSID,
X_PART_INST2CONTACT,
X_ICCID,
X_CLEAR_TANK,
X_PORT_IN,
X_HEX_SERIAL_NO,
X_PARENT_PART_SERIAL_NO,
                    PART_INST_HIST2PART_INST,
                    PART_INST_HIS2USER,
                    X_CHANGE_DATE,
                    OSUSER,
                    TRIGGERING_RECORD_TYPE )
           VALUES ( sa.SEQ_TSTAHIS_PART_INST.nextval,
decode(v_action,'I',:new.PART_GOOD_QTY,:old.PART_GOOD_QTY),
decode(v_action,'I',:new.PART_BAD_QTY,:old.PART_BAD_QTY),
decode(v_action,'I',:new.PART_SERIAL_NO,:old.PART_SERIAL_NO),
decode(v_action,'I',:new.PART_MOD,:old.PART_MOD),
decode(v_action,'I',:new.PART_BIN,:old.PART_BIN),
decode(v_action,'I',:new.LAST_PI_DATE,:old.LAST_PI_DATE),
decode(v_action,'I',:new.PI_TAG_NO,:old.PI_TAG_NO),
decode(v_action,'I',:new.LAST_CYCLE_CT,:old.LAST_CYCLE_CT),
decode(v_action,'I',:new.NEXT_CYCLE_CT,:old.NEXT_CYCLE_CT),
decode(v_action,'I',:new.LAST_MOD_TIME,:old.LAST_MOD_TIME),
decode(v_action,'I',:new.LAST_TRANS_TIME,:old.LAST_TRANS_TIME),
decode(v_action,'I',:new.TRANSACTION_ID,:old.TRANSACTION_ID),
decode(v_action,'I',:new.DATE_IN_SERV,:old.DATE_IN_SERV),
decode(v_action,'I',:new.WARR_END_DATE,:old.WARR_END_DATE),
decode(v_action,'I',:new.REPAIR_DATE,:old.REPAIR_DATE),
decode(v_action,'I',:new.PART_STATUS,:old.PART_STATUS),
decode(v_action,'I',:new.PICK_REQUEST,:old.PICK_REQUEST),
decode(v_action,'I',:new.GOOD_RES_QTY,:old.GOOD_RES_QTY),
decode(v_action,'I',:new.BAD_RES_QTY,:old.BAD_RES_QTY),
decode(v_action,'I',:new.DEV,:old.DEV),
decode(v_action,'I',:new.X_INSERT_DATE,:old.X_INSERT_DATE),
decode(v_action,'I',:new.X_SEQUENCE,:old.X_SEQUENCE),
decode(v_action,'I',:new.X_CREATION_DATE,:old.X_CREATION_DATE),
decode(v_action,'I',:new.X_PO_NUM,:old.X_PO_NUM),
decode(v_action,'I',:new.X_RED_CODE,:old.X_RED_CODE),
decode(v_action,'I',:new.X_DOMAIN,:old.X_DOMAIN),
decode(v_action,'I',:new.X_DEACTIVATION_FLAG,:old.X_DEACTIVATION_FLAG),
decode(v_action,'I',:new.X_REACTIVATION_FLAG,:old.X_REACTIVATION_FLAG),
decode(v_action,'I',:new.X_COOL_END_DATE,:old.X_COOL_END_DATE),
decode(v_action,'I',:new.X_PART_INST_STATUS,:old.X_PART_INST_STATUS),
decode(v_action,'I',:new.X_NPA,:old.X_NPA),
decode(v_action,'I',:new.X_NXX,:old.X_NXX),
decode(v_action,'I',:new.X_EXT,:old.X_EXT),
decode(v_action,'I',:new.X_ORDER_NUMBER,:old.X_ORDER_NUMBER),
decode(v_action,'I',:new.PART_INST2INV_BIN,:old.PART_INST2INV_BIN),
decode(v_action,'I',:new.N_PART_INST2PART_MOD,:old.N_PART_INST2PART_MOD),
decode(v_action,'I',:new.FULFILL2DEMAND_DTL,:old.FULFILL2DEMAND_DTL),
decode(v_action,'I',:new.PART_INST2X_PERS,:old.PART_INST2X_PERS),
decode(v_action,'I',:new.PART_INST2X_NEW_PERS,:old.PART_INST2X_NEW_PERS),
decode(v_action,'I',:new.PART_INST2CARRIER_MKT,:old.PART_INST2CARRIER_MKT),
decode(v_action,'I',:new.CREATED_BY2USER,:old.CREATED_BY2USER),
decode(v_action,'I',:new.STATUS2X_CODE_TABLE,:old.STATUS2X_CODE_TABLE),
decode(v_action,'I',:new.PART_TO_ESN2PART_INST,:old.PART_TO_ESN2PART_INST),
decode(v_action,'I',:new.X_PART_INST2SITE_PART,:old.X_PART_INST2SITE_PART),
decode(v_action,'I',:new.X_LD_PROCESSED,:old.X_LD_PROCESSED),
decode(v_action,'I',:new.DTL2PART_INST,:old.DTL2PART_INST),
decode(v_action,'I',:new.ECO_NEW2PART_INST,:old.ECO_NEW2PART_INST),
decode(v_action,'I',:new.HDR_IND,:old.HDR_IND),
decode(v_action,'I',:new.X_MSID,:old.X_MSID),
decode(v_action,'I',:new.X_PART_INST2CONTACT,:old.X_PART_INST2CONTACT),
decode(v_action,'I',:new.X_ICCID,:old.X_ICCID),
decode(v_action,'I',:new.X_CLEAR_TANK,:old.X_CLEAR_TANK),
decode(v_action,'I',:new.X_PORT_IN,:old.X_PORT_IN),
decode(v_action,'I',:new.X_HEX_SERIAL_NO,:old.X_HEX_SERIAL_NO),
decode(v_action,'I',:new.X_PARENT_PART_SERIAL_NO,:old.X_PARENT_PART_SERIAL_NO),
					 decode(v_action,'I',:new.OBJID,:old.OBJID), --OBJID OF TABLE_PART_INST
                    v_userid,         --OBJID OF TABLE_USER
                    SYSDATE,
                    v_osuser,
                    decode(v_action,'I','INSERT','U','UPDATE','D','DELETE'));
EXCEPTION
   WHEN OTHERS THEN
          insert_error_tab_proc ( 'Exception caught '||sqlerrm,
                                 '' ,
                                 'TSTAHIS_TRG_PART_INST');
END;
/