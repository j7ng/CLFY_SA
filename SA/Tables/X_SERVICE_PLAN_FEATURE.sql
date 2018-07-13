CREATE TABLE sa.x_service_plan_feature (
  objid NUMBER,
  sp_feature2rest_value_def NUMBER NOT NULL,
  sp_feature2service_plan NUMBER NOT NULL
);
ALTER TABLE sa.x_service_plan_feature ADD SUPPLEMENTAL LOG GROUP dmtsora1726689575_0 (objid, sp_feature2rest_value_def, sp_feature2service_plan) ALWAYS;
COMMENT ON COLUMN sa.x_service_plan_feature.objid IS 'Internal Record ID';
COMMENT ON COLUMN sa.x_service_plan_feature.sp_feature2rest_value_def IS 'Reference to X_SERVICEPLANFEATUREVALUE_DEF';
COMMENT ON COLUMN sa.x_service_plan_feature.sp_feature2service_plan IS 'Reference to x_service_plan';