CREATE OR REPLACE FORCE VIEW sa.table_x_carrier_errors (carrier_view_objid,x_mkt_submkt_name,x_topp_error,x_carrier_err,x_add_date,x_carrier_id) AS
select table_x_carrier_err_codes.objid, table_x_carrier.x_mkt_submkt_name,
 table_x_topp_err_codes.x_code_name, table_x_carrier_err_codes.x_code_name,
 table_x_carrier_err_codes.x_add_date, table_x_carrier.x_carrier_id
 from table_x_carrier_err_codes, table_x_carrier, table_x_topp_err_codes
 where table_x_carrier.objid = table_x_carrier_err_codes.x_car_er2x_carrier
 AND table_x_topp_err_codes.objid = table_x_carrier_err_codes.ccodes2x_topp_err_codes
 ;
COMMENT ON TABLE sa.table_x_carrier_errors IS 'custom view';
COMMENT ON COLUMN sa.table_x_carrier_errors.carrier_view_objid IS 'Carrier market objids';
COMMENT ON COLUMN sa.table_x_carrier_errors.x_mkt_submkt_name IS 'Carrier Market/Submarket Name';
COMMENT ON COLUMN sa.table_x_carrier_errors.x_topp_error IS 'Topp error code';
COMMENT ON COLUMN sa.table_x_carrier_errors.x_carrier_err IS 'Carrier code name';
COMMENT ON COLUMN sa.table_x_carrier_errors.x_add_date IS 'Date added';
COMMENT ON COLUMN sa.table_x_carrier_errors.x_carrier_id IS 'Carrier Market Identification Number';