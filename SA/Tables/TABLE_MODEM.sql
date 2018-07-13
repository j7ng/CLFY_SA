CREATE TABLE sa.table_modem (
  objid NUMBER,
  device_name VARCHAR2(20 BYTE),
  device_type VARCHAR2(20 BYTE),
  "ACTIVE" VARCHAR2(20 BYTE),
  hostname VARCHAR2(20 BYTE),
  dev NUMBER
);
ALTER TABLE sa.table_modem ADD SUPPLEMENTAL LOG GROUP dmtsora1029634795_0 ("ACTIVE", dev, device_name, device_type, hostname, objid) ALWAYS;