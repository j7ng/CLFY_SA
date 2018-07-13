CREATE TABLE sa.table_per_site_role (
  objid NUMBER,
  role_name VARCHAR2(80 BYTE),
  focus_type NUMBER,
  "ACTIVE" NUMBER,
  dev NUMBER,
  per_site_role2site NUMBER(*,0),
  per_site_role2person NUMBER(*,0)
);
ALTER TABLE sa.table_per_site_role ADD SUPPLEMENTAL LOG GROUP dmtsora499794888_0 ("ACTIVE", dev, focus_type, objid, per_site_role2person, per_site_role2site, role_name) ALWAYS;