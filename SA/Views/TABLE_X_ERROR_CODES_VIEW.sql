CREATE OR REPLACE FORCE VIEW sa.table_x_error_codes_view (topp_err_codes_objid,x_code_name,x_message,x_mkt_submkt_name,user_login_name,s_user_login_name,x_code_na,x_add_dat,x_add_date,carrier_err_codes_objid,x_carrier_id) AS
select table_x_topp_err_codes.objid, table_x_topp_err_codes.x_code_name,
 table_x_topp_err_codes.x_message, table_x_carrier.x_mkt_submkt_name,
 table_user.login_name, table_user.S_login_name, table_x_carrier_err_codes.x_code_name,
 table_x_carrier_err_codes.x_add_date, table_x_topp_err_codes.x_add_date,
 table_x_carrier_err_codes.objid, table_x_carrier.x_carrier_id
 from table_x_topp_err_codes, table_x_carrier, table_user,
  table_x_carrier_err_codes
 where table_user.objid = table_x_topp_err_codes.x_topp_err_codes2user
 AND table_x_carrier.objid = table_x_carrier_err_codes.x_car_er2x_carrier
 AND table_x_topp_err_codes.objid = table_x_carrier_err_codes.ccodes2x_topp_err_codes
 ;
COMMENT ON TABLE sa.table_x_error_codes_view IS 'custom view';
COMMENT ON COLUMN sa.table_x_error_codes_view.topp_err_codes_objid IS 'Topp error codes internal record number';
COMMENT ON COLUMN sa.table_x_error_codes_view.x_code_name IS 'Topp error code';
COMMENT ON COLUMN sa.table_x_error_codes_view.x_message IS 'Topp error messages';
COMMENT ON COLUMN sa.table_x_error_codes_view.x_mkt_submkt_name IS 'Carrier Market/Submarket Name';
COMMENT ON COLUMN sa.table_x_error_codes_view.user_login_name IS 'User login name';
COMMENT ON COLUMN sa.table_x_error_codes_view.x_code_na IS 'Carrier code name';
COMMENT ON COLUMN sa.table_x_error_codes_view.x_add_dat IS 'Date added';
COMMENT ON COLUMN sa.table_x_error_codes_view.x_add_date IS 'Date added to Table';
COMMENT ON COLUMN sa.table_x_error_codes_view.carrier_err_codes_objid IS 'Carrier error codes internal record number';
COMMENT ON COLUMN sa.table_x_error_codes_view.x_carrier_id IS 'Carrier Market Identification Number';