CREATE TABLE sa.sp_mtm_surepay (
  service_plan_objid NUMBER,
  surepay_conv_objid NUMBER
);
COMMENT ON TABLE sa.sp_mtm_surepay IS 'MTM FOR X_SERVICE_PLAN ANDSA.X_SUREPAY_CONV';
COMMENT ON COLUMN sa.sp_mtm_surepay.service_plan_objid IS 'OBJID FROM X_SERVICE_PLAN';
COMMENT ON COLUMN sa.sp_mtm_surepay.surepay_conv_objid IS 'OBJID FROMSA.X_SUREPAY_CONV';