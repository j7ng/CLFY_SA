CREATE TABLE sa.x_republik_paymentech (
  merch_order_number VARCHAR2(40 BYTE) NOT NULL,
  customer_name VARCHAR2(60 BYTE),
  transaction_code VARCHAR2(2 BYTE),
  check_acct_number VARCHAR2(53 BYTE),
  chargeback_amount NUMBER,
  approval_status NUMBER,
  creation_date DATE,
  processed VARCHAR2(20 BYTE),
  processed_date DATE
);
ALTER TABLE sa.x_republik_paymentech ADD SUPPLEMENTAL LOG GROUP dmtsora658852638_0 (approval_status, chargeback_amount, check_acct_number, creation_date, customer_name, merch_order_number, processed, processed_date, transaction_code) ALWAYS;