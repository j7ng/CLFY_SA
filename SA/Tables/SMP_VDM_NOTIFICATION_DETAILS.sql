CREATE TABLE sa.smp_vdm_notification_details (
  "NAME" VARCHAR2(256 BYTE),
  "TYPE" NUMBER(*,0),
  target VARCHAR2(256 BYTE),
  execnum NUMBER(*,0),
  "OWNER" VARCHAR2(256 BYTE),
  time_stamp DATE,
  "TIME_ZONE" NUMBER(*,0),
  "METHOD" VARCHAR2(256 BYTE),
  status NUMBER(*,0),
  message VARCHAR2(2000 BYTE),
  operation_status NUMBER
);
ALTER TABLE sa.smp_vdm_notification_details ADD SUPPLEMENTAL LOG GROUP dmtsora627375404_0 (execnum, message, "METHOD", "NAME", operation_status, "OWNER", status, target, time_stamp, "TIME_ZONE", "TYPE") ALWAYS;