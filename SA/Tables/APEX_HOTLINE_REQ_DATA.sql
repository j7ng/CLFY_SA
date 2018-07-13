CREATE TABLE sa.apex_hotline_req_data (
  source_file VARCHAR2(400 BYTE),
  esn_or_min VARCHAR2(30 BYTE),
  sms_msg VARCHAR2(200 BYTE),
  process_status VARCHAR2(1 BYTE)
);
COMMENT ON COLUMN sa.apex_hotline_req_data.sms_msg IS 'Send a message other than the default one specified at the request level. Currently for SMS only';
COMMENT ON COLUMN sa.apex_hotline_req_data.process_status IS 'N = NOT PROCESSED, S = SUCCESS, F = FAILED';