CREATE TABLE sa.adfcrm_sui_trans (
  txn_id NUMBER NOT NULL,
  agent_login_name VARCHAR2(100 BYTE),
  sui_action VARCHAR2(500 BYTE),
  esn VARCHAR2(50 BYTE),
  "MIN" VARCHAR2(50 BYTE),
  carrier_name VARCHAR2(150 BYTE),
  carrier_id NUMBER,
  carrier_market_name VARCHAR2(150 BYTE),
  carrier_iccid VARCHAR2(150 BYTE),
  txn_date TIMESTAMP,
  txn_result VARCHAR2(1000 BYTE),
  PRIMARY KEY (txn_id)
);
COMMENT ON COLUMN sa.adfcrm_sui_trans.txn_id IS 'Unique Transaction ID to identify the Transaction record.';
COMMENT ON COLUMN sa.adfcrm_sui_trans.agent_login_name IS 'Agent login name.';
COMMENT ON COLUMN sa.adfcrm_sui_trans.sui_action IS 'SUI Action name performed';
COMMENT ON COLUMN sa.adfcrm_sui_trans.esn IS 'The ESN.';
COMMENT ON COLUMN sa.adfcrm_sui_trans."MIN" IS 'The MIN.';
COMMENT ON COLUMN sa.adfcrm_sui_trans.carrier_name IS 'Carrier Name';
COMMENT ON COLUMN sa.adfcrm_sui_trans.carrier_id IS 'Carrier ID';
COMMENT ON COLUMN sa.adfcrm_sui_trans.carrier_market_name IS 'Carrier Sub Market Name';
COMMENT ON COLUMN sa.adfcrm_sui_trans.carrier_iccid IS 'Carrier ICCID';
COMMENT ON COLUMN sa.adfcrm_sui_trans.txn_date IS 'Transaction Date and Time';
COMMENT ON COLUMN sa.adfcrm_sui_trans.txn_result IS 'End Result of the transaction';