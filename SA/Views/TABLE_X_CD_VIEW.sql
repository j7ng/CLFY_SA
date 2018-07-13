CREATE OR REPLACE FORCE VIEW sa.table_x_cd_view (objid,carrier_objid,x_carrier_id,x_carrier_name,dealer_objid,dealer_id,dealer_name,s_dealer_name) AS
select table_x_carrierdealer.objid, table_x_carrier.objid,
 table_x_carrier.x_carrier_id, table_x_carrier.x_mkt_submkt_name,
 table_site.objid, table_site.site_id,
 table_site.name, table_site.S_name
 from table_x_carrierdealer, table_x_carrier, table_site
 where table_site.objid = table_x_carrierdealer.x_cd2site
 AND table_x_carrier.objid = table_x_carrierdealer.x_cd2x_carrier
 ;
COMMENT ON TABLE sa.table_x_cd_view IS 'custom view for x_carrierdealer table';
COMMENT ON COLUMN sa.table_x_cd_view.objid IS 'Preferred Carrier internal record number';
COMMENT ON COLUMN sa.table_x_cd_view.carrier_objid IS 'Preferred Carrier internal record number';
COMMENT ON COLUMN sa.table_x_cd_view.x_carrier_id IS 'Preferred Carrier market ID number';
COMMENT ON COLUMN sa.table_x_cd_view.x_carrier_name IS 'Preferred Carrier market name';
COMMENT ON COLUMN sa.table_x_cd_view.dealer_objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_x_cd_view.dealer_id IS 'Unique site number assigned according to auto-numbering definition';
COMMENT ON COLUMN sa.table_x_cd_view.dealer_name IS 'Name of the site';