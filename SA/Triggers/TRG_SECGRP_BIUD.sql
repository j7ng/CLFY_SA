CREATE OR REPLACE TRIGGER sa."TRG_SECGRP_BIUD"
BEFORE INSERT OR UPDATE OR DELETE ON sa.TABLE_X_SEC_GRP
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
      INSERT INTO x_SEC_GRP_HIST
                  ( OBJID,
DEV,
X_GRP_ID,
X_GRP_NAME,
X_GRP_DESC,
X_CREATE_DATE,
X_GRP_VALIDATE_FLAG,
X_SEC_GRP2X_THRESHOLD,
X_SOURCESYSTEM,
SEC_GRP_HIST2SEC_GRP,
SEC_GRP_HIST2USER,
X_CHANGE_DATE,
OSUSER,
TRIGGERING_RECORD_TYPE)
           VALUES ( SEQU_X_SEC_GRP_HIST.nextval,
                    decode(v_action,'I',:new.DEV,:old.DEV),
                    decode(v_action,'I',:new.X_GRP_ID,:old.X_GRP_ID),
                    decode(v_action,'I',:new.X_GRP_NAME,:old.X_GRP_NAME),
                    decode(v_action,'I',:new.X_GRP_DESC,:old.X_GRP_DESC),
                    decode(v_action,'I',:new.X_CREATE_DATE,:old.X_CREATE_DATE),
                    decode(v_action,'I',:new.X_GRP_VALIDATE_FLAG,:old.X_GRP_VALIDATE_FLAG),
                    decode(v_action,'I',:new.X_SEC_GRP2X_THRESHOLD,:old.X_SEC_GRP2X_THRESHOLD),
                    decode(v_action,'I',:new.X_SOURCESYSTEM,:old.X_SOURCESYSTEM),
                    :old.OBJID,       --OBJID OF TABLE_X_SEC_GRP
                    v_userid,         --OBJID OF TABLE_USER
                    SYSDATE,
                    v_osuser,
                    decode(v_action,'I','INSERT','U','UPDATE','D','DELETE'));
EXCEPTION
   WHEN OTHERS THEN
          insert_error_tab_proc ( 'Exception caught '||sqlerrm,
                                 '' ,
                                 'TRG_SECGRP_BIUD');
END;
/