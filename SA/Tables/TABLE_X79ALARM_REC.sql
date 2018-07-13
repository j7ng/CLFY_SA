CREATE TABLE sa.table_x79alarm_rec (
  objid NUMBER,
  dev NUMBER,
  instance_id VARCHAR2(64 BYTE),
  s_instance_id VARCHAR2(64 BYTE),
  alarm_status VARCHAR2(64 BYTE),
  s_alarm_status VARCHAR2(64 BYTE),
  server_id NUMBER,
  alarm2x79telcom_tr NUMBER
);
ALTER TABLE sa.table_x79alarm_rec ADD SUPPLEMENTAL LOG GROUP dmtsora1049260834_0 (alarm2x79telcom_tr, alarm_status, dev, instance_id, objid, server_id, s_alarm_status, s_instance_id) ALWAYS;