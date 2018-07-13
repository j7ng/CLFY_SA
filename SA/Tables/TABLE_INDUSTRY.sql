CREATE TABLE sa.table_industry (
  objid NUMBER,
  "NAME" VARCHAR2(80 BYTE),
  s_name VARCHAR2(80 BYTE),
  sic_code VARCHAR2(25 BYTE),
  ind_type VARCHAR2(25 BYTE),
  description VARCHAR2(255 BYTE),
  dev NUMBER
);
ALTER TABLE sa.table_industry ADD SUPPLEMENTAL LOG GROUP dmtsora458883019_0 (description, dev, ind_type, "NAME", objid, sic_code, s_name) ALWAYS;