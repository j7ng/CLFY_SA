CREATE TABLE sa.x_transaction (
  objid NUMBER NOT NULL,
  x_trans2payment NUMBER NOT NULL,
  x_trans2processor NUMBER NOT NULL,
  x_trans_type VARCHAR2(50 BYTE) NOT NULL,
  x_trans_date DATE NOT NULL,
  x_trans_status VARCHAR2(50 BYTE) NOT NULL,
  x_request CLOB,
  x_response CLOB,
  x_trans2payment_source NUMBER,
  x_trans2fallout NUMBER,
  x_transaction_id VARCHAR2(50 BYTE),
  x_amount NUMBER(19,2) NOT NULL,
  x_tax_amount NUMBER(19,2),
  CONSTRAINT x_trns_objid_pk PRIMARY KEY (objid)
);
COMMENT ON TABLE sa.x_transaction IS 'STORES INFORMATION ABOUT PAYMENT TRANSACTION';
COMMENT ON COLUMN sa.x_transaction.objid IS 'INTERNAL RECORD ID';
COMMENT ON COLUMN sa.x_transaction.x_trans2payment IS 'OBJID of the corresponding record in X_PAYMENT table';
COMMENT ON COLUMN sa.x_transaction.x_trans2processor IS 'OBJID of the corresponding record in X_PMT_PROCESSOR table';
COMMENT ON COLUMN sa.x_transaction.x_trans_type IS 'Transaction type i.e. ?PURCHASE? or ?REFUND?';
COMMENT ON COLUMN sa.x_transaction.x_trans_date IS 'Transaction timestamp';
COMMENT ON COLUMN sa.x_transaction.x_trans_status IS 'Transaction status i.e. SUCCESS or FAILED';
COMMENT ON COLUMN sa.x_transaction.x_request IS 'Gateway request XML';
COMMENT ON COLUMN sa.x_transaction.x_response IS 'Gateway response XML';
COMMENT ON COLUMN sa.x_transaction.x_trans2payment_source IS 'OBJID of the corresponding record in X_PAYMENT_SOURCE table, NULL in-case of rewards';
COMMENT ON COLUMN sa.x_transaction.x_trans2fallout IS 'OBJID of the corresponding record in X_FALLOUT table';
COMMENT ON COLUMN sa.x_transaction.x_transaction_id IS 'Auth or Settle confirmation Id from gateways';
COMMENT ON COLUMN sa.x_transaction.x_amount IS 'Purchase amount for the transaction';
COMMENT ON COLUMN sa.x_transaction.x_tax_amount IS 'Tax amount for the transaction';