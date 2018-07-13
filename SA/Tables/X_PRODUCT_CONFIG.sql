CREATE TABLE sa.x_product_config (
  objid NUMBER(22) NOT NULL,
  brand_name VARCHAR2(50 BYTE),
  parent_name VARCHAR2(50 BYTE),
  device_type VARCHAR2(50 BYTE),
  device_tech VARCHAR2(50 BYTE),
  part_class VARCHAR2(40 BYTE),
  part_number VARCHAR2(30 BYTE),
  voice_mtg_source VARCHAR2(50 BYTE),
  sms_mtg_source VARCHAR2(50 BYTE),
  data_mtg_source VARCHAR2(50 BYTE),
  ild_mtg_source VARCHAR2(50 BYTE),
  service_plan_group VARCHAR2(50 BYTE),
  service_plan_id NUMBER(22),
  bal_cfg_id_web NUMBER(22),
  bal_cfg_id_ivr NUMBER(22),
  insert_timestamp DATE DEFAULT SYSDATE NOT NULL,
  update_timestamp DATE DEFAULT SYSDATE NOT NULL,
  source_system VARCHAR2(100 BYTE),
  bal_cfg_id_tas NUMBER(22),
  CONSTRAINT tf_x_product_config_pk PRIMARY KEY (objid)
);
COMMENT ON TABLE sa.x_product_config IS 'Stores the details about a product';
COMMENT ON COLUMN sa.x_product_config.objid IS 'Stores the unique identifier for each record';
COMMENT ON COLUMN sa.x_product_config.brand_name IS 'Gives the Brand details like TF,SL';
COMMENT ON COLUMN sa.x_product_config.parent_name IS 'Parent carrier name ';
COMMENT ON COLUMN sa.x_product_config.device_type IS 'Describes the details about the device';
COMMENT ON COLUMN sa.x_product_config.device_tech IS 'Technology of device';
COMMENT ON COLUMN sa.x_product_config.voice_mtg_source IS 'Voice Metering source value mapped to short_name in x_usage_host';
COMMENT ON COLUMN sa.x_product_config.sms_mtg_source IS 'sms Metering source value mapped to short_name in x_usage_host';
COMMENT ON COLUMN sa.x_product_config.data_mtg_source IS 'data Metering source value mapped to short_name in x_usage_host';
COMMENT ON COLUMN sa.x_product_config.ild_mtg_source IS 'ild Metering source value mapped to short_name in x_usage_host';
COMMENT ON COLUMN sa.x_product_config.service_plan_group IS 'Associate  service plan group';
COMMENT ON COLUMN sa.x_product_config.service_plan_id IS 'Service plan id';
COMMENT ON COLUMN sa.x_product_config.bal_cfg_id_web IS 'Web balance inquiry config id mapped to X_BAL_CFG_ID in x_bi_flow_config';
COMMENT ON COLUMN sa.x_product_config.bal_cfg_id_ivr IS 'IVR balance inquiry config id mapped to X_BAL_CFG_ID in x_bi_flow_config';
COMMENT ON COLUMN sa.x_product_config.insert_timestamp IS 'Time and date when the row was entered.';
COMMENT ON COLUMN sa.x_product_config.update_timestamp IS 'Last date when the record was last modified';
COMMENT ON COLUMN sa.x_product_config.source_system IS 'Source system';