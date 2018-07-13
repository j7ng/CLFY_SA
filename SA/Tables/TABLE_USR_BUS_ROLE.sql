CREATE TABLE sa.table_usr_bus_role (
  objid NUMBER,
  role_name VARCHAR2(80 BYTE),
  s_role_name VARCHAR2(80 BYTE),
  focus_type NUMBER,
  "ACTIVE" NUMBER,
  dev NUMBER,
  usr_bus_role2bus_org NUMBER,
  usr_bus_role2user NUMBER
);
ALTER TABLE sa.table_usr_bus_role ADD SUPPLEMENTAL LOG GROUP dmtsora1205327803_0 ("ACTIVE", dev, focus_type, objid, role_name, s_role_name, usr_bus_role2bus_org, usr_bus_role2user) ALWAYS;