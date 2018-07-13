CREATE TABLE sa.table_x_exch_options (
  objid NUMBER,
  dev NUMBER,
  x_priority NUMBER,
  x_exch_type VARCHAR2(20 BYTE),
  exch_source2part_num NUMBER,
  exch_target2part_num NUMBER
);
ALTER TABLE sa.table_x_exch_options ADD SUPPLEMENTAL LOG GROUP dmtsora1701597154_0 (dev, exch_source2part_num, exch_target2part_num, objid, x_exch_type, x_priority) ALWAYS;