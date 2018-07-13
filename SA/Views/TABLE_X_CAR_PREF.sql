CREATE OR REPLACE FORCE VIEW sa.table_x_car_pref (objid,pref_car_objid,pref_car_id,pref_car_name,sec_car_objid,sec_car_id,sec_car_name) AS
select table_x_carrierpreference.objid, table_pref_car.objid,
 table_pref_car.x_carrier_id, table_pref_car.x_mkt_submkt_name,
 table_sec_car.objid, table_sec_car.x_carrier_id,
 table_sec_car.x_mkt_submkt_name
 from table_x_carrier table_pref_car, table_x_carrier table_sec_car, table_x_carrierpreference
 where table_sec_car.objid = table_x_carrierpreference.x_secondary2x_carrier
 AND table_pref_car.objid = table_x_carrierpreference.x_preferred2x_carrier
 ;
COMMENT ON TABLE sa.table_x_car_pref IS 'custom view';
COMMENT ON COLUMN sa.table_x_car_pref.objid IS 'Preferred Carrier internal record number';
COMMENT ON COLUMN sa.table_x_car_pref.pref_car_objid IS 'Preferred Carrier internal record number';
COMMENT ON COLUMN sa.table_x_car_pref.pref_car_id IS 'Preferred Carrier market ID number';
COMMENT ON COLUMN sa.table_x_car_pref.pref_car_name IS 'Preferred Carrier market name';
COMMENT ON COLUMN sa.table_x_car_pref.sec_car_objid IS 'Secondary Carrier internal record number';
COMMENT ON COLUMN sa.table_x_car_pref.sec_car_id IS 'Secondary Carrier market ID number';
COMMENT ON COLUMN sa.table_x_car_pref.sec_car_name IS 'Secondary Carrier market name';