CREATE TABLE sa.smp_vdm_notification_services (
  service_type VARCHAR2(255 BYTE),
  nodename VARCHAR2(255 BYTE),
  ior VARCHAR2(2000 BYTE),
  time_stamp DATE
);
ALTER TABLE sa.smp_vdm_notification_services ADD SUPPLEMENTAL LOG GROUP dmtsora892735601_0 (ior, nodename, service_type, time_stamp) ALWAYS;