CREATE TABLE sa.apex_hotline_req (
  source_file VARCHAR2(400 BYTE),
  blob_content BLOB,
  order_type VARCHAR2(30 BYTE),
  short_code VARCHAR2(30 BYTE),
  sms_msg VARCHAR2(30 BYTE),
  requestor VARCHAR2(30 BYTE),
  load_date DATE,
  req_processed VARCHAR2(1 BYTE)
);
COMMENT ON COLUMN sa.apex_hotline_req.req_processed IS 'N = NOT PROCESSED, S = PROCESSED SUCCESSFULLY, P = PROCESSED WITH ERRORS';