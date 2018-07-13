CREATE OR REPLACE FORCE VIEW sa.table_v_cls_subc (subcase_id,id_number,site_name,s_site_name,contact_f_name,s_contact_f_name,contact_l_name,s_contact_l_name,"CONDITION",s_condition,case_id) AS
select table_subcase.objid, table_subcase.id_number,
 table_site.name, table_site.S_name, table_contact.first_name, table_contact.S_first_name,
 table_contact.last_name, table_contact.S_last_name, table_condition.title, table_condition.S_title,
 table_case.objid
 from table_subcase, table_site, table_contact,
  table_condition, table_case
 where table_site.objid = table_case.case_reporter2site
 AND table_condition.objid = table_subcase.subc_state2condition
 AND table_case.objid = table_subcase.subcase2case
 AND table_contact.objid = table_case.case_reporter2contact
 ;
COMMENT ON TABLE sa.table_v_cls_subc IS 'Data used on the Close subcase form';
COMMENT ON COLUMN sa.table_v_cls_subc.subcase_id IS 'Subcase internal record number';
COMMENT ON COLUMN sa.table_v_cls_subc.id_number IS 'Unique ID number for the subcase; consists of case number-#';
COMMENT ON COLUMN sa.table_v_cls_subc.site_name IS 'Site name';
COMMENT ON COLUMN sa.table_v_cls_subc.contact_f_name IS 'Contact first name';
COMMENT ON COLUMN sa.table_v_cls_subc.contact_l_name IS 'Contact last name';
COMMENT ON COLUMN sa.table_v_cls_subc."CONDITION" IS 'Condition/state title of the object';
COMMENT ON COLUMN sa.table_v_cls_subc.case_id IS 'Case internal record number';