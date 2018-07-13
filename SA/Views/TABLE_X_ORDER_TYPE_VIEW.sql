CREATE OR REPLACE FORCE VIEW sa.table_x_order_type_view (x_order_type_objid,x_transmit_method,x_fax_number,x_online_number,x_network_login,x_network_password,x_system_login,x_system_password,x_template,x_email,x_order_type,x_profile_name,x_npa,x_nxx,x_bill_cycle,x_carrier_objid,x_account_num,x_dealer_code,x_market_code,x_mkt_submkt_name,x_trans_objid,x_carrier_id,x_description,x_transmit_template) AS
select table_x_order_type.objid, table_x_trans_profile.x_transmit_method,
 table_x_trans_profile.x_fax_number, table_x_trans_profile.x_online_number,
 table_x_trans_profile.x_network_login, table_x_trans_profile.x_network_password,
 table_x_trans_profile.x_system_login, table_x_trans_profile.x_system_password,
 table_x_trans_profile.x_template, table_x_trans_profile.x_email,
 table_x_order_type.x_order_type, table_x_trans_profile.x_profile_name,
 table_x_order_type.x_NPA, table_x_order_type.x_NXX,
 table_x_order_type.x_bill_cycle, table_x_carrier.objid,
 table_x_order_type.x_ld_account_num, table_x_order_type.x_dealer_code,
 table_x_order_type.x_market_code, table_x_carrier.x_mkt_submkt_name,
 table_x_trans_profile.objid, table_x_carrier.x_carrier_id,
 table_x_trans_profile.x_description, table_x_trans_profile.x_transmit_template
 from table_x_order_type, table_x_trans_profile, table_x_carrier
 where table_x_trans_profile.objid (+) = table_x_order_type.x_order_type2x_trans_profile
 AND table_x_carrier.objid = table_x_order_type.x_order_type2x_carrier
 ;
COMMENT ON TABLE sa.table_x_order_type_view IS 'custom view for order types and transmission profiles';
COMMENT ON COLUMN sa.table_x_order_type_view.x_order_type_objid IS 'Topp x_order_type internal record number';
COMMENT ON COLUMN sa.table_x_order_type_view.x_transmit_method IS 'transmission method';
COMMENT ON COLUMN sa.table_x_order_type_view.x_fax_number IS 'fax phone number';
COMMENT ON COLUMN sa.table_x_order_type_view.x_online_number IS 'Dial up phone number';
COMMENT ON COLUMN sa.table_x_order_type_view.x_network_login IS 'network login';
COMMENT ON COLUMN sa.table_x_order_type_view.x_network_password IS 'network password';
COMMENT ON COLUMN sa.table_x_order_type_view.x_system_login IS 'system login';
COMMENT ON COLUMN sa.table_x_order_type_view.x_system_password IS 'system password';
COMMENT ON COLUMN sa.table_x_order_type_view.x_template IS 'file path or template name';
COMMENT ON COLUMN sa.table_x_order_type_view.x_email IS 'email address';
COMMENT ON COLUMN sa.table_x_order_type_view.x_order_type IS 'x_order_type';
COMMENT ON COLUMN sa.table_x_order_type_view.x_profile_name IS 'Name of the profile';
COMMENT ON COLUMN sa.table_x_order_type_view.x_npa IS 'x_order_type';
COMMENT ON COLUMN sa.table_x_order_type_view.x_nxx IS 'x_order_type';
COMMENT ON COLUMN sa.table_x_order_type_view.x_bill_cycle IS 'x_order_type';
COMMENT ON COLUMN sa.table_x_order_type_view.x_carrier_objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_x_order_type_view.x_account_num IS 'x_order_type';
COMMENT ON COLUMN sa.table_x_order_type_view.x_dealer_code IS 'x_order_type';
COMMENT ON COLUMN sa.table_x_order_type_view.x_market_code IS 'x_order_type';
COMMENT ON COLUMN sa.table_x_order_type_view.x_mkt_submkt_name IS 'Carrier Market/Submarket Name';
COMMENT ON COLUMN sa.table_x_order_type_view.x_trans_objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_x_order_type_view.x_carrier_id IS 'Carrier Market Identification Number';
COMMENT ON COLUMN sa.table_x_order_type_view.x_description IS 'Added for description of trans profile on 7/19/00';
COMMENT ON COLUMN sa.table_x_order_type_view.x_transmit_template IS 'TBD';