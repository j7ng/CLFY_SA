CREATE TABLE sa.table_sce_object (
  objid NUMBER,
  subject VARCHAR2(30 BYTE),
  object_num NUMBER,
  object_name VARCHAR2(30 BYTE),
  description VARCHAR2(255 BYTE),
  data_type VARCHAR2(20 BYTE),
  field_length NUMBER,
  rel_type VARCHAR2(40 BYTE),
  to_object VARCHAR2(30 BYTE),
  gen_fld_id NUMBER,
  from_rel VARCHAR2(40 BYTE),
  to_rel VARCHAR2(40 BYTE),
  field_name VARCHAR2(64 BYTE),
  from_field VARCHAR2(20 BYTE),
  alias_name VARCHAR2(20 BYTE),
  status VARCHAR2(20 BYTE),
  view_object VARCHAR2(255 BYTE),
  object_flag NUMBER,
  spec_fld_id NUMBER,
  dev NUMBER
);
ALTER TABLE sa.table_sce_object ADD SUPPLEMENTAL LOG GROUP dmtsora691942262_0 (alias_name, data_type, description, dev, field_length, field_name, from_field, from_rel, gen_fld_id, object_flag, object_name, object_num, objid, rel_type, spec_fld_id, status, subject, to_object, to_rel, view_object) ALWAYS;