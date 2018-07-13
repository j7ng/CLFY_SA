CREATE TABLE sa.x_settlement_log (
  objid NUMBER NOT NULL,
  x_actv_date DATE,
  x_file_name VARCHAR2(255 BYTE),
  x_last_update DATE,
  x_status VARCHAR2(30 BYTE),
  CONSTRAINT x_settlement_log_pk PRIMARY KEY (objid)
);
COMMENT ON TABLE sa.x_settlement_log IS 'Header Billing SETTLEMENT Transactions';
COMMENT ON COLUMN sa.x_settlement_log.objid IS 'Internal Record ID';
COMMENT ON COLUMN sa.x_settlement_log.x_actv_date IS 'Activity Date';
COMMENT ON COLUMN sa.x_settlement_log.x_file_name IS 'File Name';
COMMENT ON COLUMN sa.x_settlement_log.x_last_update IS 'last Update';
COMMENT ON COLUMN sa.x_settlement_log.x_status IS 'Status';