CREATE TABLE sa.x_serviceplan_audit_hist (
  objid NUMBER,
  "ACTION" VARCHAR2(50 BYTE),
  old_service_plan_objid NUMBER,
  old_mkt_name VARCHAR2(50 BYTE),
  old_description VARCHAR2(250 BYTE),
  old_customer_price NUMBER,
  old_ivr_plan_id NUMBER,
  x_last_modified_date DATE,
  new_service_plan_objid NUMBER,
  new_mkt_name VARCHAR2(50 BYTE),
  new_description VARCHAR2(250 BYTE),
  new_customer_price NUMBER,
  new_ivr_plan_id NUMBER
);
COMMENT ON TABLE sa.x_serviceplan_audit_hist IS 'Track DML on table X_SERVICE_PLAN';
COMMENT ON COLUMN sa.x_serviceplan_audit_hist.objid IS 'Internal record number';
COMMENT ON COLUMN sa.x_serviceplan_audit_hist."ACTION" IS 'Type of DML: Update, Insert or Delete';
COMMENT ON COLUMN sa.x_serviceplan_audit_hist.old_service_plan_objid IS 'Old objid of table X_SERVICE_PLAN';
COMMENT ON COLUMN sa.x_serviceplan_audit_hist.old_mkt_name IS 'Old Market Name';
COMMENT ON COLUMN sa.x_serviceplan_audit_hist.old_description IS 'Old Description';
COMMENT ON COLUMN sa.x_serviceplan_audit_hist.old_customer_price IS 'Old Customer Price';
COMMENT ON COLUMN sa.x_serviceplan_audit_hist.old_ivr_plan_id IS 'Old IVR plan ID';
COMMENT ON COLUMN sa.x_serviceplan_audit_hist.x_last_modified_date IS 'DaTime of DML';
COMMENT ON COLUMN sa.x_serviceplan_audit_hist.new_service_plan_objid IS 'New objid of table X_SERVICE_PLAN';
COMMENT ON COLUMN sa.x_serviceplan_audit_hist.new_mkt_name IS 'New Market Name';
COMMENT ON COLUMN sa.x_serviceplan_audit_hist.new_description IS 'New Description';
COMMENT ON COLUMN sa.x_serviceplan_audit_hist.new_customer_price IS 'New Customer Price';
COMMENT ON COLUMN sa.x_serviceplan_audit_hist.new_ivr_plan_id IS 'New IVR plan ID';