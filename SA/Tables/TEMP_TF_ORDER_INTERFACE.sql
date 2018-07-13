CREATE TABLE sa.temp_tf_order_interface (
  creation_date DATE,
  customer_number VARCHAR2(100 BYTE),
  store_number VARCHAR2(100 BYTE),
  po_number VARCHAR2(100 BYTE),
  tf_part_number VARCHAR2(100 BYTE),
  quantity NUMBER,
  processed_flag VARCHAR2(1 BYTE),
  delivery_date DATE,
  "SOURCE" VARCHAR2(100 BYTE),
  process_date DATE,
  error_description VARCHAR2(100 BYTE),
  ship_to_name VARCHAR2(240 BYTE),
  ship_to_address VARCHAR2(240 BYTE),
  ship_to_city VARCHAR2(240 BYTE),
  ship_to_state VARCHAR2(240 BYTE),
  ship_to_zip VARCHAR2(240 BYTE),
  ship_to_phone VARCHAR2(240 BYTE),
  title VARCHAR2(80 BYTE),
  status VARCHAR2(1000 BYTE),
  ship_to_email VARCHAR2(80 BYTE),
  tf_generic_part VARCHAR2(100 BYTE),
  ff_name VARCHAR2(30 BYTE),
  carrier VARCHAR2(50 BYTE),
  "METHOD" VARCHAR2(50 BYTE),
  ship_to_address2 VARCHAR2(240 BYTE),
  line_number NUMBER,
  llid VARCHAR2(20 BYTE),
  insert_date DATE,
  amount NUMBER(19,2),
  tax_amount NUMBER(19,2),
  old_esn VARCHAR2(30 BYTE)
);
COMMENT ON TABLE sa.temp_tf_order_interface IS 'TEMPORARY ORDER INTERFACE TABLE';
COMMENT ON COLUMN sa.temp_tf_order_interface.creation_date IS 'CREATION DATE';
COMMENT ON COLUMN sa.temp_tf_order_interface.customer_number IS 'BRAND CUSTOMER NUMBER';
COMMENT ON COLUMN sa.temp_tf_order_interface.store_number IS 'STORE NUMBER';
COMMENT ON COLUMN sa.temp_tf_order_interface.po_number IS 'CASE ID NUMBER';
COMMENT ON COLUMN sa.temp_tf_order_interface.tf_part_number IS 'PART REQUEST REPLACEMENT PART NUMBER';
COMMENT ON COLUMN sa.temp_tf_order_interface.quantity IS 'PART REQUEST REPLACEMENT PART NUMBER QUANTITY';
COMMENT ON COLUMN sa.temp_tf_order_interface.processed_flag IS 'PROCESSED FLAG';
COMMENT ON COLUMN sa.temp_tf_order_interface.delivery_date IS 'ORDER DELIVERY DATE';
COMMENT ON COLUMN sa.temp_tf_order_interface."SOURCE" IS 'BRAND SOURCE';
COMMENT ON COLUMN sa.temp_tf_order_interface.process_date IS 'PROCESSED DATE';
COMMENT ON COLUMN sa.temp_tf_order_interface.error_description IS 'ERROR DESCRIPTION';
COMMENT ON COLUMN sa.temp_tf_order_interface.ship_to_name IS 'CUSTOMER SHIP TO NAME';
COMMENT ON COLUMN sa.temp_tf_order_interface.ship_to_address IS 'CUSTOMER SHIP TO ADDRESS';
COMMENT ON COLUMN sa.temp_tf_order_interface.ship_to_city IS 'CUSTOMER SHIP TO CITY';
COMMENT ON COLUMN sa.temp_tf_order_interface.ship_to_state IS 'CUSTOMER SHIP TO STATE';
COMMENT ON COLUMN sa.temp_tf_order_interface.ship_to_zip IS 'CUSTOMER SHIP TO ZIP';
COMMENT ON COLUMN sa.temp_tf_order_interface.ship_to_phone IS 'CUSTOMER SHIP TO PHONE';
COMMENT ON COLUMN sa.temp_tf_order_interface.title IS 'CASE TITLE';
COMMENT ON COLUMN sa.temp_tf_order_interface.status IS 'CASE STATUS';
COMMENT ON COLUMN sa.temp_tf_order_interface.ship_to_email IS 'CUSTOMER SHIP TO EMAIL';
COMMENT ON COLUMN sa.temp_tf_order_interface.tf_generic_part IS 'TRACFONE GENERIC PART';
COMMENT ON COLUMN sa.temp_tf_order_interface.ff_name IS 'FULFILLMENT CENTER NAME';
COMMENT ON COLUMN sa.temp_tf_order_interface.carrier IS 'COURIER ID';
COMMENT ON COLUMN sa.temp_tf_order_interface."METHOD" IS 'SHIPPING METHOD';
COMMENT ON COLUMN sa.temp_tf_order_interface.ship_to_address2 IS 'CUSTOMER SHIP TO ADDRESS2';
COMMENT ON COLUMN sa.temp_tf_order_interface.line_number IS 'LINE NUMBER';
COMMENT ON COLUMN sa.temp_tf_order_interface.llid IS 'B2B ACCOUNT ID OR LIFELINE ID';
COMMENT ON COLUMN sa.temp_tf_order_interface.insert_date IS 'INSERT DATE';
COMMENT ON COLUMN sa.temp_tf_order_interface.amount IS 'TAX RATE APPLIED ON SALES TAX RATE FOR HPP CLAIMS';
COMMENT ON COLUMN sa.temp_tf_order_interface.tax_amount IS 'TAX RATE APPLIED ON SALES TAX RATE FOR HPP CLAIMS';
COMMENT ON COLUMN sa.temp_tf_order_interface.old_esn IS 'OLD ESN FOR HH CASE DEFECTIVE PHONE';