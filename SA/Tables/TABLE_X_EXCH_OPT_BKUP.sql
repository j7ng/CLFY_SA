CREATE TABLE sa.table_x_exch_opt_bkup (
  objid NUMBER,
  dev NUMBER,
  x_priority NUMBER,
  x_exch_type VARCHAR2(20 BYTE),
  source2part_class NUMBER,
  x_new_part_num VARCHAR2(30 BYTE),
  x_used_part_num VARCHAR2(30 BYTE),
  x_days_for_used_part NUMBER
);
ALTER TABLE sa.table_x_exch_opt_bkup ADD SUPPLEMENTAL LOG GROUP dmtsora1908875627_0 (dev, objid, source2part_class, x_days_for_used_part, x_exch_type, x_new_part_num, x_priority, x_used_part_num) ALWAYS;