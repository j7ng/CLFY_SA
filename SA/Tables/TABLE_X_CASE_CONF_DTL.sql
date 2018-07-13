CREATE TABLE sa.table_x_case_conf_dtl (
  objid NUMBER,
  dev NUMBER,
  x_field_name VARCHAR2(30 BYTE),
  x_prompt VARCHAR2(30 BYTE),
  x_format VARCHAR2(30 BYTE),
  x_min_value NUMBER,
  x_max_value NUMBER,
  x_help_text VARCHAR2(255 BYTE),
  x_data_type VARCHAR2(10 BYTE),
  x_ddl_title VARCHAR2(80 BYTE)
);
ALTER TABLE sa.table_x_case_conf_dtl ADD SUPPLEMENTAL LOG GROUP dmtsora1466917997_0 (dev, objid, x_data_type, x_ddl_title, x_field_name, x_format, x_help_text, x_max_value, x_min_value, x_prompt) ALWAYS;
COMMENT ON TABLE sa.table_x_case_conf_dtl IS 'Value Pair configuration for cases';
COMMENT ON COLUMN sa.table_x_case_conf_dtl.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_x_case_conf_dtl.dev IS 'Row version number for mobile distribution purposes';
COMMENT ON COLUMN sa.table_x_case_conf_dtl.x_field_name IS 'Case Detail Field';
COMMENT ON COLUMN sa.table_x_case_conf_dtl.x_prompt IS 'WEBCSR prompt for the field';
COMMENT ON COLUMN sa.table_x_case_conf_dtl.x_format IS 'field entry format';
COMMENT ON COLUMN sa.table_x_case_conf_dtl.x_min_value IS 'Minimum Value';
COMMENT ON COLUMN sa.table_x_case_conf_dtl.x_max_value IS 'Maximum Value';
COMMENT ON COLUMN sa.table_x_case_conf_dtl.x_help_text IS 'Help Text';
COMMENT ON COLUMN sa.table_x_case_conf_dtl.x_data_type IS 'NUMBER,TEXT,DATE';
COMMENT ON COLUMN sa.table_x_case_conf_dtl.x_ddl_title IS 'Drop Down List Title reference to table_gbst_elm.title';