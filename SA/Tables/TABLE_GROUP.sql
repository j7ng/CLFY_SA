CREATE TABLE sa.table_group (
  objid NUMBER,
  "NAME" VARCHAR2(32 BYTE),
  "TYPE" NUMBER,
  status NUMBER,
  dev NUMBER,
  group_hier2group NUMBER(*,0)
);
ALTER TABLE sa.table_group ADD SUPPLEMENTAL LOG GROUP dmtsora1937816008_0 (dev, group_hier2group, "NAME", objid, status, "TYPE") ALWAYS;