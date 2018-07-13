CREATE TABLE sa.table_x79address (
  objid NUMBER,
  dev NUMBER,
  civic_address VARCHAR2(64 BYTE),
  s_civic_address VARCHAR2(64 BYTE),
  city VARCHAR2(64 BYTE),
  s_city VARCHAR2(64 BYTE),
  "STATE" VARCHAR2(64 BYTE),
  zip VARCHAR2(64 BYTE),
  s_zip VARCHAR2(64 BYTE),
  server_id NUMBER,
  address2x79country NUMBER,
  address2x79state_prov NUMBER,
  address2x79tzone NUMBER,
  addr2x79location NUMBER,
  addr2x79person NUMBER
);
ALTER TABLE sa.table_x79address ADD SUPPLEMENTAL LOG GROUP dmtsora1227472513_0 (addr2x79location, addr2x79person, address2x79country, address2x79state_prov, address2x79tzone, city, civic_address, dev, objid, server_id, "STATE", s_city, s_civic_address, s_zip, zip) ALWAYS;