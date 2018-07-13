CREATE TABLE sa.x_apn_config_mapping (
  objid NUMBER(22) NOT NULL,
  phone_manufacturer VARCHAR2(100 BYTE),
  device_type VARCHAR2(100 BYTE),
  bus_org VARCHAR2(100 BYTE),
  technology VARCHAR2(100 BYTE),
  clone_ig_flag VARCHAR2(1 BYTE),
  inactive_flag VARCHAR2(1 BYTE) DEFAULT 'N',
  part_num_sourcesystem VARCHAR2(30 BYTE),
  CONSTRAINT pk_apn_config_mapping PRIMARY KEY (objid)
);
COMMENT ON TABLE sa.x_apn_config_mapping IS 'Table used to store the x_apn_config_mapping.';
COMMENT ON COLUMN sa.x_apn_config_mapping.objid IS 'unique record identifier';
COMMENT ON COLUMN sa.x_apn_config_mapping.phone_manufacturer IS 'reference to phone_manufacturer';
COMMENT ON COLUMN sa.x_apn_config_mapping.device_type IS 'reference to device_type';
COMMENT ON COLUMN sa.x_apn_config_mapping.bus_org IS 'reference to brand';
COMMENT ON COLUMN sa.x_apn_config_mapping.technology IS 'reference to technology GSM,CDMA';
COMMENT ON COLUMN sa.x_apn_config_mapping.clone_ig_flag IS 'Check the ig_transaction exist or not';
COMMENT ON COLUMN sa.x_apn_config_mapping.inactive_flag IS 'Is used to inactivate the record  ';