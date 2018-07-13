CREATE TABLE sa.table_web_object (
  objid NUMBER,
  "NAME" VARCHAR2(255 BYTE),
  s_name VARCHAR2(255 BYTE),
  dev NUMBER,
  description VARCHAR2(255 BYTE)
);
ALTER TABLE sa.table_web_object ADD SUPPLEMENTAL LOG GROUP dmtsora419617199_0 (description, dev, "NAME", objid, s_name) ALWAYS;