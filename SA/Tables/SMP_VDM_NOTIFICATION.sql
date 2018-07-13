CREATE TABLE sa.smp_vdm_notification (
  sequence_num NUMBER(*,0),
  notification_id NUMBER(*,0),
  notification_type NUMBER(*,0),
  subtype NUMBER(*,0),
  node_name VARCHAR2(256 BYTE),
  service_name VARCHAR2(256 BYTE),
  service_type VARCHAR2(256 BYTE),
  time_stamp NUMBER(*,0),
  "TIME_ZONE" NUMBER(*,0),
  verbose NUMBER(*,0),
  domain VARCHAR2(256 BYTE),
  num_clients NUMBER(*,0)
);
ALTER TABLE sa.smp_vdm_notification ADD SUPPLEMENTAL LOG GROUP dmtsora1965875422_0 (domain, node_name, notification_id, notification_type, num_clients, sequence_num, service_name, service_type, subtype, time_stamp, "TIME_ZONE", verbose) ALWAYS;