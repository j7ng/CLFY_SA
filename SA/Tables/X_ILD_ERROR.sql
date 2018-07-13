CREATE TABLE sa.x_ild_error (
  error_text VARCHAR2(4000 BYTE),
  error_date DATE,
  "ACTION" VARCHAR2(4000 BYTE),
  serial_no VARCHAR2(50 BYTE),
  program_name VARCHAR2(1000 BYTE)
);
ALTER TABLE sa.x_ild_error ADD SUPPLEMENTAL LOG GROUP dmtsora527739809_0 ("ACTION", error_date, error_text, program_name, serial_no) ALWAYS;