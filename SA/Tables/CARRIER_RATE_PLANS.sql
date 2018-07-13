CREATE TABLE sa.carrier_rate_plans (
  objid NUMBER(22) NOT NULL,
  x_rate_plan VARCHAR2(200 BYTE) NOT NULL,
  x_carrier VARCHAR2(200 BYTE) NOT NULL,
  x_start_date DATE,
  x_end_date DATE,
  x_created_on DATE,
  x_modified_on DATE,
  x_modified_by VARCHAR2(200 BYTE),
  PRIMARY KEY (objid)
);