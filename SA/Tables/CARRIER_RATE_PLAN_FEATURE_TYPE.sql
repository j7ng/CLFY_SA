CREATE TABLE sa.carrier_rate_plan_feature_type (
  objid NUMBER(22),
  x_feature_type VARCHAR2(200 BYTE) NOT NULL,
  x_notes VARCHAR2(1000 BYTE),
  PRIMARY KEY (x_feature_type)
);