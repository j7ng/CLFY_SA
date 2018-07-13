CREATE TABLE sa.x_migr_extra_info (
  x_migra2x_case NUMBER(22),
  x_flag_migration VARCHAR2(5 BYTE),
  x_date_process DATE,
  x_problem VARCHAR2(1000 BYTE),
  x_date_email_sent DATE
);
ALTER TABLE sa.x_migr_extra_info ADD SUPPLEMENTAL LOG GROUP dmtsora1489128924_0 (x_date_email_sent, x_date_process, x_flag_migration, x_migra2x_case, x_problem) ALWAYS;