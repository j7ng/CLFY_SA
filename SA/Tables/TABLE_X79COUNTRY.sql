CREATE TABLE sa.table_x79country (
  objid NUMBER,
  dev NUMBER,
  "NAME" VARCHAR2(40 BYTE),
  s_name VARCHAR2(40 BYTE),
  code NUMBER,
  is_default NUMBER,
  server_id NUMBER
);
ALTER TABLE sa.table_x79country ADD SUPPLEMENTAL LOG GROUP dmtsora2121833504_0 (code, dev, is_default, "NAME", objid, server_id, s_name) ALWAYS;