CREATE TABLE sa.x_moneygram_error_codes (
  tf_error_code NUMBER,
  mg_valid VARCHAR2(30 BYTE),
  mg_response_code VARCHAR2(30 BYTE),
  mg_error_msg VARCHAR2(200 BYTE)
);
COMMENT ON TABLE sa.x_moneygram_error_codes IS 'TO SAVE MAPPING BETWEEN ERRORS THAT WE HANDLE FOR MONEYGRAM AND TRACFONE';
COMMENT ON COLUMN sa.x_moneygram_error_codes.tf_error_code IS 'TRACFONE ERROR CODE';
COMMENT ON COLUMN sa.x_moneygram_error_codes.mg_valid IS 'MONEYGRAM VALID STATUS';
COMMENT ON COLUMN sa.x_moneygram_error_codes.mg_response_code IS 'MONEYGRAM RESPONSE CODE';
COMMENT ON COLUMN sa.x_moneygram_error_codes.mg_error_msg IS 'MONEYGRAM ERROR MSG';