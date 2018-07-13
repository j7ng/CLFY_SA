CREATE TABLE sa.mtm_carrier_rate_plan_feature (
  objid NUMBER,
  x_feature_id NUMBER,
  x_feature_value VARCHAR2(100 BYTE) NOT NULL,
  x_feature_type VARCHAR2(100 BYTE) NOT NULL,
  x_restriction VARCHAR2(100 BYTE) NOT NULL,
  x_rate_plan_id NUMBER(22) NOT NULL,
  x_gui_display_name VARCHAR2(200 BYTE),
  throttle_state NUMBER(5),
  no_throttle_state NUMBER(5),
  x_created_on DATE,
  x_modified_on DATE,
  x_modified_by VARCHAR2(200 BYTE)
);