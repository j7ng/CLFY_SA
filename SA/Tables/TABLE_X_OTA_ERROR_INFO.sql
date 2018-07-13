CREATE TABLE sa.table_x_ota_error_info (
  objid NUMBER,
  x_ota_error_code VARCHAR2(30 BYTE),
  x_ota_error_type VARCHAR2(30 BYTE),
  x_ota_error_message VARCHAR2(200 BYTE),
  ota_err2ota_trans_dtl NUMBER
);
ALTER TABLE sa.table_x_ota_error_info ADD SUPPLEMENTAL LOG GROUP dmtsora668870086_0 (objid, ota_err2ota_trans_dtl, x_ota_error_code, x_ota_error_message, x_ota_error_type) ALWAYS;
COMMENT ON TABLE sa.table_x_ota_error_info IS 'Error codes for OTA parameters';
COMMENT ON COLUMN sa.table_x_ota_error_info.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_x_ota_error_info.x_ota_error_code IS 'OTA Error code';
COMMENT ON COLUMN sa.table_x_ota_error_info.x_ota_error_type IS 'OTA Error type';
COMMENT ON COLUMN sa.table_x_ota_error_info.x_ota_error_message IS 'OTA Error Message';
COMMENT ON COLUMN sa.table_x_ota_error_info.ota_err2ota_trans_dtl IS 'TBD';