CREATE TABLE sa.table_bus_site_role (
  objid NUMBER,
  role_name VARCHAR2(80 BYTE),
  focus_type NUMBER,
  "ACTIVE" NUMBER,
  dev NUMBER,
  bus_site_role2site NUMBER(*,0),
  bus_site_role2bus_org NUMBER(*,0)
);
ALTER TABLE sa.table_bus_site_role ADD SUPPLEMENTAL LOG GROUP dmtsora13305941_0 ("ACTIVE", bus_site_role2bus_org, bus_site_role2site, dev, focus_type, objid, role_name) ALWAYS;