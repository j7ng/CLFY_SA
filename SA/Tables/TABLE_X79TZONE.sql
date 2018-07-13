CREATE TABLE sa.table_x79tzone (
  objid NUMBER,
  dev NUMBER,
  "NAME" VARCHAR2(20 BYTE),
  s_name VARCHAR2(20 BYTE),
  full_name VARCHAR2(255 BYTE),
  gmt_diff NUMBER,
  is_default NUMBER,
  server_id NUMBER
);
ALTER TABLE sa.table_x79tzone ADD SUPPLEMENTAL LOG GROUP dmtsora550412296_0 (dev, full_name, gmt_diff, is_default, "NAME", objid, server_id, s_name) ALWAYS;