CREATE TABLE sa.phbx_scoring_transaction (
  objid NUMBER NOT NULL,
  application_req_num VARCHAR2(100 BYTE),
  x_min VARCHAR2(30 BYTE),
  customer_fname VARCHAR2(80 BYTE),
  email_address VARCHAR2(300 BYTE),
  client_id VARCHAR2(80 BYTE),
  transaction_dt TIMESTAMP,
  scoring_code VARCHAR2(30 BYTE),
  transaction_id VARCHAR2(50 BYTE),
  CONSTRAINT pk_phbx_scoring_transaction PRIMARY KEY (objid)
);
COMMENT ON COLUMN sa.phbx_scoring_transaction.objid IS 'System defined sequence';
COMMENT ON COLUMN sa.phbx_scoring_transaction.application_req_num IS 'Transaction Application Req Number';
COMMENT ON COLUMN sa.phbx_scoring_transaction.x_min IS 'Min associated with transaction';
COMMENT ON COLUMN sa.phbx_scoring_transaction.customer_fname IS 'Customer name';
COMMENT ON COLUMN sa.phbx_scoring_transaction.email_address IS 'Customer Email Address';
COMMENT ON COLUMN sa.phbx_scoring_transaction.client_id IS 'Customer client identifier';
COMMENT ON COLUMN sa.phbx_scoring_transaction.transaction_dt IS 'Transaction Date Time';
COMMENT ON COLUMN sa.phbx_scoring_transaction.scoring_code IS 'Current Score code';
COMMENT ON COLUMN sa.phbx_scoring_transaction.transaction_id IS 'Transaction id';