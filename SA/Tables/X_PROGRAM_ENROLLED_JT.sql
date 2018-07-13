CREATE TABLE sa.x_program_enrolled_jt (
  "SID" NUMBER,
  "ACTION" VARCHAR2(10 BYTE),
  username VARCHAR2(30 BYTE),
  osuser VARCHAR2(100 BYTE),
  "PROCESS" VARCHAR2(100 BYTE),
  machine VARCHAR2(100 BYTE),
  terminal VARCHAR2(100 BYTE),
  "PROGRAM" VARCHAR2(100 BYTE),
  logon_time DATE,
  dt DATE,
  sql_text VARCHAR2(1000 BYTE),
  x_esn VARCHAR2(30 BYTE),
  old_status VARCHAR2(30 BYTE),
  new_status VARCHAR2(30 BYTE),
  piece NUMBER
);