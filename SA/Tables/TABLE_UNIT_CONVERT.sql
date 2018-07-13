CREATE TABLE sa.table_unit_convert (
  objid NUMBER,
  from_unit VARCHAR2(20 BYTE),
  to_unit VARCHAR2(20 BYTE),
  "FACTOR" NUMBER,
  dev NUMBER
);
ALTER TABLE sa.table_unit_convert ADD SUPPLEMENTAL LOG GROUP dmtsora524441281_0 (dev, "FACTOR", from_unit, objid, to_unit) ALWAYS;