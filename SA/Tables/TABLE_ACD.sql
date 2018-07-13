CREATE TABLE sa.table_acd (
  objid NUMBER,
  dev NUMBER,
  server_name VARCHAR2(30 BYTE),
  server_port NUMBER,
  "TYPE" VARCHAR2(30 BYTE),
  model_num VARCHAR2(20 BYTE),
  revision VARCHAR2(30 BYTE),
  arch_ind NUMBER,
  server_combo NUMBER
);
ALTER TABLE sa.table_acd ADD SUPPLEMENTAL LOG GROUP dmtsora1128354780_0 (arch_ind, dev, model_num, objid, revision, server_combo, server_name, server_port, "TYPE") ALWAYS;