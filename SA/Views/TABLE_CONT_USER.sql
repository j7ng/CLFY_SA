CREATE OR REPLACE FORCE VIEW sa.table_cont_user (user_id,login_name,s_login_name,first_name,s_first_name,last_name,s_last_name,status) AS
select table_user.objid, table_user.login_name, table_user.S_login_name,
 table_contact.first_name, table_contact.S_first_name, table_contact.last_name, table_contact.S_last_name,
 table_user.status
 from table_user, table_contact
 where table_user.objid = table_contact.caller2user
 ;
COMMENT ON TABLE sa.table_cont_user IS 'Join user and contact';
COMMENT ON COLUMN sa.table_cont_user.user_id IS 'User object ID';
COMMENT ON COLUMN sa.table_cont_user.login_name IS 'User login name';
COMMENT ON COLUMN sa.table_cont_user.first_name IS 'Contact first name';
COMMENT ON COLUMN sa.table_cont_user.last_name IS 'Contact last name';
COMMENT ON COLUMN sa.table_cont_user.status IS 'User status; i.e., 0=inactive, 1=active, default=1';