CREATE TABLE sa.x_mvne_error_log (
  objid NUMBER NOT NULL,
  x_esn VARCHAR2(30 BYTE),
  x_sim VARCHAR2(50 BYTE),
  x_zipcode VARCHAR2(10 BYTE),
  x_process_step VARCHAR2(100 BYTE),
  x_error_code VARCHAR2(10 BYTE),
  x_error_string VARCHAR2(500 BYTE),
  x_error_date DATE,
  CONSTRAINT x_mvne_error_log_pk PRIMARY KEY (objid)
);
COMMENT ON TABLE sa.x_mvne_error_log IS 'table to log mvne errors';
COMMENT ON COLUMN sa.x_mvne_error_log.objid IS 'Unique identifier for the table';
COMMENT ON COLUMN sa.x_mvne_error_log.x_esn IS 'ESN ';
COMMENT ON COLUMN sa.x_mvne_error_log.x_sim IS 'sim';
COMMENT ON COLUMN sa.x_mvne_error_log.x_zipcode IS 'zipcode';
COMMENT ON COLUMN sa.x_mvne_error_log.x_process_step IS 'process step';
COMMENT ON COLUMN sa.x_mvne_error_log.x_error_code IS 'error code';
COMMENT ON COLUMN sa.x_mvne_error_log.x_error_string IS 'error string ';
COMMENT ON COLUMN sa.x_mvne_error_log.x_error_date IS 'error date';