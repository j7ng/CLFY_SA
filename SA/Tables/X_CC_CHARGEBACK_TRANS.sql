CREATE TABLE sa.x_cc_chargeback_trans (
  objid NUMBER NOT NULL,
  x_description VARCHAR2(255 BYTE),
  x_merch_order_number VARCHAR2(40 BYTE),
  x_customer_name VARCHAR2(60 BYTE),
  x_reason_code VARCHAR2(20 BYTE),
  x_chargeback_category VARCHAR2(20 BYTE),
  x_cc_number VARCHAR2(53 BYTE),
  x_chargeback_amount NUMBER,
  x_approval_status NUMBER,
  x_creation_date DATE,
  x_processed VARCHAR2(30 BYTE),
  x_processed_date DATE,
  x_processed_comments VARCHAR2(255 BYTE),
  x_transaction_division NUMBER,
  x_status_flag VARCHAR2(2 BYTE),
  x_sequence NUMBER,
  x_transaction_date DATE,
  x_chargeback_date DATE,
  x_activity_date DATE,
  x_usage_code NUMBER(1),
  cc_chargeback2chargeback_trans NUMBER,
  x_case_number VARCHAR2(255 BYTE)
);
ALTER TABLE sa.x_cc_chargeback_trans ADD SUPPLEMENTAL LOG GROUP dmtsora1170356214_0 (cc_chargeback2chargeback_trans, objid, x_activity_date, x_approval_status, x_case_number, x_cc_number, x_chargeback_amount, x_chargeback_category, x_chargeback_date, x_creation_date, x_customer_name, x_description, x_merch_order_number, x_processed, x_processed_comments, x_processed_date, x_reason_code, x_sequence, x_status_flag, x_transaction_date, x_transaction_division, x_usage_code) ALWAYS;
COMMENT ON TABLE sa.x_cc_chargeback_trans IS 'Detail Billing Credit Card Chargeback Transaction';
COMMENT ON COLUMN sa.x_cc_chargeback_trans.objid IS 'Internal Record ID';
COMMENT ON COLUMN sa.x_cc_chargeback_trans.x_description IS 'Description';
COMMENT ON COLUMN sa.x_cc_chargeback_trans.x_merch_order_number IS 'Merchant Order NUmber';
COMMENT ON COLUMN sa.x_cc_chargeback_trans.x_customer_name IS 'Customer Name';
COMMENT ON COLUMN sa.x_cc_chargeback_trans.x_reason_code IS 'Reason Code';
COMMENT ON COLUMN sa.x_cc_chargeback_trans.x_chargeback_category IS 'Chargeback Category';
COMMENT ON COLUMN sa.x_cc_chargeback_trans.x_cc_number IS 'Encrypted Credit Card Number';
COMMENT ON COLUMN sa.x_cc_chargeback_trans.x_chargeback_amount IS 'Chargeback Amount';
COMMENT ON COLUMN sa.x_cc_chargeback_trans.x_approval_status IS 'Approval Status';
COMMENT ON COLUMN sa.x_cc_chargeback_trans.x_creation_date IS 'Creation Timestamp';
COMMENT ON COLUMN sa.x_cc_chargeback_trans.x_processed IS 'Processed Flag';
COMMENT ON COLUMN sa.x_cc_chargeback_trans.x_processed_date IS 'Processed Date';
COMMENT ON COLUMN sa.x_cc_chargeback_trans.x_processed_comments IS 'Processed Comments';
COMMENT ON COLUMN sa.x_cc_chargeback_trans.x_transaction_division IS 'Transaction Division';
COMMENT ON COLUMN sa.x_cc_chargeback_trans.x_status_flag IS 'Sattus Flag';
COMMENT ON COLUMN sa.x_cc_chargeback_trans.x_sequence IS 'Sequence';
COMMENT ON COLUMN sa.x_cc_chargeback_trans.x_transaction_date IS 'Transaction Date';
COMMENT ON COLUMN sa.x_cc_chargeback_trans.x_chargeback_date IS 'Chargeback Date';
COMMENT ON COLUMN sa.x_cc_chargeback_trans.x_activity_date IS 'Activity Date';
COMMENT ON COLUMN sa.x_cc_chargeback_trans.x_usage_code IS 'Usage Code';
COMMENT ON COLUMN sa.x_cc_chargeback_trans.cc_chargeback2chargeback_trans IS 'Reference to x_chargeback_trans';
COMMENT ON COLUMN sa.x_cc_chargeback_trans.x_case_number IS 'reference to ID_NUMBER in table_case';