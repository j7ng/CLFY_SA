CREATE TABLE sa.x_serviceplanfeature_value (
  objid NUMBER,
  spf_value2spf NUMBER NOT NULL,
  value_ref NUMBER,
  child_value_ref NUMBER
);
ALTER TABLE sa.x_serviceplanfeature_value ADD SUPPLEMENTAL LOG GROUP dmtsora1926697968_0 (child_value_ref, objid, spf_value2spf, value_ref) ALWAYS;
COMMENT ON TABLE sa.x_serviceplanfeature_value IS 'This is a Many to Many Table that links Service Plan Feature with its value definition.';
COMMENT ON COLUMN sa.x_serviceplanfeature_value.objid IS 'Internal Record ID';
COMMENT ON COLUMN sa.x_serviceplanfeature_value.spf_value2spf IS 'Reference to x_service_plan_feature';
COMMENT ON COLUMN sa.x_serviceplanfeature_value.value_ref IS 'reference to X_SERVICEPLANFEATURE_VALUE_DEF to indicate the value of the feature.';
COMMENT ON COLUMN sa.x_serviceplanfeature_value.child_value_ref IS 'not used';