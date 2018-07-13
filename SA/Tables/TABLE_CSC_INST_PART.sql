CREATE TABLE sa.table_csc_inst_part (
  objid NUMBER,
  vendor VARCHAR2(80 BYTE),
  "NAME" VARCHAR2(80 BYTE),
  server_id NUMBER,
  dev NUMBER,
  inst2csc_part_rev NUMBER(*,0)
);
ALTER TABLE sa.table_csc_inst_part ADD SUPPLEMENTAL LOG GROUP dmtsora1625564153_0 (dev, inst2csc_part_rev, "NAME", objid, server_id, vendor) ALWAYS;