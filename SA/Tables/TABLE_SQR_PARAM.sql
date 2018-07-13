CREATE TABLE sa.table_sqr_param (
  objid NUMBER,
  title VARCHAR2(80 BYTE),
  params LONG,
  dev NUMBER
);
ALTER TABLE sa.table_sqr_param ADD SUPPLEMENTAL LOG GROUP dmtsora1979800291_0 (dev, objid, title) ALWAYS;
COMMENT ON TABLE sa.table_sqr_param IS 'EIS object which defines the SQR parameters for each specific report';
COMMENT ON COLUMN sa.table_sqr_param.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_sqr_param.title IS 'Title of SQR parameter set';
COMMENT ON COLUMN sa.table_sqr_param.params IS 'Parameters in the set';
COMMENT ON COLUMN sa.table_sqr_param.dev IS 'Row version number for mobile distribution purposes';