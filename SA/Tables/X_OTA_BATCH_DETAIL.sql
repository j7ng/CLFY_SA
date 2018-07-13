CREATE TABLE sa.x_ota_batch_detail (
  batchdetailid NUMBER,
  batchid NUMBER,
  send_time DATE,
  esn VARCHAR2(30 BYTE),
  status CHAR,
  error_code NUMBER,
  ota_trans_id NUMBER,
  error_msg VARCHAR2(255 BYTE)
);
ALTER TABLE sa.x_ota_batch_detail ADD SUPPLEMENTAL LOG GROUP dmtsora239209813_0 (batchdetailid, batchid, error_code, error_msg, esn, ota_trans_id, send_time, status) ALWAYS;
COMMENT ON TABLE sa.x_ota_batch_detail IS 'Details for OTA Batch Messaging';
COMMENT ON COLUMN sa.x_ota_batch_detail.batchdetailid IS 'Batch Detail ID';
COMMENT ON COLUMN sa.x_ota_batch_detail.batchid IS 'Batch ID';
COMMENT ON COLUMN sa.x_ota_batch_detail.send_time IS 'Send Time';
COMMENT ON COLUMN sa.x_ota_batch_detail.esn IS 'Phone Serial Number';
COMMENT ON COLUMN sa.x_ota_batch_detail.status IS 'Satus';
COMMENT ON COLUMN sa.x_ota_batch_detail.error_code IS 'Error Code';
COMMENT ON COLUMN sa.x_ota_batch_detail.ota_trans_id IS 'OTA Transaction ID';
COMMENT ON COLUMN sa.x_ota_batch_detail.error_msg IS 'Error Message';