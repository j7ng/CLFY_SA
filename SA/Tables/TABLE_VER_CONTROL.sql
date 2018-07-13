CREATE TABLE sa.table_ver_control (
  objid NUMBER,
  node_id VARCHAR2(3 BYTE),
  "TYPE" VARCHAR2(30 BYTE),
  "NAME" VARCHAR2(80 BYTE),
  lo_version VARCHAR2(40 BYTE),
  hi_version VARCHAR2(40 BYTE),
  as_of_date DATE,
  dev NUMBER
);
ALTER TABLE sa.table_ver_control ADD SUPPLEMENTAL LOG GROUP dmtsora261373004_0 (as_of_date, dev, hi_version, lo_version, "NAME", node_id, objid, "TYPE") ALWAYS;