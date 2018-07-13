CREATE TABLE sa.table_e_addr (
  objid NUMBER,
  e_num VARCHAR2(255 BYTE),
  s_e_num VARCHAR2(255 BYTE),
  access_num VARCHAR2(20 BYTE),
  "TYPE" VARCHAR2(20 BYTE),
  s_type VARCHAR2(20 BYTE),
  subtype VARCHAR2(20 BYTE),
  s_subtype VARCHAR2(20 BYTE),
  useage VARCHAR2(30 BYTE),
  dev NUMBER,
  e_type NUMBER,
  e_subtype NUMBER,
  modify_stmp DATE,
  eaddr2bus_org NUMBER,
  eaddr2site NUMBER,
  eaddr2site_part NUMBER,
  eaddr2contact NUMBER,
  eaddr2employee NUMBER
);
ALTER TABLE sa.table_e_addr ADD SUPPLEMENTAL LOG GROUP dmtsora1229643188_0 (access_num, dev, eaddr2bus_org, eaddr2contact, eaddr2employee, eaddr2site, eaddr2site_part, e_num, e_subtype, e_type, modify_stmp, objid, subtype, s_e_num, s_subtype, s_type, "TYPE", useage) ALWAYS;