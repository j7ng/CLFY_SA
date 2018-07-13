CREATE TABLE sa.table_x79mo_inst (
  objid NUMBER,
  dev NUMBER,
  instance_id VARCHAR2(64 BYTE),
  s_instance_id VARCHAR2(64 BYTE),
  failure_prob NUMBER,
  server_id NUMBER,
  inst2x79trfmt_defn NUMBER
);
ALTER TABLE sa.table_x79mo_inst ADD SUPPLEMENTAL LOG GROUP dmtsora1570855391_0 (dev, failure_prob, inst2x79trfmt_defn, instance_id, objid, server_id, s_instance_id) ALWAYS;