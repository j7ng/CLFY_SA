CREATE TABLE sa.x_error_codes (
  x_error_objid NUMBER,
  x_error_code VARCHAR2(30 BYTE),
  x_error_descr VARCHAR2(200 BYTE),
  create_date DATE,
  CONSTRAINT ec_uq UNIQUE (x_error_code)
);
COMMENT ON TABLE sa.x_error_codes IS 'Error mapping table';
COMMENT ON COLUMN sa.x_error_codes.x_error_objid IS 'Primary Key, Unique reference';
COMMENT ON COLUMN sa.x_error_codes.x_error_code IS 'Error Code Number';
COMMENT ON COLUMN sa.x_error_codes.x_error_descr IS 'Error Code Description';
COMMENT ON COLUMN sa.x_error_codes.create_date IS 'Sysdate at the time of the record creation';