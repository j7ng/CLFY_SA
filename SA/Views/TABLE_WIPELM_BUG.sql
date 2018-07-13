CREATE OR REPLACE FORCE VIEW sa.table_wipelm_bug (wip_objid,elm_objid,clarify_state,id_number,age,"CONDITION",s_condition,status,s_status,title,s_title,"PRIORITY",s_priority) AS
select table_bug.bug_wip2wipbin, table_bug.objid,
 table_condition.condition, table_bug.id_number,
 table_condition.wipbin_time, table_condition.title, table_condition.S_title,
 table_gse_status.title, table_gse_status.S_title, table_bug.title, table_bug.S_title,
 table_gse_priority.title, table_gse_priority.S_title
 from table_gbst_elm table_gse_priority, table_gbst_elm table_gse_status, table_bug, table_condition
 where table_condition.objid = table_bug.bug_condit2condition
 AND table_gse_status.objid = table_bug.bug_sts2gbst_elm
 AND table_bug.bug_wip2wipbin IS NOT NULL
 AND table_gse_priority.objid = table_bug.bug_priority2gbst_elm
 ;
COMMENT ON TABLE sa.table_wipelm_bug IS 'View bug in WIPbin form (375)';
COMMENT ON COLUMN sa.table_wipelm_bug.wip_objid IS 'WIPbin internal record number';
COMMENT ON COLUMN sa.table_wipelm_bug.elm_objid IS 'Bug internal record number';
COMMENT ON COLUMN sa.table_wipelm_bug.clarify_state IS 'Bug condition';
COMMENT ON COLUMN sa.table_wipelm_bug.id_number IS 'Bug ID number';
COMMENT ON COLUMN sa.table_wipelm_bug.age IS 'Age of bug in seconds';
COMMENT ON COLUMN sa.table_wipelm_bug."CONDITION" IS 'Bug condition';
COMMENT ON COLUMN sa.table_wipelm_bug.status IS 'Bug status';
COMMENT ON COLUMN sa.table_wipelm_bug.title IS 'Bug title';
COMMENT ON COLUMN sa.table_wipelm_bug."PRIORITY" IS 'Bug priority';