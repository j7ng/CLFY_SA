CREATE TABLE sa.x_product_config_detail (
  objid NUMBER NOT NULL,
  prod_conf2prod_conf_dtl NUMBER,
  bucket_id VARCHAR2(400 BYTE) NOT NULL,
  mtg_src_id VARCHAR2(400 BYTE) NOT NULL,
  CONSTRAINT pk_product_config_detail PRIMARY KEY (objid),
  CONSTRAINT fk1_product_config_detail FOREIGN KEY (prod_conf2prod_conf_dtl) REFERENCES sa.x_product_config (objid)
);
COMMENT ON COLUMN sa.x_product_config_detail.prod_conf2prod_conf_dtl IS 'Link to x_product_config table';
COMMENT ON COLUMN sa.x_product_config_detail.bucket_id IS 'Bucket type';
COMMENT ON COLUMN sa.x_product_config_detail.mtg_src_id IS 'Metering source';