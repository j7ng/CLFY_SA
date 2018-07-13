CREATE TABLE sa.table_catalog (
  objid NUMBER,
  "NAME" VARCHAR2(30 BYTE),
  description VARCHAR2(255 BYTE),
  s_description VARCHAR2(255 BYTE),
  last_mod_time DATE,
  "ACTIVE" NUMBER,
  dev NUMBER
);
ALTER TABLE sa.table_catalog ADD SUPPLEMENTAL LOG GROUP dmtsora132996012_0 ("ACTIVE", description, dev, last_mod_time, "NAME", objid, s_description) ALWAYS;