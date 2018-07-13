CREATE TABLE sa.carrier_rate_plan_features (
  objid NUMBER(22),
  x_feature_name VARCHAR2(100 BYTE) NOT NULL,
  x_feature_desc VARCHAR2(500 BYTE),
  x_start_date DATE,
  x_end_date DATE,
  x_created_on DATE,
  x_modified_on DATE,
  x_modified_by VARCHAR2(200 BYTE),
  x_feature_group_id NUMBER(22)
);