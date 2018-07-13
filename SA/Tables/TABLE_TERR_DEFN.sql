CREATE TABLE sa.table_terr_defn (
  objid NUMBER,
  "EXCLUDE" NUMBER,
  city VARCHAR2(30 BYTE),
  "STATE" VARCHAR2(30 BYTE),
  zipcode VARCHAR2(20 BYTE),
  country VARCHAR2(40 BYTE),
  industry_type VARCHAR2(30 BYTE),
  comments VARCHAR2(255 BYTE),
  description VARCHAR2(255 BYTE),
  product_fam VARCHAR2(50 BYTE),
  dev NUMBER,
  terr_defn2territory NUMBER(*,0)
);
ALTER TABLE sa.table_terr_defn ADD SUPPLEMENTAL LOG GROUP dmtsora1957442047_0 (city, comments, country, description, dev, "EXCLUDE", industry_type, objid, product_fam, "STATE", terr_defn2territory, zipcode) ALWAYS;