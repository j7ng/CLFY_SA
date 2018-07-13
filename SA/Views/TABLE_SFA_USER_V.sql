CREATE OR REPLACE FORCE VIEW sa.table_sfa_user_v (objid,empl_objid,con_objid,user_name,s_user_name,empl_first_name,s_empl_first_name,empl_last_name,s_empl_last_name,empl_phone,con_first_name,s_con_first_name,con_last_name,s_con_last_name,con_phone) AS
select table_user.objid, table_employee.objid,
 table_contact.objid, table_user.login_name, table_user.S_login_name,
 table_employee.first_name, table_employee.S_first_name, table_employee.last_name, table_employee.S_last_name,
 table_employee.phone, table_contact.first_name, table_contact.S_first_name,
 table_contact.last_name, table_contact.S_last_name, table_contact.phone
 from table_user, table_employee, table_contact
 where table_user.objid = table_employee.employee2user (+)
 AND table_user.objid = table_contact.caller2user (+)
 ;
COMMENT ON TABLE sa.table_sfa_user_v IS 'Displays contact and employee team members. Used by form Generic LookUp non-modal(20000), Generic LookUp modal (40000), and Select Territory Team (356)';
COMMENT ON COLUMN sa.table_sfa_user_v.objid IS 'User internal record number';
COMMENT ON COLUMN sa.table_sfa_user_v.empl_objid IS 'Employee internal record number';
COMMENT ON COLUMN sa.table_sfa_user_v.con_objid IS 'Contact internal record number';
COMMENT ON COLUMN sa.table_sfa_user_v.user_name IS 'User s login name';
COMMENT ON COLUMN sa.table_sfa_user_v.empl_first_name IS 'If the user is an employee, the employee s first name';
COMMENT ON COLUMN sa.table_sfa_user_v.empl_last_name IS 'If the user is an employee, the employee s last name';
COMMENT ON COLUMN sa.table_sfa_user_v.empl_phone IS 'If the user is an employee, the employee s phone number';
COMMENT ON COLUMN sa.table_sfa_user_v.con_first_name IS 'If the user is a contact, the contact s first name';
COMMENT ON COLUMN sa.table_sfa_user_v.con_last_name IS 'If the user is a contact, the contact s last name';
COMMENT ON COLUMN sa.table_sfa_user_v.con_phone IS 'If the user is a contact, the contact s phone number';