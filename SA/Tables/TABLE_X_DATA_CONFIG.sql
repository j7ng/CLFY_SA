CREATE TABLE sa.table_x_data_config (
  objid NUMBER,
  dev NUMBER,
  x_parent_id VARCHAR2(30 BYTE),
  x_part_class_objid NUMBER,
  x_default NUMBER,
  x_ip_address VARCHAR2(30 BYTE),
  x_apn VARCHAR2(30 BYTE),
  x_homepage VARCHAR2(150 BYTE),
  x_mmsc VARCHAR2(150 BYTE),
  cmd_148_carrier_data_switch VARCHAR2(1 BYTE),
  x_data_switch NUMBER,
  cmd_71_gprs_apn VARCHAR2(1 BYTE),
  cmd_150_clear_proxy VARCHAR2(1 BYTE),
  cmd_121_gateway_port_update VARCHAR2(1 BYTE),
  cmd_121_gateway_ip_update VARCHAR2(1 BYTE),
  cmd_71_mmsc_update VARCHAR2(1 BYTE),
  cmd_71_gateway_home VARCHAR2(1 BYTE),
  cmd_121_gateway_ip_port_update NUMBER(22)
);
ALTER TABLE sa.table_x_data_config ADD SUPPLEMENTAL LOG GROUP dmtsora1565492749_0 (dev, objid, x_apn, x_default, x_homepage, x_ip_address, x_mmsc, x_parent_id, x_part_class_objid) ALWAYS;
COMMENT ON TABLE sa.table_x_data_config IS 'Data Features phone configuration';
COMMENT ON COLUMN sa.table_x_data_config.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_x_data_config.dev IS 'Row version number for mobile distribution purposes';
COMMENT ON COLUMN sa.table_x_data_config.x_parent_id IS 'TBD';
COMMENT ON COLUMN sa.table_x_data_config.x_part_class_objid IS 'TBD';
COMMENT ON COLUMN sa.table_x_data_config.x_default IS 'TBD';
COMMENT ON COLUMN sa.table_x_data_config.x_ip_address IS 'TBD';
COMMENT ON COLUMN sa.table_x_data_config.x_apn IS 'TBD';
COMMENT ON COLUMN sa.table_x_data_config.x_homepage IS 'TBD';
COMMENT ON COLUMN sa.table_x_data_config.x_mmsc IS 'TBD';
COMMENT ON COLUMN sa.table_x_data_config.cmd_148_carrier_data_switch IS 'command parameter based on the carrier id and will be read from the column x_data_switch';
COMMENT ON COLUMN sa.table_x_data_config.x_data_switch IS 'command parameter used to generate JAVA calculation';
COMMENT ON COLUMN sa.table_x_data_config.cmd_71_gprs_apn IS 'command parameter used to pass in the value from the column x_apn';
COMMENT ON COLUMN sa.table_x_data_config.cmd_150_clear_proxy IS 'Non parameter command a hard coded value as per engineering';
COMMENT ON COLUMN sa.table_x_data_config.cmd_121_gateway_port_update IS 'command parameter used to generate the port update';
COMMENT ON COLUMN sa.table_x_data_config.cmd_121_gateway_ip_update IS 'command parameter used to generate the ip update';
COMMENT ON COLUMN sa.table_x_data_config.cmd_71_mmsc_update IS 'command parameter used to pass value of the x_mmsc';
COMMENT ON COLUMN sa.table_x_data_config.cmd_71_gateway_home IS 'command parameter used to pass value from the column x_homepage';