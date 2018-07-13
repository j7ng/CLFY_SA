CREATE TABLE sa.table_wake_up (
  objid NUMBER,
  wake_up NUMBER,
  dev NUMBER
);
ALTER TABLE sa.table_wake_up ADD SUPPLEMENTAL LOG GROUP dmtsora79173938_0 (dev, objid, wake_up) ALWAYS;