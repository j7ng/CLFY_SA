CREATE TABLE sa.x_service_plan (
  objid NUMBER,
  mkt_name VARCHAR2(50 BYTE),
  description VARCHAR2(250 BYTE),
  customer_price NUMBER NOT NULL,
  ivr_plan_id NUMBER,
  webcsr_display_name VARCHAR2(50 BYTE)
);
COMMENT ON TABLE sa.x_service_plan IS 'Service Plan Definition Header.  A Service Plan is an structure of features, values and part classes that provide or can subscrive to the service plan.';
COMMENT ON COLUMN sa.x_service_plan.objid IS 'Internal Record Id';
COMMENT ON COLUMN sa.x_service_plan.mkt_name IS 'Service Plan Name';
COMMENT ON COLUMN sa.x_service_plan.description IS 'Service Plan Description';
COMMENT ON COLUMN sa.x_service_plan.customer_price IS 'Retail Price';
COMMENT ON COLUMN sa.x_service_plan.ivr_plan_id IS 'Reference to IVR Plan ID';
COMMENT ON COLUMN sa.x_service_plan.webcsr_display_name IS 'display name for webcsr';