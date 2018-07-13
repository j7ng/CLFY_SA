CREATE OR REPLACE FORCE VIEW sa.table_x_topp_error_view (topp_err_codes_objid,x_code_name,x_message,user_login_name,s_user_login_name,x_add_date) AS
select table_x_topp_err_codes.objid, table_x_topp_err_codes.x_code_name,
 table_x_topp_err_codes.x_message, table_user.login_name, table_user.S_login_name,
 table_x_topp_err_codes.x_add_date
 from table_x_topp_err_codes, table_user
 where table_user.objid = table_x_topp_err_codes.x_topp_err_codes2user
 ;
COMMENT ON TABLE sa.table_x_topp_error_view IS 'custom view';
COMMENT ON COLUMN sa.table_x_topp_error_view.topp_err_codes_objid IS 'Topp error codes internal record number';
COMMENT ON COLUMN sa.table_x_topp_error_view.x_code_name IS 'Topp error code';
COMMENT ON COLUMN sa.table_x_topp_error_view.x_message IS 'Topp error messages';
COMMENT ON COLUMN sa.table_x_topp_error_view.user_login_name IS 'User login name';
COMMENT ON COLUMN sa.table_x_topp_error_view.x_add_date IS 'Date added to Table';