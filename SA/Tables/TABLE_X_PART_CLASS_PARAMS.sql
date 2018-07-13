CREATE TABLE sa.table_x_part_class_params (
  objid NUMBER,
  dev NUMBER,
  x_param_name VARCHAR2(50 BYTE),
  x_param_info VARCHAR2(200 BYTE)
);
ALTER TABLE sa.table_x_part_class_params ADD SUPPLEMENTAL LOG GROUP dmtsora1134923491_0 (dev, objid, x_param_info, x_param_name) ALWAYS;
COMMENT ON TABLE sa.table_x_part_class_params IS 'Additional Part Class Parameters';
COMMENT ON COLUMN sa.table_x_part_class_params.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_x_part_class_params.dev IS 'Row version number for mobile distribution purposes';
COMMENT ON COLUMN sa.table_x_part_class_params.x_param_name IS 'Parameter Name';
COMMENT ON COLUMN sa.table_x_part_class_params.x_param_info IS 'Description, valid values, restrictions, intended use';