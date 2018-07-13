CREATE OR REPLACE FORCE VIEW sa.table_terr_empl_view (objid,role_name,employee_no,last_name,s_last_name,first_name,s_first_name,terr_name,s_terr_name,end_date,terr_id,phone,terr_objid,login_name,s_login_name,fax,beeper,e_mail,empl_objid) AS
select table_emp_ter_role.objid, table_emp_ter_role.role_name,
 table_employee.employee_no, table_employee.last_name, table_employee.S_last_name,
 table_employee.first_name, table_employee.S_first_name, table_territory.name, table_territory.S_name,
 table_territory.end_date, table_territory.terr_id,
 table_employee.phone, table_territory.objid,
 table_user.login_name, table_user.S_login_name, table_employee.fax,
 table_employee.beeper, table_employee.e_mail,
 table_employee.objid
 from table_emp_ter_role, table_employee, table_territory,
  table_user
 where table_user.objid = table_employee.employee2user
 AND table_territory.objid = table_emp_ter_role.emp_ter_role2territory
 AND table_employee.objid = table_emp_ter_role.emp_ter_role2employee
 ;
COMMENT ON TABLE sa.table_terr_empl_view IS 'Territory assignments for employees. Reserved; obsolete. Replaced by view sfa_terr_tm (5349)';
COMMENT ON COLUMN sa.table_terr_empl_view.objid IS 'emp_ter_role internal record number';
COMMENT ON COLUMN sa.table_terr_empl_view.role_name IS 'The name of the role';
COMMENT ON COLUMN sa.table_terr_empl_view.employee_no IS 'Site ID number assigned according to auto-numbering definition';
COMMENT ON COLUMN sa.table_terr_empl_view.last_name IS 'Employee s last name';
COMMENT ON COLUMN sa.table_terr_empl_view.first_name IS 'Employee s first name';
COMMENT ON COLUMN sa.table_terr_empl_view.terr_name IS 'Name of the territory';
COMMENT ON COLUMN sa.table_terr_empl_view.end_date IS 'End date of the territory';
COMMENT ON COLUMN sa.table_terr_empl_view.terr_id IS 'ID of the territory';
COMMENT ON COLUMN sa.table_terr_empl_view.phone IS 'Employee s primary phone number which includes area code, number, and extension';
COMMENT ON COLUMN sa.table_terr_empl_view.terr_objid IS 'Territroy internal record number';
COMMENT ON COLUMN sa.table_terr_empl_view.login_name IS 'User login name';
COMMENT ON COLUMN sa.table_terr_empl_view.fax IS 'Employee s fax number which includes area code, number and extension';
COMMENT ON COLUMN sa.table_terr_empl_view.beeper IS 'Employee s beeper number which includes area code and number';
COMMENT ON COLUMN sa.table_terr_empl_view.e_mail IS 'Employee s e-mail address';
COMMENT ON COLUMN sa.table_terr_empl_view.empl_objid IS 'Employee internal record number';