CREATE TABLE sa.table_x_not_certify_models (
  objid NUMBER,
  dev NUMBER,
  x_parent_id VARCHAR2(30 BYTE),
  x_part_class_objid NUMBER
);
ALTER TABLE sa.table_x_not_certify_models ADD SUPPLEMENTAL LOG GROUP dmtsora491826881_0 (dev, objid, x_parent_id, x_part_class_objid) ALWAYS;
COMMENT ON TABLE sa.table_x_not_certify_models IS 'Part Class Carrier ID combinations the represent models not approved to use with a given carrier';
COMMENT ON COLUMN sa.table_x_not_certify_models.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_x_not_certify_models.dev IS 'Row version number for mobile distribution purposes';
COMMENT ON COLUMN sa.table_x_not_certify_models.x_parent_id IS 'TBD';
COMMENT ON COLUMN sa.table_x_not_certify_models.x_part_class_objid IS 'TBD';