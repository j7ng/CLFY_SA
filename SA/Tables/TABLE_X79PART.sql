CREATE TABLE sa.table_x79part (
  objid NUMBER,
  dev NUMBER,
  vendor VARCHAR2(80 BYTE),
  s_vendor VARCHAR2(80 BYTE),
  server_id NUMBER,
  "NAME" VARCHAR2(30 BYTE),
  s_name VARCHAR2(30 BYTE)
);
ALTER TABLE sa.table_x79part ADD SUPPLEMENTAL LOG GROUP dmtsora1403347244_0 (dev, "NAME", objid, server_id, s_name, s_vendor, vendor) ALWAYS;