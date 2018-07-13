CREATE TABLE sa.table_question (
  objid NUMBER,
  seq_num NUMBER,
  appl_id VARCHAR2(20 BYTE),
  "TYPE" VARCHAR2(15 BYTE),
  "TEXT" VARCHAR2(255 BYTE),
  dev NUMBER
);
ALTER TABLE sa.table_question ADD SUPPLEMENTAL LOG GROUP dmtsora1529943522_0 (appl_id, dev, objid, seq_num, "TEXT", "TYPE") ALWAYS;