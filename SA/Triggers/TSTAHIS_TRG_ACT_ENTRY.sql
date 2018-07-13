CREATE OR REPLACE TRIGGER sa.TSTAHIS_TRG_ACT_ENTRY
BEFORE INSERT OR UPDATE OR DELETE ON sa.TABLE_ACT_ENTRY
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
      INSERT INTO sa.TSTAHIS_TABLE_ACT_ENTRY
                  ( OBJID,
                    ACT_CODE,
                    ENTRY_TIME,
                    ADDNL_INFO,
                    PROXY,
                    REMOVED,
                    DEV,
                    ACT_ENTRY2CASE,
                    ACT_ENTRY2SUBCASE,
                    ACT_ENTRY2PROBDESC,
                    ACT_ENTRY2WORKAROUND,
                    ACT_ENTRY2USER,
                    ACT_ENTRY2REJECT_MSG,
                    ACT_ENTRY2NOTES_LOG,
                    ACT_ENTRY2PHONE_LOG,
                    ACT_ENTRY2RESRCH_LOG,
                    ACT_ENTRY2COMMIT_LOG,
                    ACT_ENTRY2ESCALATION,
                    ACT_ENTRY2ONSITE_LOG,
                    ACT_ENTRY2EMAIL_LOG,
                    ACT_ENTRY2SITE_PART,
                    ACT_ENTRY2SITE,
                    ACT_ENTRY2BUG,
                    ENTRY_NAME2GBST_ELM,
                    ACT_ENTRY_CHILD2PARENT,
                    ACT_ENTRY2BIZ_CAL_HDR,
                    ACT_ENTRY2SCHEDULE,
                    ACT_ENTRY2DISPTCHFE,
                    ACT_ENTRY2EMPLOYEE,
                    ACT_ENTRY2DEMAND_DTL,
                    ACT_ENTRY2DOC_INST,
                    ACT_ENTRY2PART_TRANS,
                    ACT_ENTRY2OPPORTUNITY,
                    ACT_ENTRY2CONTRACT,
                    ACT_ENTRY2JOB,
                    ACT_ENTRY2CONTACT,
                    ACT_ENTRY2TASK,
                    ACT_ENTRY2EXCHANGE,
                    ACT_ENTRY2EXCH_LOG,
                    ACT_ENTRY2CONTR_ITM,
                    ACT_ENTRY2COUNT_SETUP,
                    FOCUS_LOWID,
                    FOCUS_TYPE,
                    ACT_ENTRY_HIST2ACT_ENTRY,
                    ACT_ENTRY_HIS2USER,
                    X_CHANGE_DATE,
                    OSUSER,
                    TRIGGERING_RECORD_TYPE )
           VALUES ( sa.SEQ_TSTAHIS_ACT_ENTRY.nextval,
                    decode(v_action,'I',:new.ACT_CODE,:old.ACT_CODE),
                    decode(v_action,'I',:new.ENTRY_TIME,:old.ENTRY_TIME),
                    decode(v_action,'I',:new.ADDNL_INFO,:old.ADDNL_INFO),
                    decode(v_action,'I',:new.PROXY,:old.PROXY),
                    decode(v_action,'I',:new.REMOVED,:old.REMOVED),
                    decode(v_action,'I',:new.DEV,:old.DEV),
                    decode(v_action,'I',:new.ACT_ENTRY2CASE,:old.ACT_ENTRY2CASE),
                    decode(v_action,'I',:new.ACT_ENTRY2SUBCASE,:old.ACT_ENTRY2SUBCASE),
                    decode(v_action,'I',:new.ACT_ENTRY2PROBDESC,:old.ACT_ENTRY2PROBDESC),
                    decode(v_action,'I',:new.ACT_ENTRY2WORKAROUND,:old.ACT_ENTRY2WORKAROUND),
                    decode(v_action,'I',:new.ACT_ENTRY2USER,:old.ACT_ENTRY2USER),
                    decode(v_action,'I',:new.ACT_ENTRY2REJECT_MSG,:old.ACT_ENTRY2REJECT_MSG),
                    decode(v_action,'I',:new.ACT_ENTRY2NOTES_LOG,:old.ACT_ENTRY2NOTES_LOG),
                    decode(v_action,'I',:new.ACT_ENTRY2PHONE_LOG,:old.ACT_ENTRY2PHONE_LOG),
                    decode(v_action,'I',:new.ACT_ENTRY2RESRCH_LOG,:old.ACT_ENTRY2RESRCH_LOG),
                    decode(v_action,'I',:new.ACT_ENTRY2COMMIT_LOG,:old.ACT_ENTRY2COMMIT_LOG),
                    decode(v_action,'I',:new.ACT_ENTRY2ESCALATION,:old.ACT_ENTRY2ESCALATION),
                    decode(v_action,'I',:new.ACT_ENTRY2ONSITE_LOG,:old.ACT_ENTRY2ONSITE_LOG),
                    decode(v_action,'I',:new.ACT_ENTRY2EMAIL_LOG,:old.ACT_ENTRY2EMAIL_LOG),
                    decode(v_action,'I',:new.ACT_ENTRY2SITE_PART,:old.ACT_ENTRY2SITE_PART),
                    decode(v_action,'I',:new.ACT_ENTRY2SITE,:old.ACT_ENTRY2SITE),
                    decode(v_action,'I',:new.ACT_ENTRY2BUG,:old.ACT_ENTRY2BUG),
                    decode(v_action,'I',:new.ENTRY_NAME2GBST_ELM,:old.ENTRY_NAME2GBST_ELM),
                    decode(v_action,'I',:new.ACT_ENTRY_CHILD2PARENT,:old.ACT_ENTRY_CHILD2PARENT),
                    decode(v_action,'I',:new.ACT_ENTRY2BIZ_CAL_HDR,:old.ACT_ENTRY2BIZ_CAL_HDR),
                    decode(v_action,'I',:new.ACT_ENTRY2SCHEDULE,:old.ACT_ENTRY2SCHEDULE),
                    decode(v_action,'I',:new.ACT_ENTRY2DISPTCHFE,:old.ACT_ENTRY2DISPTCHFE),
                    decode(v_action,'I',:new.ACT_ENTRY2EMPLOYEE,:old.ACT_ENTRY2EMPLOYEE),
                    decode(v_action,'I',:new.ACT_ENTRY2DEMAND_DTL,:old.ACT_ENTRY2DEMAND_DTL),
                    decode(v_action,'I',:new.ACT_ENTRY2DOC_INST,:old.ACT_ENTRY2DOC_INST),
                    decode(v_action,'I',:new.ACT_ENTRY2PART_TRANS,:old.ACT_ENTRY2PART_TRANS),
                    decode(v_action,'I',:new.ACT_ENTRY2OPPORTUNITY,:old.ACT_ENTRY2OPPORTUNITY),
                    decode(v_action,'I',:new.ACT_ENTRY2CONTRACT,:old.ACT_ENTRY2CONTRACT),
                    decode(v_action,'I',:new.ACT_ENTRY2JOB,:old.ACT_ENTRY2JOB),
                    decode(v_action,'I',:new.ACT_ENTRY2CONTACT,:old.ACT_ENTRY2CONTACT),
                    decode(v_action,'I',:new.ACT_ENTRY2TASK,:old.ACT_ENTRY2TASK),
                    decode(v_action,'I',:new.ACT_ENTRY2EXCHANGE,:old.ACT_ENTRY2EXCHANGE),
                    decode(v_action,'I',:new.ACT_ENTRY2EXCH_LOG,:old.ACT_ENTRY2EXCH_LOG),
                    decode(v_action,'I',:new.ACT_ENTRY2CONTR_ITM,:old.ACT_ENTRY2CONTR_ITM),
                    decode(v_action,'I',:new.ACT_ENTRY2COUNT_SETUP,:old.ACT_ENTRY2COUNT_SETUP),
                    decode(v_action,'I',:new.FOCUS_LOWID,:old.FOCUS_LOWID),
                    decode(v_action,'I',:new.FOCUS_TYPE,:old.FOCUS_TYPE),
					          decode(v_action,'I',:new.OBJID,:old.OBJID), --OBJID OF TABLE_ACT_ENTRY
                    v_userid,         --OBJID OF TABLE_USER
                    SYSDATE,
                    v_osuser,
                    decode(v_action,'I','INSERT','U','UPDATE','D','DELETE'));
EXCEPTION
   WHEN OTHERS THEN
          insert_error_tab_proc ( 'Exception caught '||sqlerrm,
                                 '' ,
                                 'TSTAHIS_TRG_ACT_ENTRY');
END;
/