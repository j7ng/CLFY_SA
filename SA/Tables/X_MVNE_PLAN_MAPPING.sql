CREATE TABLE sa.x_mvne_plan_mapping (
  x_mvne_plan_id VARCHAR2(100 BYTE),
  x_tf_plan_name VARCHAR2(200 BYTE),
  x_service_plan VARCHAR2(20 BYTE),
  x_brand_name VARCHAR2(20 BYTE)
);
COMMENT ON TABLE sa.x_mvne_plan_mapping IS 'mvne plan mapping table';
COMMENT ON COLUMN sa.x_mvne_plan_mapping.x_mvne_plan_id IS 'mvne plan name';
COMMENT ON COLUMN sa.x_mvne_plan_mapping.x_tf_plan_name IS 'tracfone plan';
COMMENT ON COLUMN sa.x_mvne_plan_mapping.x_service_plan IS 'service plan';
COMMENT ON COLUMN sa.x_mvne_plan_mapping.x_brand_name IS 'brand';