CREATE OR REPLACE FORCE VIEW sa.table_dfe_cmitl (objid,title,creation_time,sched_cmpltime,act_cmpltime,cmit_txt,made_to,"CONDITION",originator,s_originator,"PRIORITY",s_priority,parent_objid) AS
select table_commit_log.objid, table_commit_log.title,
 table_commit_log.creation_time, table_commit_log.sched_cmpltime,
 table_commit_log.act_cmpltime, table_commit_log.cmit_history,
 table_commit_log.made_to, table_commit_log.condition,
 table_user.login_name, table_user.S_login_name, table_gbst_elm.title, table_gbst_elm.S_title,
 table_disptchfe.objid
 from table_commit_log, table_user, table_gbst_elm,
  table_disptchfe
 where table_user.objid = table_commit_log.commit_owner2user
 AND table_gbst_elm.objid = table_commit_log.cmit_prirty2gbst_elm
 ;
COMMENT ON TABLE sa.table_dfe_cmitl IS 'Selects dispatch FE commitments';
COMMENT ON COLUMN sa.table_dfe_cmitl.objid IS 'Commitment object ID number';
COMMENT ON COLUMN sa.table_dfe_cmitl.title IS 'Commitment title';
COMMENT ON COLUMN sa.table_dfe_cmitl.creation_time IS 'Commitment creation date and time';
COMMENT ON COLUMN sa.table_dfe_cmitl.sched_cmpltime IS 'Scheduled completion date and time';
COMMENT ON COLUMN sa.table_dfe_cmitl.act_cmpltime IS 'Actual completion date and time';
COMMENT ON COLUMN sa.table_dfe_cmitl.cmit_txt IS 'Commitment details';
COMMENT ON COLUMN sa.table_dfe_cmitl.made_to IS 'Whom commitment is made to';
COMMENT ON COLUMN sa.table_dfe_cmitl."CONDITION" IS 'Commitment condition';
COMMENT ON COLUMN sa.table_dfe_cmitl.originator IS 'User that originated commitment';
COMMENT ON COLUMN sa.table_dfe_cmitl."PRIORITY" IS 'Commitment priority';
COMMENT ON COLUMN sa.table_dfe_cmitl.parent_objid IS 'Parent dispatch FE object ID number';