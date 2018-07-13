CREATE OR REPLACE FORCE VIEW sa.table_sfa_terr_tm (objid,terr_objid,user_objid,empl_objid,con_objid,role_name,s_role_name,member_name,s_member_name,terr_id,terr_name,s_terr_name,empl_first_name,s_empl_first_name,empl_last_name,s_empl_last_name,empl_phone,empl_fax,empl_beeper,empl_e_mail,con_first_name,s_con_first_name,con_last_name,s_con_last_name,con_phone,con_e_mail,con_fax) AS
select table_usr_ter_role.objid, table_territory.objid,
 table_user.objid, table_employee.objid,
 table_contact.objid, table_usr_ter_role.role_name, table_usr_ter_role.S_role_name,
 table_user.login_name, table_user.S_login_name, table_territory.terr_id,
 table_territory.name, table_territory.S_name, table_employee.first_name, table_employee.S_first_name,
 table_employee.last_name, table_employee.S_last_name, table_employee.phone,
 table_employee.fax, table_employee.beeper,
 table_employee.e_mail, table_contact.first_name, table_contact.S_first_name,
 table_contact.last_name, table_contact.S_last_name, table_contact.phone,
 table_contact.e_mail, table_contact.fax_number
 from table_usr_ter_role, table_territory, table_user,
  table_employee, table_contact
 where table_user.objid = table_usr_ter_role.usr_ter_role2user
 AND table_user.objid = table_employee.employee2user (+)
 AND table_territory.objid = table_usr_ter_role.user_role2territory
 AND table_user.objid = table_contact.caller2user (+)
 ;
COMMENT ON TABLE sa.table_sfa_terr_tm IS 'Displays territor team information. Used by form Accounts (9681, Territory (9680), Hierarchy (9683, Team (9682)';
COMMENT ON COLUMN sa.table_sfa_terr_tm.objid IS 'Usr_ter_role internal record number';
COMMENT ON COLUMN sa.table_sfa_terr_tm.terr_objid IS 'Territory internal record number';
COMMENT ON COLUMN sa.table_sfa_terr_tm.user_objid IS 'User internal record number';
COMMENT ON COLUMN sa.table_sfa_terr_tm.empl_objid IS 'Employee internal record number';
COMMENT ON COLUMN sa.table_sfa_terr_tm.con_objid IS 'Contact internal record number';
COMMENT ON COLUMN sa.table_sfa_terr_tm.role_name IS 'User s territory team role';
COMMENT ON COLUMN sa.table_sfa_terr_tm.member_name IS 'User s login name';
COMMENT ON COLUMN sa.table_sfa_terr_tm.terr_id IS 'User-specified ID number of the territory';
COMMENT ON COLUMN sa.table_sfa_terr_tm.terr_name IS 'Name of territory for which the employee plays a role';
COMMENT ON COLUMN sa.table_sfa_terr_tm.empl_first_name IS 'If the user is an employee, the employee s first name';
COMMENT ON COLUMN sa.table_sfa_terr_tm.empl_last_name IS 'If the user is an employee, the employee s last name';
COMMENT ON COLUMN sa.table_sfa_terr_tm.empl_phone IS 'If the user is an employee, the employee s phone number';
COMMENT ON COLUMN sa.table_sfa_terr_tm.empl_fax IS 'If the user is an employee, the employee s fax number which includes area code, number, and extension';
COMMENT ON COLUMN sa.table_sfa_terr_tm.empl_beeper IS 'If the user is an employee, the employee s beeper number which includes area code and number';
COMMENT ON COLUMN sa.table_sfa_terr_tm.empl_e_mail IS 'If the user is an employee, the employee s e-mail address';
COMMENT ON COLUMN sa.table_sfa_terr_tm.con_first_name IS 'If the user is a contact, the contact s first name';
COMMENT ON COLUMN sa.table_sfa_terr_tm.con_last_name IS 'If the user is a contact, the contact s last name';
COMMENT ON COLUMN sa.table_sfa_terr_tm.con_phone IS 'If the user is a contact, the contact s phone number';
COMMENT ON COLUMN sa.table_sfa_terr_tm.con_e_mail IS 'The contact s e-mail address';
COMMENT ON COLUMN sa.table_sfa_terr_tm.con_fax IS 'The contact s fax number which includes area code, number, and extension';