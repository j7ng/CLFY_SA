CREATE TABLE sa.table_rpt (
  objid NUMBER,
  title VARCHAR2(80 BYTE),
  sqr_text LONG,
  sqr_param VARCHAR2(255 BYTE),
  dev NUMBER,
  rpt2sqr_param NUMBER(*,0)
);
ALTER TABLE sa.table_rpt ADD SUPPLEMENTAL LOG GROUP dmtsora459593680_0 (dev, objid, rpt2sqr_param, sqr_param, title) ALWAYS;
COMMENT ON TABLE sa.table_rpt IS 'EIS object which defines an SQR report in the database';
COMMENT ON COLUMN sa.table_rpt.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_rpt.title IS 'Title/name of the report';
COMMENT ON COLUMN sa.table_rpt.sqr_text IS 'SQR code for the report';
COMMENT ON COLUMN sa.table_rpt.sqr_param IS 'SQR parameter types and values for the report; used if length of parameter string is 255 characters or less';
COMMENT ON COLUMN sa.table_rpt.dev IS 'Row version number for mobile distribution purposes';
COMMENT ON COLUMN sa.table_rpt.rpt2sqr_param IS 'SQR parameter types and values for the report; used if length of parameter string is greater than 255 characters';