CREATE TABLE sa.adfcrm_tas_error (
  session_id VARCHAR2(30 BYTE),
  login_name VARCHAR2(100 BYTE),
  request VARCHAR2(4000 BYTE),
  response VARCHAR2(4000 BYTE),
  error_message VARCHAR2(30 BYTE),
  transaction_type VARCHAR2(100 BYTE),
  transaction_time TIMESTAMP,
  flow VARCHAR2(30 BYTE),
  case_id VARCHAR2(30 BYTE)
);
COMMENT ON TABLE sa.adfcrm_tas_error IS 'This table is used to hold TAS error logging from all flows';
COMMENT ON COLUMN sa.adfcrm_tas_error.session_id IS 'holds the TAS session id';
COMMENT ON COLUMN sa.adfcrm_tas_error.login_name IS 'holds the agent user name ';
COMMENT ON COLUMN sa.adfcrm_tas_error.request IS 'holds request to service or db call ';
COMMENT ON COLUMN sa.adfcrm_tas_error.response IS 'holds response from service or db call ';
COMMENT ON COLUMN sa.adfcrm_tas_error.error_message IS 'holds output message ';
COMMENT ON COLUMN sa.adfcrm_tas_error.transaction_type IS 'holds type of logged transaction: framework, soa, cbo, db, etc';
COMMENT ON COLUMN sa.adfcrm_tas_error.transaction_time IS 'holds transaction timestamp ';
COMMENT ON COLUMN sa.adfcrm_tas_error.flow IS 'holds flow where logged error occurred ';
COMMENT ON COLUMN sa.adfcrm_tas_error.case_id IS 'holds case_id if any ';