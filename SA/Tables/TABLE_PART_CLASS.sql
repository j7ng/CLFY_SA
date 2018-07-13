CREATE TABLE sa.table_part_class (
  objid NUMBER,
  "NAME" VARCHAR2(40 BYTE),
  description VARCHAR2(255 BYTE),
  dev NUMBER,
  x_model_number VARCHAR2(30 BYTE),
  x_psms_inquiry VARCHAR2(150 BYTE)
);
ALTER TABLE sa.table_part_class ADD SUPPLEMENTAL LOG GROUP dmtsora577323333_0 (description, dev, "NAME", objid, x_model_number, x_psms_inquiry) ALWAYS;
COMMENT ON TABLE sa.table_part_class IS 'Defines logical groups of parts (generic parts) for DE purposes';
COMMENT ON COLUMN sa.table_part_class.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_part_class."NAME" IS 'A unique name for the part class';
COMMENT ON COLUMN sa.table_part_class.description IS 'A brief description for the part class';
COMMENT ON COLUMN sa.table_part_class.dev IS 'Row version number for mobile distribution purposes';
COMMENT ON COLUMN sa.table_part_class.x_model_number IS 'TBD';
COMMENT ON COLUMN sa.table_part_class.x_psms_inquiry IS 'PSMS Inquiry String';