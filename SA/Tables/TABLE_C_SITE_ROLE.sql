CREATE TABLE sa.table_c_site_role (
  objid NUMBER,
  role_name VARCHAR2(80 BYTE),
  focus_type NUMBER,
  "ACTIVE" NUMBER,
  dev NUMBER,
  c_site_role2contr_itm NUMBER(*,0),
  c_site_role2site NUMBER(*,0)
);
ALTER TABLE sa.table_c_site_role ADD SUPPLEMENTAL LOG GROUP dmtsora344427163_0 ("ACTIVE", c_site_role2contr_itm, c_site_role2site, dev, focus_type, objid, role_name) ALWAYS;