CREATE TABLE sa.report_enrollment (
  db CHAR(8 BYTE),
  "COUNT" NUMBER,
  channel VARCHAR2(30 BYTE),
  "TYPE" VARCHAR2(30 BYTE),
  x_program_name VARCHAR2(40 BYTE),
  status VARCHAR2(30 BYTE),
  hour_date DATE
);