CREATE OR REPLACE TRIGGER sa.TSTAHIS_TRG_X_SIM_INV
BEFORE INSERT OR UPDATE OR DELETE ON sa.TABLE_X_SIM_INV
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
      INSERT INTO sa.TSTAHIS_TABLE_X_SIM_INV
                  ( OBJID,
X_SIM_SERIAL_NO,
X_SIM_INV_STATUS,
X_SIM_MNC,
X_INV_INSERT_DATE,
X_LAST_SHIP_DATE,
X_SIM_PO_NUMBER,
X_SIM_ORDER_NUMBER,
X_LAST_UPDATE_DATE,
X_SIM_INV2PART_MOD,
X_CREATED_BY2USER,
X_SIM_STATUS2X_CODE_TABLE,
X_SIM_INV2INV_BIN,
X_PIN1,
X_PIN2,
X_PUK1,
X_PUK2,
X_QTY,
                    X_SIM_INV_HIST2X_SIM_INV,
                    X_SIM_INV_HIS2USER,
                    X_CHANGE_DATE,
                    OSUSER,
                    TRIGGERING_RECORD_TYPE )
           VALUES ( sa.SEQ_TSTAHIS_X_SIM_INV.nextval,
decode(v_action,'I',:new.X_SIM_SERIAL_NO,:old.X_SIM_SERIAL_NO),
decode(v_action,'I',:new.X_SIM_INV_STATUS,:old.X_SIM_INV_STATUS),
decode(v_action,'I',:new.X_SIM_MNC,:old.X_SIM_MNC),
decode(v_action,'I',:new.X_INV_INSERT_DATE,:old.X_INV_INSERT_DATE),
decode(v_action,'I',:new.X_LAST_SHIP_DATE,:old.X_LAST_SHIP_DATE),
decode(v_action,'I',:new.X_SIM_PO_NUMBER,:old.X_SIM_PO_NUMBER),
decode(v_action,'I',:new.X_SIM_ORDER_NUMBER,:old.X_SIM_ORDER_NUMBER),
decode(v_action,'I',:new.X_LAST_UPDATE_DATE,:old.X_LAST_UPDATE_DATE),
decode(v_action,'I',:new.X_SIM_INV2PART_MOD,:old.X_SIM_INV2PART_MOD),
decode(v_action,'I',:new.X_CREATED_BY2USER,:old.X_CREATED_BY2USER),
decode(v_action,'I',:new.X_SIM_STATUS2X_CODE_TABLE,:old.X_SIM_STATUS2X_CODE_TABLE),
decode(v_action,'I',:new.X_SIM_INV2INV_BIN,:old.X_SIM_INV2INV_BIN),
decode(v_action,'I',:new.X_PIN1,:old.X_PIN1),
decode(v_action,'I',:new.X_PIN2,:old.X_PIN2),
decode(v_action,'I',:new.X_PUK1,:old.X_PUK1),
decode(v_action,'I',:new.X_PUK2,:old.X_PUK2),
decode(v_action,'I',:new.X_QTY,:old.X_QTY),
                     decode(v_action,'I',:new.OBJID,:old.OBJID), --OBJID OF TABLE_X_SIM_INV
                    v_userid,         --OBJID OF TABLE_USER
                    SYSDATE,
                    v_osuser,
                    decode(v_action,'I','INSERT','U','UPDATE','D','DELETE'));

EXCEPTION
   WHEN OTHERS THEN
          insert_error_tab_proc ( 'Exception caught '||sqlerrm,
                                 '' ,
                                 'TSTAHIS_TRG_X_SIM_INV');
END;
/