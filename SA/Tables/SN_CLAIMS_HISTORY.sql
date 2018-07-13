CREATE TABLE sa.sn_claims_history (
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
  carrier VARCHAR2(80 BYTE),
  "METHOD" VARCHAR2(80 BYTE),
  ship_to_address2 VARCHAR2(240 BYTE),
  line_number NUMBER,
  llid VARCHAR2(20 BYTE),
  insert_date DATE,
  amount NUMBER(19,2),
  tax_amount NUMBER(19,2),
  old_esn VARCHAR2(30 BYTE)
);
COMMENT ON TABLE sa.sn_claims_history IS 'IS USED TO REGISTER TRANSACTION RECORD MIRROR OF TEMP_TF_ORDER_INTERACE';
COMMENT ON COLUMN sa.sn_claims_history.creation_date IS 'CREATION DATE';
COMMENT ON COLUMN sa.sn_claims_history.customer_number IS 'BRAND CUSTOMER NUMBER';
COMMENT ON COLUMN sa.sn_claims_history.store_number IS 'STORE NUMBER';
COMMENT ON COLUMN sa.sn_claims_history.po_number IS 'CASE ID NUMBER';
COMMENT ON COLUMN sa.sn_claims_history.tf_part_number IS 'PART REQUEST REPLACEMENT PART NUMBER';
COMMENT ON COLUMN sa.sn_claims_history.quantity IS 'PART REQUEST REPLACEMENT PART NUMBER QUANTITY';
COMMENT ON COLUMN sa.sn_claims_history.delivery_date IS 'ORDER DELIVERY DATE';
COMMENT ON COLUMN sa.sn_claims_history."SOURCE" IS 'BRAND SOURCE';
COMMENT ON COLUMN sa.sn_claims_history.ship_to_name IS 'CUSTOMER SHIP TO NAME';
COMMENT ON COLUMN sa.sn_claims_history.ship_to_address IS 'CUSTOMER SHIP TO ADDRESS';
COMMENT ON COLUMN sa.sn_claims_history.ship_to_city IS 'CUSTOMER SHIP TO CITY';
COMMENT ON COLUMN sa.sn_claims_history.ship_to_state IS 'CUSTOMER SHIP TO STATE';
COMMENT ON COLUMN sa.sn_claims_history.ship_to_zip IS 'CUSTOMER SHIP TO ZIP';
COMMENT ON COLUMN sa.sn_claims_history.ship_to_phone IS 'CUSTOMER SHIP TO PHONE';
COMMENT ON COLUMN sa.sn_claims_history.title IS 'CASE TITLE';
COMMENT ON COLUMN sa.sn_claims_history.status IS 'CASE STATUS';
COMMENT ON COLUMN sa.sn_claims_history.ship_to_email IS 'CUSTOMER SHIP TO EMAIL';
COMMENT ON COLUMN sa.sn_claims_history.ff_name IS 'FULFILLMENT CENTER NAME';
COMMENT ON COLUMN sa.sn_claims_history.carrier IS 'COURIER ID';
COMMENT ON COLUMN sa.sn_claims_history."METHOD" IS 'SHIPPING METHOD';
COMMENT ON COLUMN sa.sn_claims_history.ship_to_address2 IS 'CUSTOMER SHIP TO ADDRESS2';
COMMENT ON COLUMN sa.sn_claims_history.llid IS 'B2B ACCOUNT ID OR LIFELINE ID';
COMMENT ON COLUMN sa.sn_claims_history.amount IS 'AMOUNT FRO RETAIL PRICE REPLACEMENT PHONE PART NUMBER';
COMMENT ON COLUMN sa.sn_claims_history.tax_amount IS 'CALCULATE AMOUNT WITH TAX AMOUNT FOR CGW ';