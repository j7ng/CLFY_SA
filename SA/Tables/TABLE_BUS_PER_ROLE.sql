CREATE TABLE sa.table_bus_per_role (
  objid NUMBER,
  role_name VARCHAR2(80 BYTE),
  focus_type NUMBER,
  "ACTIVE" NUMBER,
  dev NUMBER,
  bus_per_role2bus_org NUMBER(*,0),
  bus_per_role2person NUMBER(*,0)
);
ALTER TABLE sa.table_bus_per_role ADD SUPPLEMENTAL LOG GROUP dmtsora1535306164_0 ("ACTIVE", bus_per_role2bus_org, bus_per_role2person, dev, focus_type, objid, role_name) ALWAYS;