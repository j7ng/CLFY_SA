CREATE TABLE sa.error_code (
  error_code NUMBER(10),
  error_description VARCHAR2(2000 BYTE),
  remarks VARCHAR2(2000 BYTE),
  error_type VARCHAR2(1 BYTE),
  program_name VARCHAR2(60 BYTE),
  program_type VARCHAR2(10 BYTE),
  error_id VARCHAR2(10 BYTE)
);
ALTER TABLE sa.error_code ADD SUPPLEMENTAL LOG GROUP dmtsora1261335053_0 (error_code, error_description, error_id, error_type, program_name, program_type, remarks) ALWAYS;