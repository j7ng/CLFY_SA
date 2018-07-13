CREATE TABLE sa.table_x_ota_features_psms (
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
  objid NUMBER,
  x_ota_features2part_inst NUMBER,
  old_x_psms_destination_addr VARCHAR2(30 BYTE),
  new_x_psms_destination_addr VARCHAR2(30 BYTE)
);