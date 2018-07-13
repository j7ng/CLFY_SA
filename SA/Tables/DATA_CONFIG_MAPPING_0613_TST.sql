CREATE TABLE sa.data_config_mapping_0613_tst (
  x_parent_id VARCHAR2(30 BYTE),
  x_part_class_objid NUMBER,
  x_rate_plan VARCHAR2(30 BYTE),
  x_data_config_objid NUMBER
);
COMMENT ON TABLE sa.data_config_mapping_0613_tst IS 'Carrier APN / Access Point Name Mapping Configurations';
COMMENT ON COLUMN sa.data_config_mapping_0613_tst.x_parent_id IS 'FK to the Carrier in TABLE_X_CARRIER';
COMMENT ON COLUMN sa.data_config_mapping_0613_tst.x_part_class_objid IS 'FK to the Model in TABLE_PART_CLASS ';
COMMENT ON COLUMN sa.data_config_mapping_0613_tst.x_rate_plan IS 'Rate Plan';
COMMENT ON COLUMN sa.data_config_mapping_0613_tst.x_data_config_objid IS 'FK to TABLE_X_DATA_CONFIG';