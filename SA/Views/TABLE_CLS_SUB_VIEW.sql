CREATE OR REPLACE FORCE VIEW sa.table_cls_sub_view (subcase_id,empl_id,user_id,wip_id,id_number,closer_name,s_closer_name,site_name,s_site_name,contact_f_name,s_contact_f_name,contact_l_name,s_contact_l_name,"CONDITION",s_condition,case_wip_id,case_owner_id) AS
select table_subcase.objid, table_employee.objid,
 table_sub_user.objid, table_subcase.subc_wip2wipbin,
 table_subcase.id_number, table_sub_user.login_name, table_sub_user.S_login_name,
 table_site.name, table_site.S_name, table_contact.first_name, table_contact.S_first_name,
 table_contact.last_name, table_contact.S_last_name, table_condition.title, table_condition.S_title,
 table_case.case_wip2wipbin, table_case.case_owner2user
 from table_user table_sub_user, table_subcase, table_employee, table_site,
  table_contact, table_condition, table_case
 where table_condition.objid = table_subcase.subc_state2condition
 AND table_subcase.subc_wip2wipbin IS NOT NULL
 AND table_case.objid = table_subcase.subcase2case
 AND table_sub_user.objid = table_subcase.subc_owner2user
 AND table_case.case_wip2wipbin IS NOT NULL
 AND table_case.case_owner2user IS NOT NULL
 AND table_site.objid = table_case.case_reporter2site
 AND table_sub_user.objid = table_employee.employee2user
 AND table_contact.objid = table_case.case_reporter2contact
 ;
COMMENT ON TABLE sa.table_cls_sub_view IS 'Reserved; not used';
COMMENT ON COLUMN sa.table_cls_sub_view.subcase_id IS 'Subcase internal record number';
COMMENT ON COLUMN sa.table_cls_sub_view.empl_id IS 'Employee internal record number';
COMMENT ON COLUMN sa.table_cls_sub_view.user_id IS 'User internal record number';
COMMENT ON COLUMN sa.table_cls_sub_view.wip_id IS 'WIPbin internal record number';
COMMENT ON COLUMN sa.table_cls_sub_view.id_number IS 'Unique ID number for the subcase; consists of case number-#';
COMMENT ON COLUMN sa.table_cls_sub_view.closer_name IS 'User login name';
COMMENT ON COLUMN sa.table_cls_sub_view.site_name IS 'Site name';
COMMENT ON COLUMN sa.table_cls_sub_view.contact_f_name IS 'Contact first name';
COMMENT ON COLUMN sa.table_cls_sub_view.contact_l_name IS 'Contact last name';
COMMENT ON COLUMN sa.table_cls_sub_view."CONDITION" IS 'Title of condition';
COMMENT ON COLUMN sa.table_cls_sub_view.case_wip_id IS 'WIPbin internal record number';
COMMENT ON COLUMN sa.table_cls_sub_view.case_owner_id IS 'User internal record number';