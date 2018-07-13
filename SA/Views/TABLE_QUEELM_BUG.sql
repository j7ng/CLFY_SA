CREATE OR REPLACE FORCE VIEW sa.table_queelm_bug (que_objid,elm_objid,clarify_state,id_number,age,"CONDITION",s_condition,status,s_status,title,s_title,"PRIORITY",s_priority,"TYPE",s_type) AS
select table_bug.bug_currq2queue, table_bug.objid,
 table_condition.condition, table_bug.id_number,
 table_condition.queue_time, table_condition.title, table_condition.S_title,
 table_gse_status.title, table_gse_status.S_title, table_bug.title, table_bug.S_title,
 table_gse_priority.title, table_gse_priority.S_title, table_gse_type.title, table_gse_type.S_title
 from table_gbst_elm table_gse_priority, table_gbst_elm table_gse_status, table_gbst_elm table_gse_type, table_bug, table_condition
 where table_condition.objid = table_bug.bug_condit2condition
 AND table_gse_type.objid = table_bug.bug_type2gbst_elm
 AND table_gse_status.objid = table_bug.bug_sts2gbst_elm
 AND table_bug.bug_currq2queue IS NOT NULL
 AND table_gse_priority.objid = table_bug.bug_priority2gbst_elm
 ;
COMMENT ON TABLE sa.table_queelm_bug IS 'View bug object from Open Queue form';
COMMENT ON COLUMN sa.table_queelm_bug.que_objid IS 'Queue object ID number';
COMMENT ON COLUMN sa.table_queelm_bug.elm_objid IS 'Bug object ID number';
COMMENT ON COLUMN sa.table_queelm_bug.clarify_state IS 'Bug condition';
COMMENT ON COLUMN sa.table_queelm_bug.id_number IS 'Bug object ID number';
COMMENT ON COLUMN sa.table_queelm_bug.age IS 'Age of bug in seconds';
COMMENT ON COLUMN sa.table_queelm_bug."CONDITION" IS 'Condition of bug';
COMMENT ON COLUMN sa.table_queelm_bug.status IS 'Status of bug';
COMMENT ON COLUMN sa.table_queelm_bug.title IS 'Title of bug';
COMMENT ON COLUMN sa.table_queelm_bug."PRIORITY" IS 'Priority of bug';
COMMENT ON COLUMN sa.table_queelm_bug."TYPE" IS 'Bug type';