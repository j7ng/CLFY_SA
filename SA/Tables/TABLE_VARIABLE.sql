CREATE TABLE sa.table_variable (
  objid NUMBER,
  "NAME" VARCHAR2(80 BYTE),
  value_type NUMBER,
  "VALUE" VARCHAR2(255 BYTE),
  dev NUMBER
);
ALTER TABLE sa.table_variable ADD SUPPLEMENTAL LOG GROUP dmtsora518131219_0 (dev, "NAME", objid, "VALUE", value_type) ALWAYS;