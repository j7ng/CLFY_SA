CREATE TABLE sa.table_x_subsidy_cost (
  objid NUMBER,
  dev NUMBER,
  x_technology VARCHAR2(10 BYTE),
  x_units NUMBER
);
ALTER TABLE sa.table_x_subsidy_cost ADD SUPPLEMENTAL LOG GROUP dmtsora443708170_0 (dev, objid, x_technology, x_units) ALWAYS;