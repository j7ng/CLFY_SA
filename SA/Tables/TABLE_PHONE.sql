CREATE TABLE sa.table_phone (
  objid NUMBER,
  phone VARCHAR2(20 BYTE),
  purpose VARCHAR2(255 BYTE),
  "TYPE" NUMBER,
  login VARCHAR2(30 BYTE),
  "PASSWORD" VARCHAR2(30 BYTE),
  "NAME" VARCHAR2(20 BYTE),
  speed VARCHAR2(6 BYTE),
  "PARITY" VARCHAR2(6 BYTE),
  phone_type VARCHAR2(12 BYTE),
  "ATTRIBUTE" VARCHAR2(20 BYTE),
  dev NUMBER,
  phone2site NUMBER(*,0),
  phone2site_part NUMBER(*,0)
);
ALTER TABLE sa.table_phone ADD SUPPLEMENTAL LOG GROUP dmtsora1153385773_0 ("ATTRIBUTE", dev, login, "NAME", objid, "PARITY", "PASSWORD", phone, phone2site, phone2site_part, phone_type, purpose, speed, "TYPE") ALWAYS;