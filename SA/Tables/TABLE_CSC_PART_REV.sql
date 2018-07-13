CREATE TABLE sa.table_csc_part_rev (
  objid NUMBER,
  vendor VARCHAR2(80 BYTE),
  "VERSION" VARCHAR2(10 BYTE),
  server_id NUMBER,
  dev NUMBER,
  part_rev2csc_part NUMBER(*,0)
);
ALTER TABLE sa.table_csc_part_rev ADD SUPPLEMENTAL LOG GROUP dmtsora1872259594_0 (dev, objid, part_rev2csc_part, server_id, vendor, "VERSION") ALWAYS;