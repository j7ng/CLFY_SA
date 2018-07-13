CREATE TABLE sa.tmo_thresholds_order_config (
  objid NUMBER NOT NULL,
  ig_order_type VARCHAR2(20 BYTE),
  description VARCHAR2(100 BYTE),
  active_flag VARCHAR2(1 BYTE) DEFAULT 'N' NOT NULL,
  x_bucket_id VARCHAR2(20 BYTE) NOT NULL,
  x_benefit_type VARCHAR2(20 BYTE) NOT NULL,
  insert_timestamp DATE DEFAULT SYSDATE,
  update_timesatmp DATE DEFAULT SYSDATE,
  UNIQUE (objid)
);
COMMENT ON TABLE sa.tmo_thresholds_order_config IS 'Sending thresholds to TMO based on ig order config';
COMMENT ON COLUMN sa.tmo_thresholds_order_config.objid IS 'Serial number';
COMMENT ON COLUMN sa.tmo_thresholds_order_config.ig_order_type IS 'IG order type';
COMMENT ON COLUMN sa.tmo_thresholds_order_config.description IS 'Description of order type';
COMMENT ON COLUMN sa.tmo_thresholds_order_config.active_flag IS 'To enable or disbale the flag to control the flow';
COMMENT ON COLUMN sa.tmo_thresholds_order_config.x_bucket_id IS 'IG transaction buckets bucket id';
COMMENT ON COLUMN sa.tmo_thresholds_order_config.x_benefit_type IS 'Benefit type of the transaction';
COMMENT ON COLUMN sa.tmo_thresholds_order_config.insert_timestamp IS 'creation date';
COMMENT ON COLUMN sa.tmo_thresholds_order_config.update_timesatmp IS 'Update timestamp';