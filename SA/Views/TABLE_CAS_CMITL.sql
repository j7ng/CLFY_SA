CREATE OR REPLACE FORCE VIEW sa.table_cas_cmitl (objid,title,creation_time,sched_cmpltime,act_cmpltime,cmit_txt,made_to,"CONDITION",originator,s_originator,"PRIORITY",s_priority,parent_objid) AS
select table_commit_log.objid, table_commit_log.title,
 table_commit_log.creation_time, table_commit_log.sched_cmpltime,
 table_commit_log.act_cmpltime, table_commit_log.cmit_history,
 table_commit_log.made_to, table_commit_log.condition,
 table_user.login_name, table_user.S_login_name, table_gbst_elm.title, table_gbst_elm.S_title,
 table_commit_log.case_commit2case
 from table_commit_log, table_user, table_gbst_elm
 where table_commit_log.case_commit2case IS NOT NULL
 AND table_gbst_elm.objid = table_commit_log.cmit_prirty2gbst_elm
 AND table_user.objid = table_commit_log.commit_owner2user
 ;
COMMENT ON TABLE sa.table_cas_cmitl IS 'Selects case commitment information';
COMMENT ON COLUMN sa.table_cas_cmitl.objid IS 'Commitment object ID number';
COMMENT ON COLUMN sa.table_cas_cmitl.title IS 'Commitment title';
COMMENT ON COLUMN sa.table_cas_cmitl.creation_time IS 'Commitment creation date and time';
COMMENT ON COLUMN sa.table_cas_cmitl.sched_cmpltime IS 'Scheduled completion time';
COMMENT ON COLUMN sa.table_cas_cmitl.act_cmpltime IS 'Actual completion time';
COMMENT ON COLUMN sa.table_cas_cmitl.cmit_txt IS 'Commitment details';
COMMENT ON COLUMN sa.table_cas_cmitl.made_to IS 'Whom the commitment was made to';
COMMENT ON COLUMN sa.table_cas_cmitl."CONDITION" IS 'Commitment condition';
COMMENT ON COLUMN sa.table_cas_cmitl.originator IS 'Commitment originator';
COMMENT ON COLUMN sa.table_cas_cmitl."PRIORITY" IS 'Commitment priority';
COMMENT ON COLUMN sa.table_cas_cmitl.parent_objid IS 'Parent case object ID number';