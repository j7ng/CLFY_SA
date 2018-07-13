CREATE TABLE sa.temp_for_trigger (
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
  table_name VARCHAR2(30 BYTE)
);
ALTER TABLE sa.temp_for_trigger ADD SUPPLEMENTAL LOG GROUP dmtsora76274960_0 ("ACTION", dt, logon_time, machine, osuser, "PROCESS", "PROGRAM", "SID", sql_text, table_name, terminal, username) ALWAYS;