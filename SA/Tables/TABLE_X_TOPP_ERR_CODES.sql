CREATE TABLE sa.table_x_topp_err_codes (
  objid NUMBER,
  x_code_name VARCHAR2(80 BYTE),
  x_message VARCHAR2(255 BYTE),
  x_add_date DATE,
  x_topp_err_codes2user NUMBER
);
ALTER TABLE sa.table_x_topp_err_codes ADD SUPPLEMENTAL LOG GROUP dmtsora1647316487_0 (objid, x_add_date, x_code_name, x_message, x_topp_err_codes2user) ALWAYS;
COMMENT ON TABLE sa.table_x_topp_err_codes IS 'Stores carrier text information';
COMMENT ON COLUMN sa.table_x_topp_err_codes.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_x_topp_err_codes.x_code_name IS 'Topp error code';
COMMENT ON COLUMN sa.table_x_topp_err_codes.x_message IS 'Topp error messages';
COMMENT ON COLUMN sa.table_x_topp_err_codes.x_add_date IS 'Date added to Table';
COMMENT ON COLUMN sa.table_x_topp_err_codes.x_topp_err_codes2user IS 'codes added by users';