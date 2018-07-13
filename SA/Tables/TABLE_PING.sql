CREATE TABLE sa.table_ping (
  objid NUMBER,
  ping NUMBER,
  dev NUMBER
);
ALTER TABLE sa.table_ping ADD SUPPLEMENTAL LOG GROUP dmtsora1122511520_0 (dev, objid, ping) ALWAYS;