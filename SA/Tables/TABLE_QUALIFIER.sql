CREATE TABLE sa.table_qualifier (
  objid NUMBER,
  dev NUMBER,
  qualifier_id NUMBER,
  "NAME" VARCHAR2(255 BYTE),
  s_name VARCHAR2(255 BYTE),
  description VARCHAR2(255 BYTE)
);
ALTER TABLE sa.table_qualifier ADD SUPPLEMENTAL LOG GROUP dmtsora516271777_0 (description, dev, "NAME", objid, qualifier_id, s_name) ALWAYS;