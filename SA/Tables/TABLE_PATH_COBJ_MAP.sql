CREATE TABLE sa.table_path_cobj_map (
  objid NUMBER,
  source_object NUMBER,
  "PATH" VARCHAR2(255 BYTE),
  dialog_id NUMBER,
  cobj_name VARCHAR2(255 BYTE),
  cobj_type NUMBER,
  cobj_fld_name VARCHAR2(80 BYTE),
  dev NUMBER
);
ALTER TABLE sa.table_path_cobj_map ADD SUPPLEMENTAL LOG GROUP dmtsora1939096377_0 (cobj_fld_name, cobj_name, cobj_type, dev, dialog_id, objid, "PATH", source_object) ALWAYS;