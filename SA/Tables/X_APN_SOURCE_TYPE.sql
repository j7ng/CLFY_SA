CREATE TABLE sa.x_apn_source_type (
  apn_source_type VARCHAR2(4 BYTE) NOT NULL,
  description VARCHAR2(200 BYTE),
  apn_order_type VARCHAR2(20 BYTE),
  "TEMPLATE" VARCHAR2(4 BYTE),
  validate_rate_plan_flag VARCHAR2(1 BYTE) NOT NULL,
  PRIMARY KEY (apn_source_type)
);
COMMENT ON TABLE sa.x_apn_source_type IS 'Table for storing the APN source type information';