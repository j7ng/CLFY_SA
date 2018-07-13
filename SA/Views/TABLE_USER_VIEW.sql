CREATE OR REPLACE FORCE VIEW sa.table_user_view (objid,"NAME",s_name,status) AS
select table_user.objid, table_user.login_name, table_user.S_login_name,
 table_user.status
 from table_user;
COMMENT ON TABLE sa.table_user_view IS 'Selects a user s status; i.e., active/inactive';
COMMENT ON COLUMN sa.table_user_view.objid IS 'User internal record number';
COMMENT ON COLUMN sa.table_user_view."NAME" IS 'User login name';
COMMENT ON COLUMN sa.table_user_view.status IS 'User status; i.e., 0=inactive, 1=active, default=1';