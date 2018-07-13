CREATE TABLE sa.table_ct_bus_role (
  objid NUMBER,
  role_name VARCHAR2(80 BYTE),
  s_role_name VARCHAR2(80 BYTE),
  focus_type NUMBER,
  "ACTIVE" NUMBER,
  dev NUMBER,
  ct_bus_role2contact NUMBER,
  ct_bus_role2bus_org NUMBER
);
ALTER TABLE sa.table_ct_bus_role ADD SUPPLEMENTAL LOG GROUP dmtsora546069399_0 ("ACTIVE", ct_bus_role2bus_org, ct_bus_role2contact, dev, focus_type, objid, role_name, s_role_name) ALWAYS;