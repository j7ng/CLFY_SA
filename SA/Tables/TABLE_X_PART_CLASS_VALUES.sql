CREATE TABLE sa.table_x_part_class_values (
  objid NUMBER,
  dev NUMBER,
  x_param_value VARCHAR2(50 BYTE),
  value2class_param NUMBER,
  value2part_class NUMBER
);
ALTER TABLE sa.table_x_part_class_values ADD SUPPLEMENTAL LOG GROUP dmtsora1288521304_0 (dev, objid, value2class_param, value2part_class, x_param_value) ALWAYS;
COMMENT ON TABLE sa.table_x_part_class_values IS 'Values for Part Class Parameters';
COMMENT ON COLUMN sa.table_x_part_class_values.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_x_part_class_values.dev IS 'Row version number for mobile distribution purposes';
COMMENT ON COLUMN sa.table_x_part_class_values.x_param_value IS 'TBD';
COMMENT ON COLUMN sa.table_x_part_class_values.value2class_param IS 'TBD';
COMMENT ON COLUMN sa.table_x_part_class_values.value2part_class IS 'TBD';