CREATE TABLE sa.x_spr_transaction_log (
  objid NUMBER(22) NOT NULL,
  esn VARCHAR2(30 BYTE),
  "MIN" VARCHAR2(30 BYTE),
  subscriber_id VARCHAR2(50 BYTE),
  "GROUP_ID" VARCHAR2(50 BYTE),
  pcrf_transaction_id NUMBER(22),
  program_step VARCHAR2(100 BYTE),
  program_name VARCHAR2(500 BYTE),
  message VARCHAR2(1000 BYTE),
  response_code NUMBER(3),
  response_message VARCHAR2(1000 BYTE),
  sourcesystem VARCHAR2(30 BYTE),
  offer_id VARCHAR2(50 BYTE),
  insert_timestamp DATE DEFAULT SYSDATE NOT NULL,
  update_timestamp DATE DEFAULT SYSDATE NOT NULL,
  throttle_source VARCHAR2(50 BYTE),
  parent_name VARCHAR2(40 BYTE),
  usage_tier_id NUMBER(2),
  "COS" VARCHAR2(30 BYTE),
  policy_name VARCHAR2(30 BYTE),
  entitlement VARCHAR2(30 BYTE),
  threshold_reached_time DATE,
  last_redemption_date DATE,
  CONSTRAINT x_spr_transaction_log_pk PRIMARY KEY (objid)
);
COMMENT ON TABLE sa.x_spr_transaction_log IS 'Logging table to capture all the internal procedure calls';
COMMENT ON COLUMN sa.x_spr_transaction_log.objid IS 'Unique identifier of the record.';
COMMENT ON COLUMN sa.x_spr_transaction_log.esn IS 'Serial Number of the logged row.';
COMMENT ON COLUMN sa.x_spr_transaction_log."MIN" IS 'Mobile Number of the logged row.';
COMMENT ON COLUMN sa.x_spr_transaction_log.subscriber_id IS 'Identified of Subscriber';
COMMENT ON COLUMN sa.x_spr_transaction_log."GROUP_ID" IS 'Group Id of group where customer belongs to';
COMMENT ON COLUMN sa.x_spr_transaction_log.pcrf_transaction_id IS 'PCRF Transaction ID';
COMMENT ON COLUMN sa.x_spr_transaction_log.program_step IS 'Program step';
COMMENT ON COLUMN sa.x_spr_transaction_log.program_name IS 'Program name';
COMMENT ON COLUMN sa.x_spr_transaction_log.message IS 'Message';
COMMENT ON COLUMN sa.x_spr_transaction_log.response_code IS 'Response Code';
COMMENT ON COLUMN sa.x_spr_transaction_log.response_message IS 'Response Message';
COMMENT ON COLUMN sa.x_spr_transaction_log.sourcesystem IS 'Source System';
COMMENT ON COLUMN sa.x_spr_transaction_log.offer_id IS 'Offer Id';
COMMENT ON COLUMN sa.x_spr_transaction_log.insert_timestamp IS 'Record Inserted Timestamp';
COMMENT ON COLUMN sa.x_spr_transaction_log.update_timestamp IS 'Record Updated Timestamp';
COMMENT ON COLUMN sa.x_spr_transaction_log.last_redemption_date IS 'Last redemption date info is sending by 3CI';