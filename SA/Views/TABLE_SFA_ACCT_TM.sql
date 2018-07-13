CREATE OR REPLACE FORCE VIEW sa.table_sfa_acct_tm (objid,acct_objid,user_objid,empl_objid,con_objid,role_name,s_role_name,member_name,s_member_name,acct_id,s_acct_id,acct_name,s_acct_name,empl_first_name,s_empl_first_name,empl_last_name,s_empl_last_name,empl_phone,empl_fax,empl_beeper,empl_e_mail,con_first_name,s_con_first_name,con_last_name,s_con_last_name,con_phone,con_e_mail,empl_title,empl_salutation,con_title,con_salutation) AS
select table_usr_bus_role.objid, table_bus_org.objid,
 table_user.objid, table_employee.objid,
 table_contact.objid, table_usr_bus_role.role_name, table_usr_bus_role.S_role_name,
 table_user.login_name, table_user.S_login_name, table_bus_org.org_id, table_bus_org.S_org_id,
 table_bus_org.name, table_bus_org.S_name, table_employee.first_name, table_employee.S_first_name,
 table_employee.last_name, table_employee.S_last_name, table_employee.phone,
 table_employee.fax, table_employee.beeper,
 table_employee.e_mail, table_contact.first_name, table_contact.S_first_name,
 table_contact.last_name, table_contact.S_last_name, table_contact.phone,
 table_contact.e_mail, table_employee.title,
 table_employee.salutation, table_contact.title,
 table_contact.salutation
 from table_usr_bus_role, table_bus_org, table_user,
  table_employee, table_contact
 where table_user.objid = table_usr_bus_role.usr_bus_role2user
 AND table_user.objid = table_employee.employee2user (+)
 AND table_bus_org.objid = table_usr_bus_role.usr_bus_role2bus_org
 AND table_user.objid = table_contact.caller2user (+)
 ;
COMMENT ON TABLE sa.table_sfa_acct_tm IS 'Displays account team members. Used by forms Account Manager (11650), Console-Sales (12000)';
COMMENT ON COLUMN sa.table_sfa_acct_tm.objid IS 'Usr_bus_role internal record number';
COMMENT ON COLUMN sa.table_sfa_acct_tm.acct_objid IS 'Bus_org internal record number';
COMMENT ON COLUMN sa.table_sfa_acct_tm.user_objid IS 'User internal record number';
COMMENT ON COLUMN sa.table_sfa_acct_tm.empl_objid IS 'Employee internal record number';
COMMENT ON COLUMN sa.table_sfa_acct_tm.con_objid IS 'Contact internal record number';
COMMENT ON COLUMN sa.table_sfa_acct_tm.role_name IS 'User s account team role';
COMMENT ON COLUMN sa.table_sfa_acct_tm.member_name IS 'User s login name';
COMMENT ON COLUMN sa.table_sfa_acct_tm.acct_id IS 'ID of bus org for which the employee plays a role';
COMMENT ON COLUMN sa.table_sfa_acct_tm.acct_name IS 'Name of bus org for which the employee plays a role';
COMMENT ON COLUMN sa.table_sfa_acct_tm.empl_first_name IS 'Employee s first name';
COMMENT ON COLUMN sa.table_sfa_acct_tm.empl_last_name IS 'Employee s last name';
COMMENT ON COLUMN sa.table_sfa_acct_tm.empl_phone IS 'Employee s phone number';
COMMENT ON COLUMN sa.table_sfa_acct_tm.empl_fax IS 'Employee s fax number which includes area code, number, and extension';
COMMENT ON COLUMN sa.table_sfa_acct_tm.empl_beeper IS 'Employee s beeper number which includes area code and number';
COMMENT ON COLUMN sa.table_sfa_acct_tm.empl_e_mail IS 'Employee s e-mail address';
COMMENT ON COLUMN sa.table_sfa_acct_tm.con_first_name IS 'Contact s first name';
COMMENT ON COLUMN sa.table_sfa_acct_tm.con_last_name IS 'Contact s last name';
COMMENT ON COLUMN sa.table_sfa_acct_tm.con_phone IS 'Contact s phone number';
COMMENT ON COLUMN sa.table_sfa_acct_tm.con_e_mail IS 'Contact s primary e-mail address';
COMMENT ON COLUMN sa.table_sfa_acct_tm.empl_title IS 'Employee s professional title';
COMMENT ON COLUMN sa.table_sfa_acct_tm.empl_salutation IS 'Employee s form of address; e.g., Mr., Miss, Mrs';
COMMENT ON COLUMN sa.table_sfa_acct_tm.con_title IS 'Contact s professional title';
COMMENT ON COLUMN sa.table_sfa_acct_tm.con_salutation IS 'Contact s form of address; e.g., Mr., Miss, Mrs';