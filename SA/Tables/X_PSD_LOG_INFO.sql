CREATE TABLE sa.x_psd_log_info (
  logtime DATE,
  login_name VARCHAR2(30 BYTE),
  esn VARCHAR2(30 BYTE),
  phone_sequence NUMBER(3),
  esn_status VARCHAR2(20 BYTE),
  runvalidateesn VARCHAR2(20 BYTE),
  codegenerated VARCHAR2(20 BYTE),
  iscodeaccepted VARCHAR2(1 BYTE),
  issequenceupdated VARCHAR2(1 BYTE)
);
ALTER TABLE sa.x_psd_log_info ADD SUPPLEMENTAL LOG GROUP dmtsora519741171_0 (codegenerated, esn, esn_status, iscodeaccepted, issequenceupdated, login_name, logtime, phone_sequence, runvalidateesn) ALWAYS;
COMMENT ON TABLE sa.x_psd_log_info IS 'Activity log table for PSD tool processing';
COMMENT ON COLUMN sa.x_psd_log_info.logtime IS 'Timestamp for the transaction';
COMMENT ON COLUMN sa.x_psd_log_info.login_name IS 'login name of user';
COMMENT ON COLUMN sa.x_psd_log_info.esn IS 'Phone Serial Number';
COMMENT ON COLUMN sa.x_psd_log_info.phone_sequence IS 'Phone Sequence';
COMMENT ON COLUMN sa.x_psd_log_info.esn_status IS 'Phone Status: 50,51,52,54';
COMMENT ON COLUMN sa.x_psd_log_info.runvalidateesn IS 'Flag for Validate ESN: Y,N';
COMMENT ON COLUMN sa.x_psd_log_info.codegenerated IS 'Phone Code Generated';
COMMENT ON COLUMN sa.x_psd_log_info.iscodeaccepted IS 'Code Accepted Flag: Y.N';
COMMENT ON COLUMN sa.x_psd_log_info.issequenceupdated IS 'Sequenece Update Flag: Y,N';