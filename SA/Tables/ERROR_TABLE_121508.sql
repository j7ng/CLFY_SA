CREATE TABLE sa.error_table_121508 (
  error_text VARCHAR2(4000 BYTE),
  error_date DATE,
  "ACTION" VARCHAR2(4000 BYTE),
  "KEY" VARCHAR2(50 BYTE),
  program_name VARCHAR2(1000 BYTE)
);
ALTER TABLE sa.error_table_121508 ADD SUPPLEMENTAL LOG GROUP dmtsora448408280_0 ("ACTION", error_date, error_text, "KEY", program_name) ALWAYS;