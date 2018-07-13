CREATE TABLE sa.table_prop_name (
  objid NUMBER,
  obj_type NUMBER,
  prop_name VARCHAR2(80 BYTE),
  path_name VARCHAR2(255 BYTE),
  val_type NUMBER,
  max_len NUMBER,
  extra_info VARCHAR2(255 BYTE),
  subtype NUMBER,
  locale NUMBER,
  dev NUMBER
);
ALTER TABLE sa.table_prop_name ADD SUPPLEMENTAL LOG GROUP dmtsora1048561691_0 (dev, extra_info, locale, max_len, objid, obj_type, path_name, prop_name, subtype, val_type) ALWAYS;