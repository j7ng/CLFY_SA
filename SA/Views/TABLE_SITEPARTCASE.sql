CREATE OR REPLACE FORCE VIEW sa.table_sitepartcase (contact_objid,elm_objid,clarify_state,id_number,title,s_title,age,"CONDITION",s_condition,status,s_status,last_name,s_last_name,first_name,s_first_name,creation_time,part_objid,serial_no,s_serial_no,is_supercase,instance_name,x_service_id,x_case_type) AS
select table_contact.objid, table_case.objid,
 table_condition.condition, table_case.id_number,
 table_case.title, table_case.S_title, table_condition.wipbin_time,
 table_condition.title, table_condition.S_title, table_gbst_elm.title, table_gbst_elm.S_title,
 table_contact.last_name, table_contact.S_last_name, table_contact.first_name, table_contact.S_first_name,
 table_case.creation_time, table_site_part.objid,
 table_site_part.serial_no, table_site_part.S_serial_no, table_case.is_supercase,
 table_site_part.instance_name, table_site_part.x_service_id,
 table_case.x_case_type
 from table_contact, table_case, table_condition,
  table_gbst_elm, table_site_part
 where table_condition.objid = table_case.case_state2condition
 AND table_gbst_elm.objid = table_case.casests2gbst_elm
 AND table_site_part.objid = table_case.case_prod2site_part
 AND table_contact.objid = table_case.case_reporter2contact
 ;
COMMENT ON TABLE sa.table_sitepartcase IS 'Used internally to select Cases related to Site Parts';
COMMENT ON COLUMN sa.table_sitepartcase.contact_objid IS 'Contact internal record number';
COMMENT ON COLUMN sa.table_sitepartcase.elm_objid IS 'Case internal record number';
COMMENT ON COLUMN sa.table_sitepartcase.clarify_state IS 'Code number for condition type';
COMMENT ON COLUMN sa.table_sitepartcase.id_number IS 'Unique case number assigned based on auto-numbering definition';
COMMENT ON COLUMN sa.table_sitepartcase.title IS 'Case or service call title; summary of case details';
COMMENT ON COLUMN sa.table_sitepartcase.age IS 'Date and time task was accepted into WIPbin';
COMMENT ON COLUMN sa.table_sitepartcase."CONDITION" IS 'Title of condition';
COMMENT ON COLUMN sa.table_sitepartcase.status IS 'Status of the case';
COMMENT ON COLUMN sa.table_sitepartcase.last_name IS 'Contact last name';
COMMENT ON COLUMN sa.table_sitepartcase.first_name IS 'Contact first name';
COMMENT ON COLUMN sa.table_sitepartcase.creation_time IS 'The date and time the case was created';
COMMENT ON COLUMN sa.table_sitepartcase.part_objid IS 'Site part internal record number';
COMMENT ON COLUMN sa.table_sitepartcase.serial_no IS 'Installed part serial number';
COMMENT ON COLUMN sa.table_sitepartcase.is_supercase IS 'Flag if the case is a super case';
COMMENT ON COLUMN sa.table_sitepartcase.instance_name IS 'Service type';
COMMENT ON COLUMN sa.table_sitepartcase.x_service_id IS 'ESN/Service ID for site part';
COMMENT ON COLUMN sa.table_sitepartcase.x_case_type IS 'Case type';