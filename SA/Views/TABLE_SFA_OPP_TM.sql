CREATE OR REPLACE FORCE VIEW sa.table_sfa_opp_tm (objid,opp_objid,user_objid,empl_objid,con_objid,role_name,s_role_name,member_name,s_member_name,opp_id,s_opp_id,opp_name,s_opp_name,empl_first_name,s_empl_first_name,empl_last_name,s_empl_last_name,empl_phone,empl_fax,empl_beeper,empl_e_mail,con_first_name,s_con_first_name,con_last_name,s_con_last_name,con_phone,con_e_mail,empl_title,empl_salutation,con_title,con_salutation) AS
select table_usr_opp_role.objid, table_opportunity.objid,
 table_user.objid, table_employee.objid,
 table_contact.objid, table_usr_opp_role.role_name, table_usr_opp_role.S_role_name,
 table_user.login_name, table_user.S_login_name, table_opportunity.id, table_opportunity.S_id,
 table_opportunity.name, table_opportunity.S_name, table_employee.first_name, table_employee.S_first_name,
 table_employee.last_name, table_employee.S_last_name, table_employee.phone,
 table_employee.fax, table_employee.beeper,
 table_employee.e_mail, table_contact.first_name, table_contact.S_first_name,
 table_contact.last_name, table_contact.S_last_name, table_contact.phone,
 table_contact.e_mail, table_employee.title,
 table_employee.salutation, table_contact.title,
 table_contact.salutation
 from table_usr_opp_role, table_opportunity, table_user,
  table_employee, table_contact
 where table_user.objid = table_usr_opp_role.opp_role2user
 AND table_user.objid = table_contact.caller2user (+)
 AND table_opportunity.objid = table_usr_opp_role.usr_role2opportunity
 AND table_user.objid = table_employee.employee2user (+)
 ;
COMMENT ON TABLE sa.table_sfa_opp_tm IS 'Displays opportunity team members. Used by forms Console-Sales (12000) and Opportunity Mgr (13000)';
COMMENT ON COLUMN sa.table_sfa_opp_tm.objid IS 'User internal record number';
COMMENT ON COLUMN sa.table_sfa_opp_tm.opp_objid IS 'Opportunity internal record number';
COMMENT ON COLUMN sa.table_sfa_opp_tm.user_objid IS 'User internal record number';
COMMENT ON COLUMN sa.table_sfa_opp_tm.empl_objid IS 'Employee internal record number';
COMMENT ON COLUMN sa.table_sfa_opp_tm.con_objid IS 'Contact internal record number';
COMMENT ON COLUMN sa.table_sfa_opp_tm.role_name IS 'User s opportunity team role name';
COMMENT ON COLUMN sa.table_sfa_opp_tm.member_name IS 'User login name';
COMMENT ON COLUMN sa.table_sfa_opp_tm.opp_id IS 'ID of opportunity for which the user plays a role';
COMMENT ON COLUMN sa.table_sfa_opp_tm.opp_name IS 'Name of opportunity for which the user plays a role';
COMMENT ON COLUMN sa.table_sfa_opp_tm.empl_first_name IS 'If the user is an employee, the employee s first name';
COMMENT ON COLUMN sa.table_sfa_opp_tm.empl_last_name IS ' If the user is an employee, the employee s last name';
COMMENT ON COLUMN sa.table_sfa_opp_tm.empl_phone IS 'If the user is an employee, the employee s phone number';
COMMENT ON COLUMN sa.table_sfa_opp_tm.empl_fax IS 'If the user is an employee, the employee s fax number which includes area code, number, and extension';
COMMENT ON COLUMN sa.table_sfa_opp_tm.empl_beeper IS 'If the user is an employee, the employee s beeper number which includes area code and number';
COMMENT ON COLUMN sa.table_sfa_opp_tm.empl_e_mail IS 'If the user is an employee, the employee s e-mail address';
COMMENT ON COLUMN sa.table_sfa_opp_tm.con_first_name IS 'If the user is a contact, the contact s first name';
COMMENT ON COLUMN sa.table_sfa_opp_tm.con_last_name IS 'If the user is a contact, the contact s last name';
COMMENT ON COLUMN sa.table_sfa_opp_tm.con_phone IS 'If the user is a contact, the contact s phone number';
COMMENT ON COLUMN sa.table_sfa_opp_tm.con_e_mail IS 'Contact s primary e-mail address';
COMMENT ON COLUMN sa.table_sfa_opp_tm.empl_title IS 'Employee s professional title';
COMMENT ON COLUMN sa.table_sfa_opp_tm.empl_salutation IS 'Employee s form of address; e.g., Mr., Miss, Mrs';
COMMENT ON COLUMN sa.table_sfa_opp_tm.con_title IS 'Contact s professional title';
COMMENT ON COLUMN sa.table_sfa_opp_tm.con_salutation IS 'Contact s form of address; e.g., Mr., Miss, Mrs';