CREATE OR REPLACE FORCE VIEW sa.table_acct_team (role_name,first_name,s_first_name,last_name,s_last_name,site_id,login_name,s_login_name,phone,fax,beeper,e_mail,org_id,s_org_id,org_name,s_org_name,role_objid) AS
select table_bus_empl_role.role_name, table_employee.first_name, table_employee.S_first_name,
 table_employee.last_name, table_employee.S_last_name, table_employee.supp_person_off2site,
 table_user.login_name, table_user.S_login_name, table_employee.phone,
 table_employee.fax, table_employee.beeper,
 table_employee.e_mail, table_bus_org.org_id, table_bus_org.S_org_id,
 table_bus_org.name, table_bus_org.S_name, table_bus_empl_role.objid
 from table_bus_empl_role, table_employee, table_user,
  table_bus_org
 where table_user.objid = table_employee.employee2user
 AND table_employee.objid = table_bus_empl_role.bus_empl_role2employee
 AND table_bus_org.objid = table_bus_empl_role.bus_empl_role2bus_org
 AND table_employee.supp_person_off2site IS NOT NULL
 ;
COMMENT ON TABLE sa.table_acct_team IS 'Displays account team members. Used by Account Team Form (8504)';
COMMENT ON COLUMN sa.table_acct_team.role_name IS 'Name of the account team role';
COMMENT ON COLUMN sa.table_acct_team.first_name IS 'Employee s first name';
COMMENT ON COLUMN sa.table_acct_team.last_name IS 'Employee s last name';
COMMENT ON COLUMN sa.table_acct_team.site_id IS 'Site internal record number';
COMMENT ON COLUMN sa.table_acct_team.login_name IS 'User login name';
COMMENT ON COLUMN sa.table_acct_team.phone IS 'Employee s phone number';
COMMENT ON COLUMN sa.table_acct_team.fax IS 'Employee s fax number which includes area code, number, and extension';
COMMENT ON COLUMN sa.table_acct_team.beeper IS 'Employee s beeper number which includes area code and number';
COMMENT ON COLUMN sa.table_acct_team.e_mail IS 'Employee s e-mail address';
COMMENT ON COLUMN sa.table_acct_team.org_id IS 'ID of bus org for which the employee plays a role';
COMMENT ON COLUMN sa.table_acct_team.org_name IS 'Name of bus org for which the employee plays a role';
COMMENT ON COLUMN sa.table_acct_team.role_objid IS 'Internal record number of the employee s business  role';