CREATE TABLE sa.mtm_sp_carrierfeatures (
  x_service_plan_id NUMBER,
  x_carrier_features_id NUMBER,
  "PRIORITY" NUMBER
);
ALTER TABLE sa.mtm_sp_carrierfeatures ADD SUPPLEMENTAL LOG GROUP dmtsora929995152_0 ("PRIORITY", x_carrier_features_id, x_service_plan_id) ALWAYS;
COMMENT ON TABLE sa.mtm_sp_carrierfeatures IS 'Carrier features available for a given service plan, many to many relation.';
COMMENT ON COLUMN sa.mtm_sp_carrierfeatures.x_service_plan_id IS 'Reference to OBJID OF X_SERVICE_PLAN  ';
COMMENT ON COLUMN sa.mtm_sp_carrierfeatures.x_carrier_features_id IS 'Reference to objid of table table_X_CARRIER_FEATURES';
COMMENT ON COLUMN sa.mtm_sp_carrierfeatures."PRIORITY" IS 'priority level';