CREATE OR REPLACE TRIGGER sa.TSTAHIS_TRG_USER
BEFORE INSERT OR UPDATE OR DELETE ON sa.TABLE_USER
REFERENCING NEW AS NEW OLD AS OLD
FOR EACH ROW
DISABLE DECLARE
 v_action VARCHAR2(1);
 v_osuser  varchar2(50);
 v_userid varchar2(30);
pragma AUTONOMOUS_TRANSACTION;
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
      INSERT INTO sa.TSTAHIS_TABLE_USER
                  ( OBJID,
LOGIN_NAME,
S_LOGIN_NAME,
PASSWORD,
AGENT_ID,
STATUS,
EQUIP_ID,
CS_LIC,
CSDE_LIC,
CQ_LIC,
PASSWD_CHG,
LAST_LOGIN,
CLFO_LIC,
CS_LIC_TYPE,
CQ_LIC_TYPE,
CSFTS_LIC,
CSFTSDE_LIC,
CQFTS_LIC,
WEB_LOGIN,
S_WEB_LOGIN,
WEB_PASSWORD,
SUBMITTER_IND,
SFA_LIC,
CCN_LIC,
UNIV_LIC,
NODE_ID,
DEV,
LOCALE,
USER_ACCESS2PRIVCLASS,
USER_DEFAULT2WIPBIN,
SUPVR_DEFAULT2MONITOR,
USER2RC_CONFIG,
USER2SRVR,
OFFLINE2PRIVCLASS,
WIRELESS_EMAIL,
ALT_LOGIN_NAME,
S_ALT_LOGIN_NAME,
USER2PAGE_CLASS,
WEB_LAST_LOGIN,
WEB_PASSWD_CHG,
                    USER_HIST2USER,
                    USER_HIS2USER,
                    X_CHANGE_DATE,
                    OSUSER,
                    TRIGGERING_RECORD_TYPE )
           VALUES ( sa.SEQ_TSTAHIS_USER.nextval,
decode(v_action,'I',:new.LOGIN_NAME,:old.LOGIN_NAME),
decode(v_action,'I',:new.S_LOGIN_NAME,:old.S_LOGIN_NAME),
decode(v_action,'I',:new.PASSWORD,:old.PASSWORD),
decode(v_action,'I',:new.AGENT_ID,:old.AGENT_ID),
decode(v_action,'I',:new.STATUS,:old.STATUS),
decode(v_action,'I',:new.EQUIP_ID,:old.EQUIP_ID),
decode(v_action,'I',:new.CS_LIC,:old.CS_LIC),
decode(v_action,'I',:new.CSDE_LIC,:old.CSDE_LIC),
decode(v_action,'I',:new.CQ_LIC,:old.CQ_LIC),
decode(v_action,'I',:new.PASSWD_CHG,:old.PASSWD_CHG),
decode(v_action,'I',:new.LAST_LOGIN,:old.LAST_LOGIN),
decode(v_action,'I',:new.CLFO_LIC,:old.CLFO_LIC),
decode(v_action,'I',:new.CS_LIC_TYPE,:old.CS_LIC_TYPE),
decode(v_action,'I',:new.CQ_LIC_TYPE,:old.CQ_LIC_TYPE),
decode(v_action,'I',:new.CSFTS_LIC,:old.CSFTS_LIC),
decode(v_action,'I',:new.CSFTSDE_LIC,:old.CSFTSDE_LIC),
decode(v_action,'I',:new.CQFTS_LIC,:old.CQFTS_LIC),
decode(v_action,'I',:new.WEB_LOGIN,:old.WEB_LOGIN),
decode(v_action,'I',:new.S_WEB_LOGIN,:old.S_WEB_LOGIN),
decode(v_action,'I',:new.WEB_PASSWORD,:old.WEB_PASSWORD),
decode(v_action,'I',:new.SUBMITTER_IND,:old.SUBMITTER_IND),
decode(v_action,'I',:new.SFA_LIC,:old.SFA_LIC),
decode(v_action,'I',:new.CCN_LIC,:old.CCN_LIC),
decode(v_action,'I',:new.UNIV_LIC,:old.UNIV_LIC),
decode(v_action,'I',:new.NODE_ID,:old.NODE_ID),
decode(v_action,'I',:new.DEV,:old.DEV),
decode(v_action,'I',:new.LOCALE,:old.LOCALE),
decode(v_action,'I',:new.USER_ACCESS2PRIVCLASS,:old.USER_ACCESS2PRIVCLASS),
decode(v_action,'I',:new.USER_DEFAULT2WIPBIN,:old.USER_DEFAULT2WIPBIN),
decode(v_action,'I',:new.SUPVR_DEFAULT2MONITOR,:old.SUPVR_DEFAULT2MONITOR),
decode(v_action,'I',:new.USER2RC_CONFIG,:old.USER2RC_CONFIG),
decode(v_action,'I',:new.USER2SRVR,:old.USER2SRVR),
decode(v_action,'I',:new.OFFLINE2PRIVCLASS,:old.OFFLINE2PRIVCLASS),
decode(v_action,'I',:new.WIRELESS_EMAIL,:old.WIRELESS_EMAIL),
decode(v_action,'I',:new.ALT_LOGIN_NAME,:old.ALT_LOGIN_NAME),
decode(v_action,'I',:new.S_ALT_LOGIN_NAME,:old.S_ALT_LOGIN_NAME),
decode(v_action,'I',:new.USER2PAGE_CLASS,:old.USER2PAGE_CLASS),
decode(v_action,'I',:new.WEB_LAST_LOGIN,:old.WEB_LAST_LOGIN),
decode(v_action,'I',:new.WEB_PASSWD_CHG,:old.WEB_PASSWD_CHG),
                     decode(v_action,'I',:new.OBJID,:old.OBJID), --OBJID OF TABLE_USER
                    v_userid,         --OBJID OF TABLE_USER
                    SYSDATE,
                    v_osuser,
                    decode(v_action,'I','INSERT','U','UPDATE','D','DELETE'));
          commit;
EXCEPTION
   WHEN OTHERS THEN
          insert_error_tab_proc ( 'Exception caught '||sqlerrm,
                                 '' ,
                                 'TSTAHIS_TRG_USER');
                                 commit;

END;
/