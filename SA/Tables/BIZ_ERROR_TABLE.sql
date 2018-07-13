CREATE TABLE sa.biz_error_table (
  error_text VARCHAR2(400 BYTE),
  error_date DATE,
  error_num VARCHAR2(400 BYTE),
  error_key VARCHAR2(100 BYTE),
  program_name VARCHAR2(100 BYTE)
);
COMMENT ON TABLE sa.biz_error_table IS 'Table Will Log The Errors Occured During The Fulfillment';
COMMENT ON COLUMN sa.biz_error_table.error_text IS 'Error_Message';
COMMENT ON COLUMN sa.biz_error_table.error_date IS 'Error_Date';
COMMENT ON COLUMN sa.biz_error_table.error_num IS 'Error_Number';
COMMENT ON COLUMN sa.biz_error_table.error_key IS 'To Identify The Error_Key ';
COMMENT ON COLUMN sa.biz_error_table.program_name IS 'Error Occured In Perticular Program';