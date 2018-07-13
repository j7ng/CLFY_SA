CREATE OR REPLACE FORCE VIEW sa.table_x_topp_errors_view (objid,x_code_name,x_message,x_add_date,user_login_name,s_user_login_name) AS
select table_x_topp_err_codes.objid, table_x_topp_err_codes.x_code_name,
 table_x_topp_err_codes.x_message, table_x_topp_err_codes.x_add_date,
 table_user.login_name, table_user.S_login_name
 from table_x_topp_err_codes, table_user
 where table_user.objid = table_x_topp_err_codes.x_topp_err_codes2user
 ;
COMMENT ON TABLE sa.table_x_topp_errors_view IS 'custom view for error codes';
COMMENT ON COLUMN sa.table_x_topp_errors_view.objid IS 'Topp error codes internal record number';
COMMENT ON COLUMN sa.table_x_topp_errors_view.x_code_name IS 'Topp error code';
COMMENT ON COLUMN sa.table_x_topp_errors_view.x_message IS 'Topp error messages';
COMMENT ON COLUMN sa.table_x_topp_errors_view.x_add_date IS 'Date added to Table';
COMMENT ON COLUMN sa.table_x_topp_errors_view.user_login_name IS 'User login name';