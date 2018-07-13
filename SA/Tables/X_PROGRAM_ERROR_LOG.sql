CREATE TABLE sa.x_program_error_log (
  x_source VARCHAR2(80 BYTE),
  x_error_code VARCHAR2(20 BYTE),
  x_error_msg VARCHAR2(255 BYTE),
  x_date DATE,
  x_description VARCHAR2(255 BYTE),
  x_severity NUMBER(1),
  x_key VARCHAR2(30 BYTE),
  x_key_desc VARCHAR2(100 BYTE)
);
ALTER TABLE sa.x_program_error_log ADD SUPPLEMENTAL LOG GROUP dmtsora1764689452_0 (x_date, x_description, x_error_code, x_error_msg, x_severity, x_source) ALWAYS;
COMMENT ON TABLE sa.x_program_error_log IS 'Error Log for Billing Platform Application, any problem in the application is log in this table.';
COMMENT ON COLUMN sa.x_program_error_log.x_source IS 'Program that is originating the entry';
COMMENT ON COLUMN sa.x_program_error_log.x_error_code IS 'Error Code generated';
COMMENT ON COLUMN sa.x_program_error_log.x_error_msg IS 'Error Message';
COMMENT ON COLUMN sa.x_program_error_log.x_date IS 'Date the entry was produced.';
COMMENT ON COLUMN sa.x_program_error_log.x_description IS 'Description of the problem';
COMMENT ON COLUMN sa.x_program_error_log.x_severity IS 'Severity Level of the Error.';