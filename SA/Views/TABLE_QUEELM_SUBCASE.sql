CREATE OR REPLACE FORCE VIEW sa.table_queelm_subcase (que_objid,elm_objid,clarify_state,id_number,age,"CONDITION",s_condition,status,s_status,title,s_title,"PRIORITY",s_priority,severity,s_severity,subtype,"OWNER",condition_code) AS
select table_subcase.subc_currq2queue, table_subcase.objid,
 table_condition.condition, table_subcase.id_number,
 table_condition.queue_time, table_condition.title, table_condition.S_title,
 table_gse_status.title, table_gse_status.S_title, table_subcase.title, table_subcase.S_title,
 table_gse_priority.title, table_gse_priority.S_title, table_gse_severity.title, table_gse_severity.S_title,
 table_subcase.sub_type, table_subcase.subc_owner2user,
 table_condition.condition
 from table_gbst_elm table_gse_priority, table_gbst_elm table_gse_severity, table_gbst_elm table_gse_status, table_subcase, table_condition
 where table_subcase.subc_currq2queue IS NOT NULL
 AND table_condition.objid = table_subcase.subc_state2condition
 AND table_gse_status.objid = table_subcase.subc_casests2gbst_elm
 AND table_gse_severity.objid = table_subcase.subc_svrity2gbst_elm
 AND table_subcase.subc_owner2user IS NOT NULL
 AND table_gse_priority.objid = table_subcase.subc_priorty2gbst_elm
 ;
COMMENT ON TABLE sa.table_queelm_subcase IS 'View subcase information for form Queue (378)';
COMMENT ON COLUMN sa.table_queelm_subcase.que_objid IS 'Queue object ID number';
COMMENT ON COLUMN sa.table_queelm_subcase.elm_objid IS 'Subcase object ID number';
COMMENT ON COLUMN sa.table_queelm_subcase.clarify_state IS 'Subcase condition';
COMMENT ON COLUMN sa.table_queelm_subcase.id_number IS 'Subcase ID number';
COMMENT ON COLUMN sa.table_queelm_subcase.age IS 'Age of subcase in seconds';
COMMENT ON COLUMN sa.table_queelm_subcase."CONDITION" IS 'Condition of subcase';
COMMENT ON COLUMN sa.table_queelm_subcase.status IS 'Status of subcase';
COMMENT ON COLUMN sa.table_queelm_subcase.title IS 'Title of subcase';
COMMENT ON COLUMN sa.table_queelm_subcase."PRIORITY" IS 'Priority of subcase';
COMMENT ON COLUMN sa.table_queelm_subcase.severity IS 'Severity of subcase';
COMMENT ON COLUMN sa.table_queelm_subcase.subtype IS 'Subcase type';
COMMENT ON COLUMN sa.table_queelm_subcase."OWNER" IS 'Subcase owner s internal record number';
COMMENT ON COLUMN sa.table_queelm_subcase.condition_code IS 'Code number for subcase condition';