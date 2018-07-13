CREATE TABLE sa.table_x_psms_template (
  objid NUMBER,
  dev NUMBER,
  x_ild_type NUMBER,
  x_seq NUMBER,
  x_command VARCHAR2(10 BYTE),
  x_param_c VARCHAR2(30 BYTE),
  x_param_d1 VARCHAR2(30 BYTE),
  x_param_d2 VARCHAR2(30 BYTE),
  x_param_d3 VARCHAR2(30 BYTE),
  x_param_d7 VARCHAR2(30 BYTE),
  x_param_d8 VARCHAR2(30 BYTE),
  x_param_s1 VARCHAR2(50 BYTE),
  x_ild_prog_status VARCHAR2(10 BYTE),
  x_message_txt VARCHAR2(190 BYTE)
);
ALTER TABLE sa.table_x_psms_template ADD SUPPLEMENTAL LOG GROUP dmtsora1674686117_0 (dev, objid, x_command, x_ild_prog_status, x_ild_type, x_message_txt, x_param_c, x_param_d1, x_param_d2, x_param_d3, x_param_d7, x_param_d8, x_param_s1, x_seq) ALWAYS;
COMMENT ON TABLE sa.table_x_psms_template IS 'Template for psms message';
COMMENT ON COLUMN sa.table_x_psms_template.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_x_psms_template.dev IS 'Row version number for mobile distribution purposes';
COMMENT ON COLUMN sa.table_x_psms_template.x_ild_type IS 'ILD Type, 1 and 2';
COMMENT ON COLUMN sa.table_x_psms_template.x_seq IS 'Sequence';
COMMENT ON COLUMN sa.table_x_psms_template.x_command IS 'Command Type ILD01,ILD02,etc';
COMMENT ON COLUMN sa.table_x_psms_template.x_param_c IS 'TBD';
COMMENT ON COLUMN sa.table_x_psms_template.x_param_d1 IS 'TBD';
COMMENT ON COLUMN sa.table_x_psms_template.x_param_d2 IS 'TBD';
COMMENT ON COLUMN sa.table_x_psms_template.x_param_d3 IS 'TBD';
COMMENT ON COLUMN sa.table_x_psms_template.x_param_d7 IS 'TBD';
COMMENT ON COLUMN sa.table_x_psms_template.x_param_d8 IS 'TBD';
COMMENT ON COLUMN sa.table_x_psms_template.x_param_s1 IS 'TBD';
COMMENT ON COLUMN sa.table_x_psms_template.x_ild_prog_status IS 'TBD';
COMMENT ON COLUMN sa.table_x_psms_template.x_message_txt IS 'TBD';