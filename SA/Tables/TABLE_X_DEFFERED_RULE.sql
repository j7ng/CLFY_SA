CREATE TABLE sa.table_x_deffered_rule (
  objid NUMBER,
  dev NUMBER,
  x_plan_type VARCHAR2(20 BYTE),
  x_month_no NUMBER,
  x_month_value NUMBER
);
ALTER TABLE sa.table_x_deffered_rule ADD SUPPLEMENTAL LOG GROUP dmtsora680267371_0 (dev, objid, x_month_no, x_month_value, x_plan_type) ALWAYS;