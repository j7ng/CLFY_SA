CREATE TABLE sa.table_sit_prt_role (
  objid NUMBER,
  role_name VARCHAR2(80 BYTE),
  focus_type NUMBER,
  "ACTIVE" NUMBER,
  dev NUMBER,
  prt_role2site NUMBER(*,0),
  prt_role2site_part NUMBER(*,0),
  vendor_part_no VARCHAR2(30 BYTE)
);
ALTER TABLE sa.table_sit_prt_role ADD SUPPLEMENTAL LOG GROUP dmtsora1514834034_0 ("ACTIVE", dev, focus_type, objid, prt_role2site, prt_role2site_part, role_name, vendor_part_no) ALWAYS;