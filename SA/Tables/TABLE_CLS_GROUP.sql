CREATE TABLE sa.table_cls_group (
  objid NUMBER,
  "NAME" VARCHAR2(80 BYTE),
  dev NUMBER
);
ALTER TABLE sa.table_cls_group ADD SUPPLEMENTAL LOG GROUP dmtsora455913954_0 (dev, "NAME", objid) ALWAYS;
COMMENT ON TABLE sa.table_cls_group IS 'Groups templates for administrative purposes';
COMMENT ON COLUMN sa.table_cls_group.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_cls_group."NAME" IS 'Name of the template group';
COMMENT ON COLUMN sa.table_cls_group.dev IS 'Row version number for mobile distribution purposes';