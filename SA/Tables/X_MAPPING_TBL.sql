CREATE TABLE sa.x_mapping_tbl (
  x_script_name VARCHAR2(25 BYTE),
  x_error_objid NUMBER,
  x_flow_objid NUMBER,
  x_func_objid NUMBER
);
COMMENT ON TABLE sa.x_mapping_tbl IS 'Error mapping table, deletermines the script to display based on flow, function, error';
COMMENT ON COLUMN sa.x_mapping_tbl.x_script_name IS 'Reference table_x_scripts using  Script Type concatenated with Script Id.';
COMMENT ON COLUMN sa.x_mapping_tbl.x_error_objid IS 'FK to x_error_codes table';
COMMENT ON COLUMN sa.x_mapping_tbl.x_flow_objid IS 'FK to x_flows table';
COMMENT ON COLUMN sa.x_mapping_tbl.x_func_objid IS 'FK to x_fucntions table';