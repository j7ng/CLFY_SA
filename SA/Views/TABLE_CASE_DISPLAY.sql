CREATE OR REPLACE FORCE VIEW sa.table_case_display (objid,id_number,"CONDITION",s_condition,status,s_status,title,s_title,creation_time,first_name,s_first_name,last_name,s_last_name,phone,severity,s_severity,"TYPE",s_type,is_supercase,cond_objid,status_objid,type_objid,severity_objid,site_objid,site_name,s_site_name,site_id,condition_code,contact_objid) AS
select table_case.objid, table_case.id_number,
 table_condition.title, table_condition.S_title, table_gse_status.title, table_gse_status.S_title,
 table_case.title, table_case.S_title, table_case.creation_time,
 table_contact.first_name, table_contact.S_first_name, table_contact.last_name, table_contact.S_last_name,
 table_contact.phone, table_gse_severity.title, table_gse_severity.S_title,
 table_gse_type.title, table_gse_type.S_title, table_case.is_supercase,
 table_condition.objid, table_gse_status.objid,
 table_gse_type.objid, table_gse_severity.objid,
 table_site.objid, table_site.name, table_site.S_name,
 table_site.site_id, table_condition.condition,
 table_contact.objid
 from table_gbst_elm table_gse_severity, table_gbst_elm table_gse_status, table_gbst_elm table_gse_type, table_case, table_condition, table_contact,
  table_site
 where table_condition.objid = table_case.case_state2condition
 AND table_gse_type.objid = table_case.calltype2gbst_elm
 AND table_site.objid = table_case.case_reporter2site
 AND table_gse_severity.objid = table_case.respsvrty2gbst_elm
 AND table_contact.objid = table_case.case_reporter2contact
 AND table_gse_status.objid = table_case.casests2gbst_elm
 ;
COMMENT ON TABLE sa.table_case_display IS 'Displays cases in Account Manager. Used by form Account Manager (11650)';
COMMENT ON COLUMN sa.table_case_display.objid IS 'Case internal record number';
COMMENT ON COLUMN sa.table_case_display.id_number IS 'Unique case number assigned based on auto-numbering definition';
COMMENT ON COLUMN sa.table_case_display."CONDITION" IS 'Condition of the case';
COMMENT ON COLUMN sa.table_case_display.status IS 'Status of the case';
COMMENT ON COLUMN sa.table_case_display.title IS 'Case or service call title; summary of case details';
COMMENT ON COLUMN sa.table_case_display.creation_time IS 'The date and time the case was created';
COMMENT ON COLUMN sa.table_case_display.first_name IS 'Contact first name';
COMMENT ON COLUMN sa.table_case_display.last_name IS 'Contact last name';
COMMENT ON COLUMN sa.table_case_display.phone IS 'Contact phone number';
COMMENT ON COLUMN sa.table_case_display.severity IS 'Severity of the case';
COMMENT ON COLUMN sa.table_case_display."TYPE" IS 'Type of case';
COMMENT ON COLUMN sa.table_case_display.is_supercase IS 'Indicates whether the case is a super or a victim case; i.e., 0=normal or victim case, 1=supercase';
COMMENT ON COLUMN sa.table_case_display.cond_objid IS 'Condition internal record number';
COMMENT ON COLUMN sa.table_case_display.status_objid IS 'Status internal record number';
COMMENT ON COLUMN sa.table_case_display.type_objid IS 'Type internal record number';
COMMENT ON COLUMN sa.table_case_display.severity_objid IS 'Severity internal record number';
COMMENT ON COLUMN sa.table_case_display.site_objid IS 'Site internal record number';
COMMENT ON COLUMN sa.table_case_display.site_name IS 'Name of the reporting site';
COMMENT ON COLUMN sa.table_case_display.site_id IS 'Unique site number assigned according to auto-numbering definition';
COMMENT ON COLUMN sa.table_case_display.condition_code IS 'Code number for condition type';
COMMENT ON COLUMN sa.table_case_display.contact_objid IS 'Contact internal record number';