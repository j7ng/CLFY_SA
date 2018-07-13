CREATE TABLE sa.table_page_class (
  objid NUMBER,
  dev NUMBER,
  "NAME" VARCHAR2(80 BYTE),
  s_name VARCHAR2(80 BYTE),
  description VARCHAR2(255 BYTE),
  s_description VARCHAR2(255 BYTE)
);
ALTER TABLE sa.table_page_class ADD SUPPLEMENTAL LOG GROUP dmtsora475539992_0 (description, dev, "NAME", objid, s_description, s_name) ALWAYS;
COMMENT ON TABLE sa.table_page_class IS 'Stores the resource config names and descriptions';
COMMENT ON COLUMN sa.table_page_class.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_page_class.dev IS 'Row version number for mobile distribution purposes';
COMMENT ON COLUMN sa.table_page_class."NAME" IS 'Name that is added to files that are part of this resource config';
COMMENT ON COLUMN sa.table_page_class.description IS 'Description of the resource configuration';