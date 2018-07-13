CREATE TABLE sa.smartpay_order_log_hdr (
  objid NUMBER NOT NULL,
  commerce_order_id VARCHAR2(50 BYTE),
  commerce_order_type VARCHAR2(50 BYTE),
  bus_org_id VARCHAR2(40 BYTE),
  request_source VARCHAR2(20 BYTE),
  client_id VARCHAR2(100 BYTE),
  amount NUMBER(19,2),
  total_amount NUMBER(19,2),
  decision VARCHAR2(20 BYTE),
  auth_request_id VARCHAR2(30 BYTE),
  merchant_ref_number VARCHAR2(50 BYTE),
  customer_firstname VARCHAR2(20 BYTE),
  customer_lastname VARCHAR2(20 BYTE),
  customer_phone VARCHAR2(20 BYTE),
  customer_email VARCHAR2(50 BYTE),
  ship_address1 VARCHAR2(200 BYTE),
  ship_address2 VARCHAR2(200 BYTE),
  ship_city VARCHAR2(30 BYTE),
  ship_state VARCHAR2(40 BYTE),
  ship_zip VARCHAR2(20 BYTE),
  ship_country VARCHAR2(20 BYTE),
  response_code VARCHAR2(100 BYTE),
  response_message VARCHAR2(1000 BYTE),
  insert_timestamp DATE DEFAULT SYSDATE,
  update_timestamp DATE DEFAULT SYSDATE,
  CONSTRAINT smartpay_ord_log_hdr_pk PRIMARY KEY (objid) USING INDEX sa.smartpay_ord_log_hdr_unique
);
COMMENT ON COLUMN sa.smartpay_order_log_hdr.objid IS 'Internal record number';
COMMENT ON COLUMN sa.smartpay_order_log_hdr.commerce_order_id IS 'From OFS/e-commerce(Order_id)';
COMMENT ON COLUMN sa.smartpay_order_log_hdr.commerce_order_type IS 'Order/Pre-order';
COMMENT ON COLUMN sa.smartpay_order_log_hdr.bus_org_id IS 'Brand';
COMMENT ON COLUMN sa.smartpay_order_log_hdr.request_source IS 'WEB/CSR/IVR/APP etc.';
COMMENT ON COLUMN sa.smartpay_order_log_hdr.client_id IS 'Client ID';
COMMENT ON COLUMN sa.smartpay_order_log_hdr.amount IS 'Amount for the transaction';
COMMENT ON COLUMN sa.smartpay_order_log_hdr.total_amount IS 'Total Amount for the transaction';
COMMENT ON COLUMN sa.smartpay_order_log_hdr.decision IS 'Decision returned for the transaction';
COMMENT ON COLUMN sa.smartpay_order_log_hdr.auth_request_id IS 'Authorization Request Id';
COMMENT ON COLUMN sa.smartpay_order_log_hdr.merchant_ref_number IS 'Merchant Reference Number.';
COMMENT ON COLUMN sa.smartpay_order_log_hdr.customer_firstname IS 'Customer First Name ';
COMMENT ON COLUMN sa.smartpay_order_log_hdr.customer_lastname IS 'Customer Last Name';
COMMENT ON COLUMN sa.smartpay_order_log_hdr.customer_phone IS 'Customer Phone Number';
COMMENT ON COLUMN sa.smartpay_order_log_hdr.customer_email IS 'Customer Email Address';
COMMENT ON COLUMN sa.smartpay_order_log_hdr.ship_address1 IS 'Customer Address Line 1';
COMMENT ON COLUMN sa.smartpay_order_log_hdr.ship_address2 IS 'Customer Address Line 2';
COMMENT ON COLUMN sa.smartpay_order_log_hdr.ship_city IS 'Customer Address City';
COMMENT ON COLUMN sa.smartpay_order_log_hdr.ship_state IS 'Customer Address State';
COMMENT ON COLUMN sa.smartpay_order_log_hdr.ship_zip IS 'Customer Address Zip';
COMMENT ON COLUMN sa.smartpay_order_log_hdr.ship_country IS 'Customer Address Country';
COMMENT ON COLUMN sa.smartpay_order_log_hdr.response_code IS 'Response code received';
COMMENT ON COLUMN sa.smartpay_order_log_hdr.response_message IS 'Response message received';
COMMENT ON COLUMN sa.smartpay_order_log_hdr.insert_timestamp IS 'Record Creation Timestamp';
COMMENT ON COLUMN sa.smartpay_order_log_hdr.update_timestamp IS 'Record Updation Timestamp';