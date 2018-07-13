CREATE TABLE sa.x_spr_error_log (
  objid NUMBER(38) NOT NULL,
  esn VARCHAR2(40 BYTE),
  "MIN" VARCHAR2(40 BYTE),
  call_trans_objid NUMBER(38),
  program_purch_hdr_objid NUMBER(38),
  ig_transaction_objid NUMBER(38),
  action_type VARCHAR2(20 BYTE),
  reason VARCHAR2(500 BYTE),
  response VARCHAR2(1000 BYTE),
  program_name VARCHAR2(200 BYTE),
  "ACTION" VARCHAR2(1000 BYTE),
  log_date DATE DEFAULT SYSDATE NOT NULL,
  new_esn VARCHAR2(30 BYTE),
  old_esn VARCHAR2(30 BYTE),
  CONSTRAINT pk_spr_error_log PRIMARY KEY (objid)
);
COMMENT ON TABLE sa.x_spr_error_log IS 'Stores the messages from the spr transactions';
COMMENT ON COLUMN sa.x_spr_error_log.objid IS 'Unique record identifier';
COMMENT ON COLUMN sa.x_spr_error_log.esn IS 'Serial No of the Subscriber';
COMMENT ON COLUMN sa.x_spr_error_log."MIN" IS 'Mobile number of the Subscriber';
COMMENT ON COLUMN sa.x_spr_error_log.call_trans_objid IS 'Call trans reference';
COMMENT ON COLUMN sa.x_spr_error_log.program_purch_hdr_objid IS 'Program purchase reference';
COMMENT ON COLUMN sa.x_spr_error_log.ig_transaction_objid IS 'IG transaction reference';
COMMENT ON COLUMN sa.x_spr_error_log.action_type IS 'Action type of the call trans';
COMMENT ON COLUMN sa.x_spr_error_log.reason IS 'Reason of the call trans';
COMMENT ON COLUMN sa.x_spr_error_log.response IS 'Response of the action';
COMMENT ON COLUMN sa.x_spr_error_log.program_name IS 'Program executed';
COMMENT ON COLUMN sa.x_spr_error_log."ACTION" IS 'Step or action';
COMMENT ON COLUMN sa.x_spr_error_log.log_date IS 'Logging date';