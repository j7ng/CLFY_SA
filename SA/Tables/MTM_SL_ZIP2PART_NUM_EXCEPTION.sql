CREATE TABLE sa.mtm_sl_zip2part_num_exception (
  table_x_zip_code_objid NUMBER,
  program_param_objid NUMBER,
  safelink_zip2part_num NUMBER
);
COMMENT ON COLUMN sa.mtm_sl_zip2part_num_exception.table_x_zip_code_objid IS 'Objid from TABLE_X_ZIP_CODE';
COMMENT ON COLUMN sa.mtm_sl_zip2part_num_exception.program_param_objid IS 'Objid from X_PROGRAM_PARAMETER';
COMMENT ON COLUMN sa.mtm_sl_zip2part_num_exception.safelink_zip2part_num IS 'PART NUMBER ASSOCIATED WITH SAFELINK CUSTOMERS';