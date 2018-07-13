CREATE OR REPLACE FORCE VIEW sa.table_x_profile_view (carrier_objid,profile_objid,profile_name,market_name,order_type) AS
select table_x_carrier.objid, table_x_trans_profile.objid,
 table_x_trans_profile.x_profile_name, table_x_carrier.x_mkt_submkt_name,
 table_x_order_type.x_order_type
 from table_x_carrier, table_x_trans_profile, table_x_order_type
 where table_x_trans_profile.objid = table_x_order_type.x_order_type2x_trans_profile
 AND table_x_carrier.objid = table_x_order_type.x_order_type2x_carrier
 ;
COMMENT ON TABLE sa.table_x_profile_view IS 'custom view';
COMMENT ON COLUMN sa.table_x_profile_view.carrier_objid IS 'Carrier Objid';
COMMENT ON COLUMN sa.table_x_profile_view.profile_objid IS 'Transmission Profile objids';
COMMENT ON COLUMN sa.table_x_profile_view.profile_name IS 'Name of the profile';
COMMENT ON COLUMN sa.table_x_profile_view.market_name IS 'Carrier Market/Submarket Name';
COMMENT ON COLUMN sa.table_x_profile_view.order_type IS 'x_order_type';