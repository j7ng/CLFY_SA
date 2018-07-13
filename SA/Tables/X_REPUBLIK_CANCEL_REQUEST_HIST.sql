CREATE TABLE sa.x_republik_cancel_request_hist (
  request_id NUMBER NOT NULL,
  payment_method VARCHAR2(6 BYTE) NOT NULL,
  cc_number VARCHAR2(100 BYTE),
  check_acct_number VARCHAR2(53 BYTE),
  customer_phone VARCHAR2(30 BYTE),
  customer_email VARCHAR2(100 BYTE),
  customer_firstname VARCHAR2(50 BYTE),
  customer_lastname VARCHAR2(50 BYTE),
  created_by VARCHAR2(50 BYTE) NOT NULL,
  created_date DATE NOT NULL,
  status VARCHAR2(10 BYTE) NOT NULL,
  last_updated_date DATE
);
ALTER TABLE sa.x_republik_cancel_request_hist ADD SUPPLEMENTAL LOG GROUP dmtsora74473828_0 (cc_number, check_acct_number, created_by, created_date, customer_email, customer_firstname, customer_lastname, customer_phone, last_updated_date, payment_method, request_id, status) ALWAYS;