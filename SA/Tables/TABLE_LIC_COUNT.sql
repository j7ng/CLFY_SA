CREATE TABLE sa.table_lic_count (
  objid NUMBER,
  lic_type VARCHAR2(30 BYTE),
  paid_lic_count NUMBER,
  max_lic_count NUMBER,
  lic_used NUMBER,
  times_graced NUMBER,
  dev NUMBER
);
ALTER TABLE sa.table_lic_count ADD SUPPLEMENTAL LOG GROUP dmtsora498505180_0 (dev, lic_type, lic_used, max_lic_count, objid, paid_lic_count, times_graced) ALWAYS;