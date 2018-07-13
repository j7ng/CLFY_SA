CREATE TABLE sa.table_x_shipping_master (
  objid NUMBER,
  dev NUMBER,
  x_zip_code VARCHAR2(5 BYTE),
  x_service_level NUMBER,
  x_weight VARCHAR2(10 BYTE),
  x_shipping_cost NUMBER(19,4),
  master2courier NUMBER,
  master2method NUMBER,
  master2ff_center NUMBER
);
ALTER TABLE sa.table_x_shipping_master ADD SUPPLEMENTAL LOG GROUP dmtsora1910305296_0 (dev, master2courier, master2ff_center, master2method, objid, x_service_level, x_shipping_cost, x_weight, x_zip_code) ALWAYS;
COMMENT ON TABLE sa.table_x_shipping_master IS 'Cost associated to shipping services';
COMMENT ON COLUMN sa.table_x_shipping_master.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_x_shipping_master.dev IS 'Row version number for mobile distribution purposes';
COMMENT ON COLUMN sa.table_x_shipping_master.x_zip_code IS 'Destination Zip Code';
COMMENT ON COLUMN sa.table_x_shipping_master.x_service_level IS 'Number of Days for Delivery';
COMMENT ON COLUMN sa.table_x_shipping_master.x_weight IS 'Weight of the package LETTER,1LB,2LB';
COMMENT ON COLUMN sa.table_x_shipping_master.x_shipping_cost IS 'Dollar value of the shipping cost';
COMMENT ON COLUMN sa.table_x_shipping_master.master2courier IS 'TBD';
COMMENT ON COLUMN sa.table_x_shipping_master.master2method IS 'TBD';
COMMENT ON COLUMN sa.table_x_shipping_master.master2ff_center IS 'TBD';