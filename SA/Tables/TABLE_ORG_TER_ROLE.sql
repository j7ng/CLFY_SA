CREATE TABLE sa.table_org_ter_role (
  objid NUMBER,
  role_name VARCHAR2(80 BYTE),
  focus_type NUMBER,
  "ACTIVE" NUMBER,
  dev NUMBER,
  org_ter_role2territory NUMBER(*,0),
  org_ter_role2bus_org NUMBER(*,0)
);
ALTER TABLE sa.table_org_ter_role ADD SUPPLEMENTAL LOG GROUP dmtsora2043920459_0 ("ACTIVE", dev, focus_type, objid, org_ter_role2bus_org, org_ter_role2territory, role_name) ALWAYS;