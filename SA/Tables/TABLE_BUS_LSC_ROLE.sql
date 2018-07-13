CREATE TABLE sa.table_bus_lsc_role (
  objid NUMBER,
  role_name VARCHAR2(80 BYTE),
  s_role_name VARCHAR2(80 BYTE),
  focus_type NUMBER,
  "ACTIVE" NUMBER,
  dev NUMBER,
  bus_lsc2bus_org NUMBER,
  bus_lsc2lead_source NUMBER
);
ALTER TABLE sa.table_bus_lsc_role ADD SUPPLEMENTAL LOG GROUP dmtsora578263355_0 ("ACTIVE", bus_lsc2bus_org, bus_lsc2lead_source, dev, focus_type, objid, role_name, s_role_name) ALWAYS;