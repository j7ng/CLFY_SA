CREATE TABLE sa.table_ripbin (
  objid NUMBER,
  title VARCHAR2(24 BYTE),
  dev NUMBER
);
ALTER TABLE sa.table_ripbin ADD SUPPLEMENTAL LOG GROUP dmtsora1873326400_0 (dev, objid, title) ALWAYS;
COMMENT ON TABLE sa.table_ripbin IS 'Bin where closed cases, subcases and change requests are stored; icon no longer visible on the desktop; use of query now allows access to closed items. Reserved; obsolete';
COMMENT ON COLUMN sa.table_ripbin.objid IS 'Internal record number. Reserved; obsolete';
COMMENT ON COLUMN sa.table_ripbin.title IS 'Title/name of bin. Reserved; obsolete';
COMMENT ON COLUMN sa.table_ripbin.dev IS 'Row version number for mobile distribution purposes';