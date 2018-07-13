CREATE TABLE sa.table_x_upg_units2esn (
  objid NUMBER,
  dev NUMBER,
  x_start_date DATE,
  x_end_date DATE,
  x_units_type VARCHAR2(200 BYTE),
  upg_units2case NUMBER,
  upg_units2part_inst NUMBER
);
ALTER TABLE sa.table_x_upg_units2esn ADD SUPPLEMENTAL LOG GROUP dmtsora1990699365_0 (dev, objid, upg_units2case, upg_units2part_inst, x_end_date, x_start_date, x_units_type) ALWAYS;