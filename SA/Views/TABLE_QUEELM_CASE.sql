CREATE OR REPLACE FORCE VIEW sa.table_queelm_case (que_objid,elm_objid,clarify_state,id_number,age,"CONDITION",s_condition,status,s_status,title,s_title,"PRIORITY",s_priority,severity,s_severity,"TYPE",s_type,"OWNER",workaround,condition_code,x_carrier_id,x_carrier_name,x_creation_time,x_esn) AS
select table_case.case_currq2queue, table_case.objid,
 table_condition.condition, table_case.id_number,
 table_condition.queue_time, table_condition.title, table_condition.S_title,
 table_gse_status.title, table_gse_status.S_title, table_case.title, table_case.S_title,
 table_gse_priority.title, table_gse_priority.S_title, table_gse_severity.title, table_gse_severity.S_title,
 table_gse_type.title, table_gse_type.S_title, table_case.case_owner2user,
 table_case.case_soln2workaround, table_condition.condition,
 table_case.x_text_car_id, table_case.x_carrier_name,
 table_case.creation_time, table_case.x_esn
 from table_gbst_elm table_gse_priority, table_gbst_elm table_gse_severity, table_gbst_elm table_gse_status, table_gbst_elm table_gse_type, table_case, table_condition
 where table_case.case_currq2queue IS NOT NULL
 AND table_case.case_owner2user IS NOT NULL
 AND table_condition.objid = table_case.case_state2condition
 AND table_gse_priority.objid = table_case.respprty2gbst_elm
 AND table_gse_severity.objid = table_case.respsvrty2gbst_elm
 AND table_gse_type.objid = table_case.calltype2gbst_elm
 AND table_gse_status.objid = table_case.casests2gbst_elm
 ;
COMMENT ON TABLE sa.table_queelm_case IS 'View case information for Queue form (728)';
COMMENT ON COLUMN sa.table_queelm_case.que_objid IS 'Queue internal record number';
COMMENT ON COLUMN sa.table_queelm_case.elm_objid IS 'Case internal record number';
COMMENT ON COLUMN sa.table_queelm_case.clarify_state IS 'Case condition';
COMMENT ON COLUMN sa.table_queelm_case.id_number IS 'Unique case number assigned based on auto-numbering definition';
COMMENT ON COLUMN sa.table_queelm_case.age IS 'Age of case in seconds';
COMMENT ON COLUMN sa.table_queelm_case."CONDITION" IS 'Condition of case';
COMMENT ON COLUMN sa.table_queelm_case.status IS 'Status of case';
COMMENT ON COLUMN sa.table_queelm_case.title IS 'Title of case';
COMMENT ON COLUMN sa.table_queelm_case."PRIORITY" IS 'Priority of case';
COMMENT ON COLUMN sa.table_queelm_case.severity IS 'Severity of case';
COMMENT ON COLUMN sa.table_queelm_case."TYPE" IS 'Type of case';
COMMENT ON COLUMN sa.table_queelm_case."OWNER" IS 'Case owner s Internal record number';
COMMENT ON COLUMN sa.table_queelm_case.workaround IS 'Case workaround s internal record number';
COMMENT ON COLUMN sa.table_queelm_case.condition_code IS 'Code number for case condition';
COMMENT ON COLUMN sa.table_queelm_case.x_carrier_id IS 'Carrier ID stored as text from the case';
COMMENT ON COLUMN sa.table_queelm_case.x_carrier_name IS 'Carrier Market/Submarket Name';
COMMENT ON COLUMN sa.table_queelm_case.x_creation_time IS 'The date and time the case was created';
COMMENT ON COLUMN sa.table_queelm_case.x_esn IS 'Serial Number of the Phone for Wireless or Service Id for Wireline';