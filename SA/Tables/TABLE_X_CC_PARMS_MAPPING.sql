CREATE TABLE sa.table_x_cc_parms_mapping (
  objid NUMBER,
  x_part_class VARCHAR2(80 BYTE),
  x_part_num VARCHAR2(80 BYTE),
  x_domain VARCHAR2(80 BYTE),
  x_source_system VARCHAR2(80 BYTE),
  mapping2cc_parms NUMBER,
  mapping2part_num NUMBER,
  x_sub_brand VARCHAR2(80 BYTE)
);
COMMENT ON TABLE sa.table_x_cc_parms_mapping IS 'Mapping table for table_x_cc_parms';
COMMENT ON COLUMN sa.table_x_cc_parms_mapping.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_x_cc_parms_mapping.x_part_class IS 'Part Class';
COMMENT ON COLUMN sa.table_x_cc_parms_mapping.x_part_num IS 'Part Number';
COMMENT ON COLUMN sa.table_x_cc_parms_mapping.x_domain IS 'Name of the domain for the part num';
COMMENT ON COLUMN sa.table_x_cc_parms_mapping.x_source_system IS 'Source system';
COMMENT ON COLUMN sa.table_x_cc_parms_mapping.mapping2cc_parms IS 'Relation to table_x_cc_parms';
COMMENT ON COLUMN sa.table_x_cc_parms_mapping.mapping2part_num IS 'Relation to table_part_num';
COMMENT ON COLUMN sa.table_x_cc_parms_mapping.x_sub_brand IS 'Sub brand';