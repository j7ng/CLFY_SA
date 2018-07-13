CREATE TABLE sa.table_x_sec_func (
  objid NUMBER,
  dev NUMBER,
  x_func_id VARCHAR2(10 BYTE),
  x_func_name VARCHAR2(50 BYTE),
  x_func_desc VARCHAR2(100 BYTE),
  x_func_type VARCHAR2(50 BYTE),
  x_func_app VARCHAR2(50 BYTE),
  x_func_create_date DATE,
  x_func_validate_flag VARCHAR2(10 BYTE)
);
ALTER TABLE sa.table_x_sec_func ADD SUPPLEMENTAL LOG GROUP dmtsora1569862035_0 (dev, objid, x_func_app, x_func_create_date, x_func_desc, x_func_id, x_func_name, x_func_type, x_func_validate_flag) ALWAYS;
COMMENT ON TABLE sa.table_x_sec_func IS 'Contains all security access functions';
COMMENT ON COLUMN sa.table_x_sec_func.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_x_sec_func.dev IS 'Row version number for mobile distribution purposes';
COMMENT ON COLUMN sa.table_x_sec_func.x_func_id IS 'Function identification number';
COMMENT ON COLUMN sa.table_x_sec_func.x_func_name IS 'Contains name of the function';
COMMENT ON COLUMN sa.table_x_sec_func.x_func_desc IS 'Contains function description';
COMMENT ON COLUMN sa.table_x_sec_func.x_func_type IS 'Contains the function type';
COMMENT ON COLUMN sa.table_x_sec_func.x_func_app IS 'contains the application associated to the function';
COMMENT ON COLUMN sa.table_x_sec_func.x_func_create_date IS 'Contains the date the function was created';
COMMENT ON COLUMN sa.table_x_sec_func.x_func_validate_flag IS 'Flag if function is valid or invalid';