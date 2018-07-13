CREATE OR REPLACE FORCE VIEW sa.table_wipelm_subcase (wip_objid,elm_objid,clarify_state,id_number,age,"CONDITION",s_condition,status,s_status,title,s_title,"PRIORITY",s_priority,severity,s_severity,"OWNER",condition_code) AS
select table_subcase.subc_wip2wipbin, table_subcase.objid,
 table_condition.condition, table_subcase.id_number,
 table_condition.wipbin_time, table_condition.title, table_condition.S_title,
 table_gse_status.title, table_gse_status.S_title, table_subcase.title, table_subcase.S_title,
 table_gse_priority.title, table_gse_priority.S_title, table_gse_severity.title, table_gse_severity.S_title,
 table_subcase.subc_owner2user, table_condition.condition
 from table_gbst_elm table_gse_priority, table_gbst_elm table_gse_severity, table_gbst_elm table_gse_status, table_subcase, table_condition
 where table_gse_status.objid = table_subcase.subc_casests2gbst_elm
 AND table_subcase.subc_owner2user IS NOT NULL
 AND table_gse_priority.objid = table_subcase.subc_priorty2gbst_elm
 AND table_condition.objid = table_subcase.subc_state2condition
 AND table_subcase.subc_wip2wipbin IS NOT NULL
 AND table_gse_severity.objid = table_subcase.subc_svrity2gbst_elm
 ;
COMMENT ON TABLE sa.table_wipelm_subcase IS 'View subcase information for WIPbin form (375)';
COMMENT ON COLUMN sa.table_wipelm_subcase.wip_objid IS 'WIPbin internal record number';
COMMENT ON COLUMN sa.table_wipelm_subcase.elm_objid IS 'Subcase internal record number number';
COMMENT ON COLUMN sa.table_wipelm_subcase.clarify_state IS 'Subcase state';
COMMENT ON COLUMN sa.table_wipelm_subcase.id_number IS 'Unique ID number for the subcase; consists of case number-#';
COMMENT ON COLUMN sa.table_wipelm_subcase.age IS 'Subcase age in seconds';
COMMENT ON COLUMN sa.table_wipelm_subcase."CONDITION" IS 'Subcase condition';
COMMENT ON COLUMN sa.table_wipelm_subcase.status IS 'Subcase status';
COMMENT ON COLUMN sa.table_wipelm_subcase.title IS 'Subcase title';
COMMENT ON COLUMN sa.table_wipelm_subcase."PRIORITY" IS 'Subcase priority';
COMMENT ON COLUMN sa.table_wipelm_subcase.severity IS 'Subcase severity';
COMMENT ON COLUMN sa.table_wipelm_subcase."OWNER" IS 'Subcase owner s internal record number';
COMMENT ON COLUMN sa.table_wipelm_subcase.condition_code IS 'Code number for subcase condition';