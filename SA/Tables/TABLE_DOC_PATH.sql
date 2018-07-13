CREATE TABLE sa.table_doc_path (
  objid NUMBER,
  "PATH" VARCHAR2(255 BYTE),
  dev NUMBER,
  mime_type VARCHAR2(64 BYTE)
);
ALTER TABLE sa.table_doc_path ADD SUPPLEMENTAL LOG GROUP dmtsora1756359250_0 (dev, mime_type, objid, "PATH") ALWAYS;
COMMENT ON TABLE sa.table_doc_path IS 'Defines the filename and path where an attachment is located on disk';
COMMENT ON COLUMN sa.table_doc_path.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_doc_path."PATH" IS 'Path and file name of the attachment';
COMMENT ON COLUMN sa.table_doc_path.dev IS 'Row version number for mobile distribution purposes';
COMMENT ON COLUMN sa.table_doc_path.mime_type IS 'MIME type of the attachment file';