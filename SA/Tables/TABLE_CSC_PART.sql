CREATE TABLE sa.table_csc_part (
  objid NUMBER,
  vendor VARCHAR2(80 BYTE),
  "NAME" VARCHAR2(30 BYTE),
  relation NUMBER,
  csc_order VARCHAR2(10 BYTE),
  server_id NUMBER,
  dev NUMBER
);
ALTER TABLE sa.table_csc_part ADD SUPPLEMENTAL LOG GROUP dmtsora1966007414_0 (csc_order, dev, "NAME", objid, relation, server_id, vendor) ALWAYS;