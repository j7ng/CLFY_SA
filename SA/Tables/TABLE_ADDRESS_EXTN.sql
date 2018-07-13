CREATE TABLE sa.table_address_extn (
  objid NUMBER,
  dev NUMBER,
  "TYPE" NUMBER,
  first_name VARCHAR2(30 BYTE),
  last_name VARCHAR2(30 BYTE),
  nickname VARCHAR2(30 BYTE),
  "ACTIVE" NUMBER,
  address_extn2preference NUMBER,
  address_extn2address NUMBER
);
ALTER TABLE sa.table_address_extn ADD SUPPLEMENTAL LOG GROUP dmtsora1098530359_0 ("ACTIVE", address_extn2address, address_extn2preference, dev, first_name, last_name, nickname, objid, "TYPE") ALWAYS;