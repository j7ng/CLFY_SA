CREATE OR REPLACE FORCE VIEW sa.table_wipelm_case (wip_objid,elm_objid,clarify_state,id_number,age,"CONDITION",s_condition,status,s_status,title,s_title,"PRIORITY",s_priority,severity,s_severity,"OWNER",workaround,condition_code,x_carrier_id,x_carrier_name,x_creation_time,x_esn) AS
select table_case.case_wip2wipbin, table_case.objid,
 table_condition.condition, table_case.id_number,
 table_condition.wipbin_time, table_condition.title, table_condition.S_title,
 table_gse_status.title, table_gse_status.S_title, table_case.title, table_case.S_title,
 table_gse_priority.title, table_gse_priority.S_title, table_gse_severity.title, table_gse_severity.S_title,
 table_case.case_owner2user, table_case.case_soln2workaround,
 table_condition.condition, table_case.x_text_car_id,
 table_case.x_carrier_name, table_case.creation_time,
 table_case.x_esn
 from table_gbst_elm table_gse_priority, table_gbst_elm table_gse_severity, table_gbst_elm table_gse_status, table_case, table_condition
 where table_gse_priority.objid = table_case.respprty2gbst_elm
 AND table_condition.objid = table_case.case_state2condition
 AND table_case.case_wip2wipbin IS NOT NULL
 AND table_gse_status.objid = table_case.casests2gbst_elm
 AND table_case.case_owner2user IS NOT NULL
 AND table_gse_severity.objid = table_case.respsvrty2gbst_elm
 ;
COMMENT ON TABLE sa.table_wipelm_case IS 'View of case information in WIPbin form (375).  Used by forms WIPbin WIP name (375), WIPbin WIP name (377), Queue (376), Queue (378)';
COMMENT ON COLUMN sa.table_wipelm_case.wip_objid IS 'WIPbin internal record number';
COMMENT ON COLUMN sa.table_wipelm_case.elm_objid IS 'Case internal record number';
COMMENT ON COLUMN sa.table_wipelm_case.clarify_state IS 'State of case';
COMMENT ON COLUMN sa.table_wipelm_case.id_number IS 'Unique case number assigned based on auto-numbering definition';
COMMENT ON COLUMN sa.table_wipelm_case.age IS 'Age of case in seconds';
COMMENT ON COLUMN sa.table_wipelm_case."CONDITION" IS 'Case condition';
COMMENT ON COLUMN sa.table_wipelm_case.status IS 'Case status';
COMMENT ON COLUMN sa.table_wipelm_case.title IS 'Case title';
COMMENT ON COLUMN sa.table_wipelm_case."PRIORITY" IS 'Case priority';
COMMENT ON COLUMN sa.table_wipelm_case.severity IS 'Case severity';
COMMENT ON COLUMN sa.table_wipelm_case."OWNER" IS 'Case owner s Internal record number';
COMMENT ON COLUMN sa.table_wipelm_case.workaround IS 'Case workaround s internal record number';
COMMENT ON COLUMN sa.table_wipelm_case.condition_code IS 'Code number for case condition';
COMMENT ON COLUMN sa.table_wipelm_case.x_carrier_id IS 'Carrier ID stored as text from the case';
COMMENT ON COLUMN sa.table_wipelm_case.x_carrier_name IS 'Carrier Market/Submarket Name';
COMMENT ON COLUMN sa.table_wipelm_case.x_creation_time IS 'The date and time the case was created';
COMMENT ON COLUMN sa.table_wipelm_case.x_esn IS 'Serial Number of the Phone for Wireless or Service Id for Wireline';