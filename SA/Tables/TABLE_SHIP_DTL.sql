CREATE TABLE sa.table_ship_dtl (
  objid NUMBER,
  serial_no VARCHAR2(40 BYTE),
  part_number VARCHAR2(30 BYTE),
  s_part_number VARCHAR2(30 BYTE),
  mod_level VARCHAR2(10 BYTE),
  s_mod_level VARCHAR2(10 BYTE),
  description VARCHAR2(255 BYTE),
  s_description VARCHAR2(255 BYTE),
  dev NUMBER,
  ship_dtl2demand_dtl NUMBER(*,0),
  ship_dtl2ship_parts NUMBER(*,0)
);
ALTER TABLE sa.table_ship_dtl ADD SUPPLEMENTAL LOG GROUP dmtsora393646184_0 (description, dev, mod_level, objid, part_number, serial_no, ship_dtl2demand_dtl, ship_dtl2ship_parts, s_description, s_mod_level, s_part_number) ALWAYS;