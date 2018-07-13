CREATE TABLE sa.table_x_courier (
  objid NUMBER,
  dev NUMBER,
  x_courier_id VARCHAR2(10 BYTE),
  x_courier_name VARCHAR2(50 BYTE),
  x_po_box NUMBER,
  courier_website VARCHAR2(255 BYTE),
  courier_tracking_link VARCHAR2(255 BYTE)
);
ALTER TABLE sa.table_x_courier ADD SUPPLEMENTAL LOG GROUP dmtsora2146864497_0 (dev, objid, x_courier_id, x_courier_name, x_po_box) ALWAYS;
COMMENT ON TABLE sa.table_x_courier IS 'Courier Providers';
COMMENT ON COLUMN sa.table_x_courier.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_x_courier.dev IS 'Row version number for mobile distribution purposes';
COMMENT ON COLUMN sa.table_x_courier.x_courier_id IS 'Courier ID, DHL,FEDEX,UPS,etc.';
COMMENT ON COLUMN sa.table_x_courier.x_courier_name IS 'Long Name Courier Provider';
COMMENT ON COLUMN sa.table_x_courier.x_po_box IS 'Ships to PO Box, 0=No, 1=Yes';
COMMENT ON COLUMN sa.table_x_courier.courier_website IS 'The couriers website i.e. www.fedex.com';
COMMENT ON COLUMN sa.table_x_courier.courier_tracking_link IS 'The couriers link use to track a package when the couriers tracking number is concatenated ';