CREATE OR REPLACE FORCE VIEW sa.table_rc_user (user_id,rc_name,login_name,s_login_name,first_name,s_first_name,last_name,s_last_name) AS
select table_user.objid, table_rc_config.name,
 table_user.login_name, table_user.S_login_name, table_employee.first_name, table_employee.S_first_name,
 table_employee.last_name, table_employee.S_last_name
 from table_user, table_rc_config, table_employee
 where table_rc_config.objid = table_user.user2rc_config
 AND table_user.objid = table_employee.employee2user
 ;
COMMENT ON TABLE sa.table_rc_user IS 'Used by form Resource Config <Title> (10043), <Configuration> Membership (10044)';
COMMENT ON COLUMN sa.table_rc_user.user_id IS 'User object ID';
COMMENT ON COLUMN sa.table_rc_user.rc_name IS 'Name of the resource configuration';
COMMENT ON COLUMN sa.table_rc_user.login_name IS 'User login name';
COMMENT ON COLUMN sa.table_rc_user.first_name IS 'Employee first name';
COMMENT ON COLUMN sa.table_rc_user.last_name IS 'Employee last name';