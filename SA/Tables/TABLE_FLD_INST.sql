CREATE TABLE sa.table_fld_inst (
  objid NUMBER,
  dev NUMBER,
  fld_name VARCHAR2(128 BYTE),
  "VALUE" VARCHAR2(255 BYTE),
  is_pending NUMBER,
  flex_owner_objid NUMBER,
  fld2svc_fld NUMBER,
  fld2rqst_inst NUMBER
);
ALTER TABLE sa.table_fld_inst ADD SUPPLEMENTAL LOG GROUP dmtsora1919600911_0 (dev, fld2rqst_inst, fld2svc_fld, fld_name, flex_owner_objid, is_pending, objid, "VALUE") ALWAYS;