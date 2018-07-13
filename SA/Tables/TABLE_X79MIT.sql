CREATE TABLE sa.table_x79mit (
  objid NUMBER,
  focus_type NUMBER,
  focus_lowid NUMBER,
  server_id NUMBER,
  "NAME" VARCHAR2(240 BYTE),
  dev NUMBER,
  child2x79mit NUMBER
);
ALTER TABLE sa.table_x79mit ADD SUPPLEMENTAL LOG GROUP dmtsora1314825641_0 (child2x79mit, dev, focus_lowid, focus_type, "NAME", objid, server_id) ALWAYS;