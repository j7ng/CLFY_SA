CREATE OR REPLACE FORCE VIEW sa.table_cls_case_view (case_id,empl_id,user_id,wip_id,id_number,closer_name,s_closer_name,site_name,s_site_name,contact_f_name,s_contact_f_name,contact_l_name,s_contact_l_name,"CONDITION",s_condition) AS
select table_case.objid, table_employee.objid,
 table_user.objid, table_case.case_wip2wipbin,
 table_case.id_number, table_user.login_name, table_user.S_login_name,
 table_site.name, table_site.S_name, table_contact.first_name, table_contact.S_first_name,
 table_contact.last_name, table_contact.S_last_name, table_condition.title, table_condition.S_title
 from table_case, table_employee, table_user,
  table_site, table_contact, table_condition
 where table_case.case_wip2wipbin IS NOT NULL
 AND table_user.objid = table_case.case_owner2user
 AND table_site.objid = table_case.case_reporter2site
 AND table_condition.objid = table_case.case_state2condition
 AND table_contact.objid = table_case.case_reporter2contact
 AND table_user.objid = table_employee.employee2user
 ;
COMMENT ON TABLE sa.table_cls_case_view IS 'View close case information';
COMMENT ON COLUMN sa.table_cls_case_view.case_id IS 'Case internal record number';
COMMENT ON COLUMN sa.table_cls_case_view.empl_id IS 'Employee internal record number';
COMMENT ON COLUMN sa.table_cls_case_view.user_id IS 'User internal record number';
COMMENT ON COLUMN sa.table_cls_case_view.wip_id IS 'WIPbin internal record number';
COMMENT ON COLUMN sa.table_cls_case_view.id_number IS 'Unique case number assigned based on auto-numbering definition';
COMMENT ON COLUMN sa.table_cls_case_view.closer_name IS 'User login name';
COMMENT ON COLUMN sa.table_cls_case_view.site_name IS 'Site name';
COMMENT ON COLUMN sa.table_cls_case_view.contact_f_name IS 'Contact first name';
COMMENT ON COLUMN sa.table_cls_case_view.contact_l_name IS 'Contact last name';
COMMENT ON COLUMN sa.table_cls_case_view."CONDITION" IS 'Title of condition';