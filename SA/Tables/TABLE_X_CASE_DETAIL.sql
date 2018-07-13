CREATE TABLE sa.table_x_case_detail (
  objid NUMBER,
  dev NUMBER,
  x_name VARCHAR2(50 BYTE),
  x_value VARCHAR2(500 BYTE),
  detail2case NUMBER
);
ALTER TABLE sa.table_x_case_detail ADD SUPPLEMENTAL LOG GROUP dmtsora49959747_0 (detail2case, dev, objid, x_name, x_value) ALWAYS;
COMMENT ON TABLE sa.table_x_case_detail IS 'Detail name value pait support for case';
COMMENT ON COLUMN sa.table_x_case_detail.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_x_case_detail.dev IS 'Row version number for mobile distribution purposes';
COMMENT ON COLUMN sa.table_x_case_detail.x_name IS 'field name';
COMMENT ON COLUMN sa.table_x_case_detail.x_value IS 'field value';
COMMENT ON COLUMN sa.table_x_case_detail.detail2case IS 'TBD';