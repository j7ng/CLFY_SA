CREATE TABLE sa.table_value_map (
  objid NUMBER,
  parent_object NUMBER,
  parent_context VARCHAR2(30 BYTE),
  parent_fld_name VARCHAR2(80 BYTE),
  parent_fld_type NUMBER,
  parent_fld_val VARCHAR2(255 BYTE),
  child_object NUMBER,
  child_context VARCHAR2(30 BYTE),
  child_fld_name VARCHAR2(80 BYTE),
  child_fld_type NUMBER,
  child_fld_val VARCHAR2(255 BYTE),
  dev NUMBER
);
ALTER TABLE sa.table_value_map ADD SUPPLEMENTAL LOG GROUP dmtsora1786140020_0 (child_context, child_fld_name, child_fld_type, child_fld_val, child_object, dev, objid, parent_context, parent_fld_name, parent_fld_type, parent_fld_val, parent_object) ALWAYS;