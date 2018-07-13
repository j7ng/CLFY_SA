CREATE TABLE sa.table_fld_def (
  objid NUMBER,
  dev NUMBER,
  fld_name VARCHAR2(128 BYTE),
  attrib_type VARCHAR2(20 BYTE),
  description VARCHAR2(255 BYTE),
  fld_def2tbl_def NUMBER
);
ALTER TABLE sa.table_fld_def ADD SUPPLEMENTAL LOG GROUP dmtsora1406686393_0 (attrib_type, description, dev, fld_def2tbl_def, fld_name, objid) ALWAYS;
COMMENT ON TABLE sa.table_fld_def IS 'Defines FML fields used by Process Manager. Each field is unique';
COMMENT ON COLUMN sa.table_fld_def.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_fld_def.dev IS 'Row version number for mobile distribution purposes';
COMMENT ON COLUMN sa.table_fld_def.fld_name IS 'The Tuxedo FML field name';
COMMENT ON COLUMN sa.table_fld_def.attrib_type IS 'Attribute type, one of  String, Number, Date';
COMMENT ON COLUMN sa.table_fld_def.description IS 'Brief description of what the field is for';
COMMENT ON COLUMN sa.table_fld_def.fld_def2tbl_def IS 'The tbl file that defines this field';