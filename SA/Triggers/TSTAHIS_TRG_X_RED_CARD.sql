CREATE OR REPLACE TRIGGER sa.TSTAHIS_TRG_X_RED_CARD
BEFORE INSERT OR UPDATE OR DELETE ON sa.TABLE_X_RED_CARD
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
      INSERT INTO sa.TSTAHIS_TABLE_X_RED_CARD
                  ( OBJID,
RED_CARD2CALL_TRANS,
RED_SMP2INV_SMP,
RED_SMP2X_PI_HIST,
X_ACCESS_DAYS,
X_RED_CODE,
X_RED_DATE,
X_RED_UNITS,
X_SMP,
X_STATUS,
X_RESULT,
X_CREATED_BY2USER,
X_INV_INSERT_DATE,
X_LAST_SHIP_DATE,
X_ORDER_NUMBER,
X_PO_NUM,
X_RED_CARD2INV_BIN,
X_RED_CARD2PART_MOD,
                    X_RED_CARD_HIST2X_RED_CARD,
                    X_RED_CARD_HIS2USER,
                    X_CHANGE_DATE,
                    OSUSER,
                    TRIGGERING_RECORD_TYPE )
           VALUES ( sa.SEQ_TSTAHIS_X_RED_CARD.nextval,
decode(v_action,'I',:new.RED_CARD2CALL_TRANS,:old.RED_CARD2CALL_TRANS),
decode(v_action,'I',:new.RED_SMP2INV_SMP,:old.RED_SMP2INV_SMP),
decode(v_action,'I',:new.RED_SMP2X_PI_HIST,:old.RED_SMP2X_PI_HIST),
decode(v_action,'I',:new.X_ACCESS_DAYS,:old.X_ACCESS_DAYS),
decode(v_action,'I',:new.X_RED_CODE,:old.X_RED_CODE),
decode(v_action,'I',:new.X_RED_DATE,:old.X_RED_DATE),
decode(v_action,'I',:new.X_RED_UNITS,:old.X_RED_UNITS),
decode(v_action,'I',:new.X_SMP,:old.X_SMP),
decode(v_action,'I',:new.X_STATUS,:old.X_STATUS),
decode(v_action,'I',:new.X_RESULT,:old.X_RESULT),
decode(v_action,'I',:new.X_CREATED_BY2USER,:old.X_CREATED_BY2USER),
decode(v_action,'I',:new.X_INV_INSERT_DATE,:old.X_INV_INSERT_DATE),
decode(v_action,'I',:new.X_LAST_SHIP_DATE,:old.X_LAST_SHIP_DATE),
decode(v_action,'I',:new.X_ORDER_NUMBER,:old.X_ORDER_NUMBER),
decode(v_action,'I',:new.X_PO_NUM,:old.X_PO_NUM),
decode(v_action,'I',:new.X_RED_CARD2INV_BIN,:old.X_RED_CARD2INV_BIN),
decode(v_action,'I',:new.X_RED_CARD2PART_MOD,:old.X_RED_CARD2PART_MOD),
                     decode(v_action,'I',:new.OBJID,:old.OBJID), --OBJID OF TABLE_X_RED_CARD
                    v_userid,         --OBJID OF TABLE_USER
                    SYSDATE,
                    v_osuser,
                    decode(v_action,'I','INSERT','U','UPDATE','D','DELETE'));

EXCEPTION
   WHEN OTHERS THEN
          insert_error_tab_proc ( 'Exception caught '||sqlerrm,
                                 '' ,
                                 'TSTAHIS_TRG_X_RED_CARD');
END;
/