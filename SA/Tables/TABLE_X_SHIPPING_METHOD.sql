CREATE TABLE sa.table_x_shipping_method (
  objid NUMBER,
  dev NUMBER,
  x_shipping_method VARCHAR2(30 BYTE),
  method2courier NUMBER,
  x_alt_name VARCHAR2(30 BYTE),
  x_scac VARCHAR2(30 BYTE)
);
ALTER TABLE sa.table_x_shipping_method ADD SUPPLEMENTAL LOG GROUP dmtsora401883224_0 (dev, method2courier, objid, x_shipping_method) ALWAYS;
COMMENT ON TABLE sa.table_x_shipping_method IS 'Different Services provider by Couriers';
COMMENT ON COLUMN sa.table_x_shipping_method.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_x_shipping_method.dev IS 'Row version number for mobile distribution purposes';
COMMENT ON COLUMN sa.table_x_shipping_method.x_shipping_method IS 'Service Name for Shipping Method';
COMMENT ON COLUMN sa.table_x_shipping_method.method2courier IS 'TBD';