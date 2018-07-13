CREATE TABLE sa.table_x_carrier_err_codes (
  objid NUMBER,
  x_code_name VARCHAR2(80 BYTE),
  x_add_date DATE,
  ccodes2x_topp_err_codes NUMBER,
  x_car_er2x_carrier NUMBER,
  x_car_er2user NUMBER
);
ALTER TABLE sa.table_x_carrier_err_codes ADD SUPPLEMENTAL LOG GROUP dmtsora786031475_0 (ccodes2x_topp_err_codes, objid, x_add_date, x_car_er2user, x_car_er2x_carrier, x_code_name) ALWAYS;
COMMENT ON TABLE sa.table_x_carrier_err_codes IS 'Stores carrier text information';
COMMENT ON COLUMN sa.table_x_carrier_err_codes.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_x_carrier_err_codes.x_code_name IS 'Carrier code name';
COMMENT ON COLUMN sa.table_x_carrier_err_codes.x_add_date IS 'Date added';
COMMENT ON COLUMN sa.table_x_carrier_err_codes.ccodes2x_topp_err_codes IS 'Related error codes';
COMMENT ON COLUMN sa.table_x_carrier_err_codes.x_car_er2x_carrier IS 'Error codes per carrier';
COMMENT ON COLUMN sa.table_x_carrier_err_codes.x_car_er2user IS 'codes added by users';