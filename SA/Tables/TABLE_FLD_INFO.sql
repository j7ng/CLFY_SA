CREATE TABLE sa.table_fld_info (
  objid NUMBER,
  obj_name VARCHAR2(80 BYTE),
  obj_type VARCHAR2(80 BYTE),
  fld_name VARCHAR2(80 BYTE),
  gen_fld_name VARCHAR2(80 BYTE),
  dtype_name VARCHAR2(80 BYTE),
  fld_id NUMBER,
  dtype NUMBER,
  fld_width VARCHAR2(80 BYTE),
  fld_desc VARCHAR2(255 BYTE),
  gen_fld_id NUMBER,
  dev NUMBER
);
ALTER TABLE sa.table_fld_info ADD SUPPLEMENTAL LOG GROUP dmtsora184938042_0 (dev, dtype, dtype_name, fld_desc, fld_id, fld_name, fld_width, gen_fld_id, gen_fld_name, objid, obj_name, obj_type) ALWAYS;