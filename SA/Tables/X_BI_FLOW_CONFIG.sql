CREATE TABLE sa.x_bi_flow_config (
  objid NUMBER(22) NOT NULL,
  x_brand_name VARCHAR2(50 BYTE),
  x_channel VARCHAR2(50 BYTE),
  x_bal_cfg_id NUMBER(22),
  x_flow_id VARCHAR2(50 BYTE),
  x_script_id VARCHAR2(50 BYTE),
  x_chl_cfg2metering_scenarios NUMBER(22),
  insert_timestamp DATE DEFAULT SYSDATE,
  update_timestamp DATE DEFAULT SYSDATE,
  CONSTRAINT tf_x_bi_flow_config_pk PRIMARY KEY (objid)
);
COMMENT ON TABLE sa.x_bi_flow_config IS 'Source for the BI with the flow id details';
COMMENT ON COLUMN sa.x_bi_flow_config.objid IS 'Stores the unique identifier for each record';
COMMENT ON COLUMN sa.x_bi_flow_config.x_brand_name IS 'Gives the Brand details like TF,SL';
COMMENT ON COLUMN sa.x_bi_flow_config.x_channel IS 'Channel details like WEB TAS';
COMMENT ON COLUMN sa.x_bi_flow_config.x_flow_id IS 'Flow id for BI';
COMMENT ON COLUMN sa.x_bi_flow_config.x_script_id IS 'Associated script id';
COMMENT ON COLUMN sa.x_bi_flow_config.insert_timestamp IS 'Time and date when the row was entered.';
COMMENT ON COLUMN sa.x_bi_flow_config.update_timestamp IS 'Last date when the record was last modified';