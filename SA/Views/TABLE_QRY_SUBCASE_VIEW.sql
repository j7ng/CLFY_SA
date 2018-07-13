CREATE OR REPLACE FORCE VIEW sa.table_qry_subcase_view (elm_objid,id_number,"OWNER",s_owner,"CONDITION",s_condition,status,s_status,title,s_title,site_name,s_site_name,first_name,s_first_name,last_name,s_last_name,sub_type,behavior,"PRIORITY",s_priority,severity,s_severity,required_date) AS
select table_subcase.objid, table_subcase.id_number,
 table_owner.login_name, table_owner.S_login_name, table_condition.title, table_condition.S_title,
 table_gse_status.title, table_gse_status.S_title, table_subcase.title, table_subcase.S_title,
 table_site.name, table_site.S_name, table_contact.first_name, table_contact.S_first_name,
 table_contact.last_name, table_contact.S_last_name, table_subcase.sub_type,
 table_subcase.behavior, table_gse_priority.title, table_gse_priority.S_title,
 table_gse_severity.title, table_gse_severity.S_title, table_subcase.required_date
 from table_gbst_elm table_gse_priority, table_gbst_elm table_gse_severity, table_gbst_elm table_gse_status, table_user table_owner, table_subcase, table_condition, table_site,
  table_contact, table_case
 where table_contact.objid = table_case.case_reporter2contact
 AND table_gse_severity.objid = table_subcase.subc_svrity2gbst_elm
 AND table_case.objid = table_subcase.subcase2case
 AND table_owner.objid = table_subcase.subc_owner2user
 AND table_condition.objid = table_subcase.subc_state2condition
 AND table_gse_priority.objid = table_subcase.subc_priorty2gbst_elm
 AND table_site.objid = table_case.case_reporter2site
 AND table_gse_status.objid = table_subcase.subc_casests2gbst_elm
 ;
COMMENT ON TABLE sa.table_qry_subcase_view IS 'Used by form Subcases from Query (811)';
COMMENT ON COLUMN sa.table_qry_subcase_view.elm_objid IS 'Subcase internal record number';
COMMENT ON COLUMN sa.table_qry_subcase_view.id_number IS 'Unique ID number for the subcase; consists of case number-#';
COMMENT ON COLUMN sa.table_qry_subcase_view."OWNER" IS 'Subcase owner user login name';
COMMENT ON COLUMN sa.table_qry_subcase_view."CONDITION" IS 'Condition of the subcase';
COMMENT ON COLUMN sa.table_qry_subcase_view.status IS 'Status of the subcase';
COMMENT ON COLUMN sa.table_qry_subcase_view.title IS 'Subcase title';
COMMENT ON COLUMN sa.table_qry_subcase_view.site_name IS 'Name of the reporting site';
COMMENT ON COLUMN sa.table_qry_subcase_view.first_name IS 'Contact first name';
COMMENT ON COLUMN sa.table_qry_subcase_view.last_name IS 'Contact last name';
COMMENT ON COLUMN sa.table_qry_subcase_view.sub_type IS 'Subcase type; general or administrative';
COMMENT ON COLUMN sa.table_qry_subcase_view.behavior IS 'Internal field indicating the behavior of the subcase type; i.e.,  1=normal, 2=administrative subcase';
COMMENT ON COLUMN sa.table_qry_subcase_view."PRIORITY" IS 'Priority of the subcase';
COMMENT ON COLUMN sa.table_qry_subcase_view.severity IS 'Serverity of the subcase';
COMMENT ON COLUMN sa.table_qry_subcase_view.required_date IS 'Date and time task must be completed';