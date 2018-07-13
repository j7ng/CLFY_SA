CREATE OR REPLACE FORCE VIEW sa.table_prodcase (contact_objid,elm_objid,clarify_state,id_number,title,s_title,age,"CONDITION",s_condition,status,s_status,last_name,s_last_name,first_name,s_first_name,creation_time,prodpart_objid,svcpart_objid,svc_serial,s_svc_serial,is_supercase,role_objid) AS
select table_contact.objid, table_case.objid,
 table_condition.condition, table_case.id_number,
 table_case.title, table_case.S_title, table_condition.wipbin_time,
 table_condition.title, table_condition.S_title, table_gbst_elm.title, table_gbst_elm.S_title,
 table_contact.last_name, table_contact.S_last_name, table_contact.first_name, table_contact.S_first_name,
 table_case.creation_time, table_product_part.objid,
 table_service_part.objid, table_service_part.serial_no, table_service_part.S_serial_no,
 table_case.is_supercase, table_prt_prt_role.objid
 from table_site_part table_product_part, table_site_part table_service_part, table_contact, table_case, table_condition,
  table_gbst_elm, table_prt_prt_role
 where table_service_part.objid = table_prt_prt_role.role_for2site_part
 AND table_contact.objid = table_case.case_reporter2contact
 AND table_product_part.objid = table_prt_prt_role.player2site_part
 AND table_product_part.objid = table_case.case_prod2site_part
 AND table_condition.objid = table_case.case_state2condition
 AND table_gbst_elm.objid = table_case.casests2gbst_elm
 ;
COMMENT ON TABLE sa.table_prodcase IS 'Selects Cases related to products';
COMMENT ON COLUMN sa.table_prodcase.contact_objid IS 'Contact internal record number';
COMMENT ON COLUMN sa.table_prodcase.elm_objid IS 'Case internal record number';
COMMENT ON COLUMN sa.table_prodcase.clarify_state IS 'Code number for condition type';
COMMENT ON COLUMN sa.table_prodcase.id_number IS 'Unique case number assigned based on auto-numbering definition';
COMMENT ON COLUMN sa.table_prodcase.title IS 'Case or service call title; summary of case details';
COMMENT ON COLUMN sa.table_prodcase.age IS 'Date and time task was accepted into WIPbin';
COMMENT ON COLUMN sa.table_prodcase."CONDITION" IS 'Title of condition';
COMMENT ON COLUMN sa.table_prodcase.status IS 'Status of the case';
COMMENT ON COLUMN sa.table_prodcase.last_name IS 'Contact last name';
COMMENT ON COLUMN sa.table_prodcase.first_name IS 'Contact first name';
COMMENT ON COLUMN sa.table_prodcase.creation_time IS 'The date and time the case was created';
COMMENT ON COLUMN sa.table_prodcase.prodpart_objid IS 'Product site part internal record number';
COMMENT ON COLUMN sa.table_prodcase.svcpart_objid IS 'Product site part internal record number';
COMMENT ON COLUMN sa.table_prodcase.svc_serial IS 'Installed product serial number';
COMMENT ON COLUMN sa.table_prodcase.is_supercase IS 'Flag if the case is a super case';
COMMENT ON COLUMN sa.table_prodcase.role_objid IS 'Interal record number of prt_prt_role';