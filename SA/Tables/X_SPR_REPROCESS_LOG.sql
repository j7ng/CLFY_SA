CREATE TABLE sa.x_spr_reprocess_log (
  objid NUMBER(38) NOT NULL,
  esn VARCHAR2(40 BYTE),
  "MIN" VARCHAR2(40 BYTE),
  call_trans_objid NUMBER(38),
  ig_transaction_id NUMBER(38),
  ig_order_type VARCHAR2(20 BYTE),
  ct_action_type VARCHAR2(20 BYTE),
  reason VARCHAR2(500 BYTE),
  response VARCHAR2(1000 BYTE),
  program_name VARCHAR2(200 BYTE),
  "ACTION" VARCHAR2(1000 BYTE),
  reprocess_flag VARCHAR2(1 BYTE),
  reprocess_count NUMBER DEFAULT 0,
  insert_timestamp DATE DEFAULT SYSDATE,
  update_timestamp DATE DEFAULT SYSDATE,
  CONSTRAINT pk_spr_reprocess_log PRIMARY KEY (objid)
);
COMMENT ON TABLE sa.x_spr_reprocess_log IS 'Stores the failure transactions from the spr transactions';
COMMENT ON COLUMN sa.x_spr_reprocess_log.objid IS 'Unique record identifier';
COMMENT ON COLUMN sa.x_spr_reprocess_log.esn IS 'Serial No of the Subscriber';
COMMENT ON COLUMN sa.x_spr_reprocess_log."MIN" IS 'Mobile number of the Subscriber';
COMMENT ON COLUMN sa.x_spr_reprocess_log.call_trans_objid IS 'Call trans reference';
COMMENT ON COLUMN sa.x_spr_reprocess_log.ig_transaction_id IS 'IG transaction reference';
COMMENT ON COLUMN sa.x_spr_reprocess_log.ct_action_type IS 'Call trasn action type ';
COMMENT ON COLUMN sa.x_spr_reprocess_log.response IS 'Response of the action';
COMMENT ON COLUMN sa.x_spr_reprocess_log.program_name IS 'Program executed';
COMMENT ON COLUMN sa.x_spr_reprocess_log."ACTION" IS 'Step or action';
COMMENT ON COLUMN sa.x_spr_reprocess_log.reprocess_flag IS 'Status of the record, to identify records to be re-processed or already processed';
COMMENT ON COLUMN sa.x_spr_reprocess_log.reprocess_count IS 'Number of times the transactions processed';
COMMENT ON COLUMN sa.x_spr_reprocess_log.insert_timestamp IS 'Logging date';
COMMENT ON COLUMN sa.x_spr_reprocess_log.update_timestamp IS 'updated date';