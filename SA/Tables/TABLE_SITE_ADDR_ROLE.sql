CREATE TABLE sa.table_site_addr_role (
  objid NUMBER,
  role_name VARCHAR2(80 BYTE),
  focus_type NUMBER,
  "ACTIVE" NUMBER,
  dev NUMBER,
  site_add_role2address NUMBER(*,0),
  site_addr_role2site NUMBER(*,0)
);
ALTER TABLE sa.table_site_addr_role ADD SUPPLEMENTAL LOG GROUP dmtsora1337790829_0 ("ACTIVE", dev, focus_type, objid, role_name, site_addr_role2site, site_add_role2address) ALWAYS;