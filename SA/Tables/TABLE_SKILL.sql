CREATE TABLE sa.table_skill (
  objid NUMBER,
  dev NUMBER,
  "NAME" VARCHAR2(80 BYTE),
  s_name VARCHAR2(80 BYTE)
);
ALTER TABLE sa.table_skill ADD SUPPLEMENTAL LOG GROUP dmtsora1755419228_0 (dev, "NAME", objid, s_name) ALWAYS;