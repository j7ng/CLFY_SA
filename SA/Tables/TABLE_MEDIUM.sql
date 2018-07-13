CREATE TABLE sa.table_medium (
  objid NUMBER,
  dev NUMBER,
  title VARCHAR2(80 BYTE),
  s_title VARCHAR2(80 BYTE),
  description VARCHAR2(255 BYTE),
  s_description VARCHAR2(255 BYTE),
  "TYPE" NUMBER,
  locale NUMBER
);
ALTER TABLE sa.table_medium ADD SUPPLEMENTAL LOG GROUP dmtsora243598390_0 (description, dev, locale, objid, s_description, s_title, title, "TYPE") ALWAYS;