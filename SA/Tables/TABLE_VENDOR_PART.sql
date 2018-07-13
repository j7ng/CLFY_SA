CREATE TABLE sa.table_vendor_part (
  objid NUMBER,
  vendor_part_no VARCHAR2(30 BYTE),
  s_vendor_part_no VARCHAR2(30 BYTE),
  role_name VARCHAR2(80 BYTE),
  lead_time NUMBER,
  avg_lead_time NUMBER,
  avg_cost NUMBER(19,4),
  dev NUMBER,
  vendor_rev VARCHAR2(10 BYTE),
  s_vendor_rev VARCHAR2(10 BYTE),
  warranty NUMBER,
  preference VARCHAR2(20 BYTE),
  part_status VARCHAR2(20 BYTE),
  vendor_part2site NUMBER,
  vendor_part2mod_level NUMBER
);
ALTER TABLE sa.table_vendor_part ADD SUPPLEMENTAL LOG GROUP dmtsora1886214325_0 (avg_cost, avg_lead_time, dev, lead_time, objid, part_status, preference, role_name, s_vendor_part_no, s_vendor_rev, vendor_part2mod_level, vendor_part2site, vendor_part_no, vendor_rev, warranty) ALWAYS;