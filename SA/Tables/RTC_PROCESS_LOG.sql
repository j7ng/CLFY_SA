CREATE TABLE sa.rtc_process_log (
  process_text VARCHAR2(400 BYTE),
  process_date TIMESTAMP,
  "ACTION" VARCHAR2(400 BYTE),
  process_key VARCHAR2(100 BYTE),
  program_name VARCHAR2(100 BYTE)
);
COMMENT ON COLUMN sa.rtc_process_log.process_text IS 'Process Messages';
COMMENT ON COLUMN sa.rtc_process_log.process_date IS 'Date when the transcation is processed';
COMMENT ON COLUMN sa.rtc_process_log."ACTION" IS 'Process Action';
COMMENT ON COLUMN sa.rtc_process_log.process_key IS 'Key to identify the Case records';
COMMENT ON COLUMN sa.rtc_process_log.program_name IS 'Name of the procedure';