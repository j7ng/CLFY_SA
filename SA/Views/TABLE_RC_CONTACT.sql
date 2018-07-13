CREATE OR REPLACE FORCE VIEW sa.table_rc_contact (user_id,rc_name,login_name,s_login_name,first_name,s_first_name,last_name,s_last_name) AS
select table_user.objid, table_rc_config.name,
 table_user.login_name, table_user.S_login_name, table_contact.first_name, table_contact.S_first_name,
 table_contact.last_name, table_contact.S_last_name
 from table_user, table_rc_config, table_contact
 where table_user.objid = table_contact.caller2user
 AND table_rc_config.objid = table_user.user2rc_config
 ;
COMMENT ON TABLE sa.table_rc_contact IS 'Joins attachment to its doc_path';
COMMENT ON COLUMN sa.table_rc_contact.user_id IS 'User internal record number';
COMMENT ON COLUMN sa.table_rc_contact.rc_name IS 'Name of the resource configuration';
COMMENT ON COLUMN sa.table_rc_contact.login_name IS 'User login name';
COMMENT ON COLUMN sa.table_rc_contact.first_name IS 'Contact first name';
COMMENT ON COLUMN sa.table_rc_contact.last_name IS 'Contact last name';