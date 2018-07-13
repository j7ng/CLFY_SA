CREATE TABLE sa.table_bus_bus_role (
  objid NUMBER,
  "ACTIVE" NUMBER,
  role_name VARCHAR2(80 BYTE),
  dev NUMBER,
  role_for2bus_org NUMBER(*,0),
  player2bus_org NUMBER(*,0)
);
ALTER TABLE sa.table_bus_bus_role ADD SUPPLEMENTAL LOG GROUP dmtsora289872901_0 ("ACTIVE", dev, objid, player2bus_org, role_for2bus_org, role_name) ALWAYS;