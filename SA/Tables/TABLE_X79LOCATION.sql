CREATE TABLE sa.table_x79location (
  objid NUMBER,
  dev NUMBER,
  premises_name VARCHAR2(64 BYTE),
  s_premises_name VARCHAR2(64 BYTE),
  server_id NUMBER
);
ALTER TABLE sa.table_x79location ADD SUPPLEMENTAL LOG GROUP dmtsora948138760_0 (dev, objid, premises_name, server_id, s_premises_name) ALWAYS;