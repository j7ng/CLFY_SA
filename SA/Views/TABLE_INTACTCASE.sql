CREATE OR REPLACE FORCE VIEW sa.table_intactcase (contact_objid,elm_objid,clarify_state,id_number,title,s_title,age,"CONDITION",s_condition,status,s_status,last_name,s_last_name,first_name,s_first_name,creation_time,location_objid) AS
select table_employee.objid, table_case.objid,
 table_condition.condition, table_case.id_number,
 table_case.title, table_case.S_title, table_condition.wipbin_time,
 table_condition.title, table_condition.S_title, table_gbst_elm.title, table_gbst_elm.S_title,
 table_employee.last_name, table_employee.S_last_name, table_employee.first_name, table_employee.S_first_name,
 table_case.creation_time, table_site.objid
 from table_employee, table_case, table_condition,
  table_gbst_elm, table_site
 where table_employee.objid = table_case.case_empl2employee
 AND table_gbst_elm.objid = table_case.casests2gbst_elm
 AND table_condition.objid = table_case.case_state2condition
 AND table_employee.objid = table_site.site_support2employee
 ;
COMMENT ON TABLE sa.table_intactcase IS 'Reserved; not used';
COMMENT ON COLUMN sa.table_intactcase.contact_objid IS 'Employee internal record number';
COMMENT ON COLUMN sa.table_intactcase.elm_objid IS 'Case internal record number';
COMMENT ON COLUMN sa.table_intactcase.clarify_state IS 'Code number for condition type';
COMMENT ON COLUMN sa.table_intactcase.id_number IS 'Unique case number assigned based on auto-numbering definition';
COMMENT ON COLUMN sa.table_intactcase.title IS 'Case or service call title; summary of case details';
COMMENT ON COLUMN sa.table_intactcase.age IS 'Date and time task was accepted into WIPbin';
COMMENT ON COLUMN sa.table_intactcase."CONDITION" IS 'Title of condition';
COMMENT ON COLUMN sa.table_intactcase.status IS 'Reserved; not used';
COMMENT ON COLUMN sa.table_intactcase.last_name IS 'Employee last name';
COMMENT ON COLUMN sa.table_intactcase.first_name IS 'Employee first name';
COMMENT ON COLUMN sa.table_intactcase.creation_time IS 'The date and time the case was created';
COMMENT ON COLUMN sa.table_intactcase.location_objid IS 'Site internal record number';