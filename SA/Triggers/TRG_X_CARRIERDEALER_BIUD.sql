CREATE OR REPLACE TRIGGER sa."TRG_X_CARRIERDEALER_BIUD"
BEFORE INSERT OR UPDATE OR DELETE ON sa.TABLE_X_CARRIERDEALER
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
      INSERT INTO x_carrierdealer_hist
                 ( OBJID,
                   X_CARRIER_ID,
                   X_DEALER_ID,
                   X_CD2X_CARRIER,
                   X_CD2SITE,
                   CARRIERDEALER_HIST2CARRIERDELR,
                   X_CARRIERDEALER_HIST2USER,
                   X_CHANGE_DATE,
                   OSUSER,
                   TRIGGERING_RECORD_TYPE
                 )
          VALUES ( seq_x_carrierdealer_hist.NEXTVAL,
                   decode(v_action,'I',:new.X_CARRIER_ID,:old.X_CARRIER_ID),
                   decode(v_action,'I',:new.X_DEALER_ID,:old.X_DEALER_ID),
                   decode(v_action,'I',:new.X_CD2X_CARRIER,:old.X_CD2X_CARRIER),
                   decode(v_action,'I',:new.X_CD2SITE,:old.X_CD2SITE),
                   :old.OBJID,      -- objid of Table_X_Carrierdealer
                   v_userid,        -- objid of Table_User
                   sysdate,
                   v_osuser,
                   decode(v_action,'I','INSERT','U','UPDATE','D','DELETE')
                 ) ;


EXCEPTION
   WHEN OTHERS THEN
          insert_error_tab_proc ( 'Exception caught '||sqlerrm,
                                 '' ,
                                 'TRG_X_CARRIERDEALER_BIUD');
END;
/