CREATE TABLE sa.adp_upgrade_ops (
  objid NUMBER NOT NULL,
  dev NUMBER NOT NULL,
  "VERSION" NUMBER NOT NULL,
  "OPCODE" NUMBER NOT NULL,
  object_name VARCHAR2(64 BYTE) NOT NULL,
  field_name VARCHAR2(64 BYTE),
  details LONG
);
ALTER TABLE sa.adp_upgrade_ops ADD SUPPLEMENTAL LOG GROUP dmtsora1013688483_0 (dev, field_name, object_name, objid, "OPCODE", "VERSION") ALWAYS;