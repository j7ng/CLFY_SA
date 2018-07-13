CREATE TABLE sa.x_functions (
  x_func_objid NUMBER,
  x_func_name VARCHAR2(100 BYTE),
  x_func_descr VARCHAR2(200 BYTE),
  create_date DATE,
  CONSTRAINT func_uq UNIQUE (x_func_name)
);
COMMENT ON TABLE sa.x_functions IS 'Error Mapping Functions. Lookup Table';
COMMENT ON COLUMN sa.x_functions.x_func_objid IS 'Primary Key ';
COMMENT ON COLUMN sa.x_functions.x_func_name IS 'Name of the Function';
COMMENT ON COLUMN sa.x_functions.x_func_descr IS 'Description of the Function';
COMMENT ON COLUMN sa.x_functions.create_date IS 'Sysdate at the time of record creation.';