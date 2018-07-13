CREATE TABLE sa.table_bus_addr_role (
  objid NUMBER,
  role_name VARCHAR2(80 BYTE),
  focus_type NUMBER,
  "ACTIVE" NUMBER,
  dev NUMBER,
  bus_addr_role2address NUMBER(*,0),
  bus_addr_role2bus_org NUMBER(*,0)
);
ALTER TABLE sa.table_bus_addr_role ADD SUPPLEMENTAL LOG GROUP dmtsora237820094_0 ("ACTIVE", bus_addr_role2address, bus_addr_role2bus_org, dev, focus_type, objid, role_name) ALWAYS;