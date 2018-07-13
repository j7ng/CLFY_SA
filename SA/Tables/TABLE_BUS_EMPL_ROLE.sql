CREATE TABLE sa.table_bus_empl_role (
  objid NUMBER,
  role_name VARCHAR2(80 BYTE),
  focus_type NUMBER,
  "ACTIVE" NUMBER,
  dev NUMBER,
  bus_empl_role2bus_org NUMBER(*,0),
  bus_empl_role2employee NUMBER(*,0)
);
ALTER TABLE sa.table_bus_empl_role ADD SUPPLEMENTAL LOG GROUP dmtsora285740354_0 ("ACTIVE", bus_empl_role2bus_org, bus_empl_role2employee, dev, focus_type, objid, role_name) ALWAYS;