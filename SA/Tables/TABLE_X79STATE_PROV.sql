CREATE TABLE sa.table_x79state_prov (
  objid NUMBER,
  dev NUMBER,
  "NAME" VARCHAR2(64 BYTE),
  s_name VARCHAR2(64 BYTE),
  full_name VARCHAR2(80 BYTE),
  s_full_name VARCHAR2(80 BYTE),
  code NUMBER,
  is_default NUMBER,
  server_id NUMBER,
  state_prov2x79country NUMBER
);
ALTER TABLE sa.table_x79state_prov ADD SUPPLEMENTAL LOG GROUP dmtsora1676566161_0 (code, dev, full_name, is_default, "NAME", objid, server_id, state_prov2x79country, s_full_name, s_name) ALWAYS;