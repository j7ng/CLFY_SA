CREATE TABLE sa.table_x_parameters (
  objid NUMBER,
  dev NUMBER,
  x_param_name VARCHAR2(50 BYTE),
  x_param_value VARCHAR2(2000 BYTE),
  x_notes VARCHAR2(255 BYTE),
  CONSTRAINT unq_x_param UNIQUE (x_param_name,x_param_value)
);
ALTER TABLE sa.table_x_parameters ADD SUPPLEMENTAL LOG GROUP dmtsora365795125_0 (dev, objid, x_notes, x_param_name, x_param_value) ALWAYS;
COMMENT ON TABLE sa.table_x_parameters IS 'Generic Database Parameters';
COMMENT ON COLUMN sa.table_x_parameters.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_x_parameters.dev IS 'Row version number for mobile distribution purposes';
COMMENT ON COLUMN sa.table_x_parameters.x_param_name IS 'TBD';
COMMENT ON COLUMN sa.table_x_parameters.x_param_value IS 'TBD';
COMMENT ON COLUMN sa.table_x_parameters.x_notes IS 'TBD';