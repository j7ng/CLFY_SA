CREATE OR REPLACE FORCE VIEW sa.table_x_ship_master_view (x_courier_name,x_courier_id,x_ff_code,x_ff_name,x_objid,x_zip_code,x_weight,x_shipping_cost,x_shipping_method,x_service_level) AS
select table_x_courier.x_courier_name, table_x_courier.x_courier_id,
 table_x_ff_center.x_ff_code, table_x_ff_center.x_ff_name,
 table_x_shipping_master.objid, table_x_shipping_master.x_zip_code,
 table_x_shipping_master.x_weight, table_x_shipping_master.x_shipping_cost,
 table_x_shipping_method.x_shipping_method, table_x_shipping_master.x_service_level
 from table_x_courier, table_x_ff_center, table_x_shipping_master,
  table_x_shipping_method
 where table_x_ff_center.objid = table_x_shipping_master.master2ff_center
 AND table_x_shipping_method.objid = table_x_shipping_master.master2method
 AND table_x_courier.objid = table_x_shipping_master.master2courier
 ;
COMMENT ON TABLE sa.table_x_ship_master_view IS 'Shipping Master View';
COMMENT ON COLUMN sa.table_x_ship_master_view.x_courier_name IS 'Long Name Courier Provider';
COMMENT ON COLUMN sa.table_x_ship_master_view.x_courier_id IS 'Courier ID, DHL,FEDEX,UPS,etc.';
COMMENT ON COLUMN sa.table_x_ship_master_view.x_ff_code IS 'fulfillment center code';
COMMENT ON COLUMN sa.table_x_ship_master_view.x_ff_name IS 'fulfillment center name';
COMMENT ON COLUMN sa.table_x_ship_master_view.x_objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_x_ship_master_view.x_zip_code IS 'Destination Zip Code';
COMMENT ON COLUMN sa.table_x_ship_master_view.x_weight IS 'Weight of the package LETTER,1LB,2LB';
COMMENT ON COLUMN sa.table_x_ship_master_view.x_shipping_cost IS 'Dollar value of the shipping cost';
COMMENT ON COLUMN sa.table_x_ship_master_view.x_shipping_method IS 'Service Name for Shipping Method';
COMMENT ON COLUMN sa.table_x_ship_master_view.x_service_level IS 'Number of Days for Delivery';