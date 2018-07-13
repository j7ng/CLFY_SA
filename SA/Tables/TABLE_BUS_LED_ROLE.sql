CREATE TABLE sa.table_bus_led_role (
  objid NUMBER,
  "ACTIVE" NUMBER,
  role_name VARCHAR2(80 BYTE),
  s_role_name VARCHAR2(80 BYTE),
  focus_type NUMBER,
  dev NUMBER,
  led_role2lead NUMBER,
  bus_led_role2bus_org NUMBER
);
ALTER TABLE sa.table_bus_led_role ADD SUPPLEMENTAL LOG GROUP dmtsora1895224782_0 ("ACTIVE", bus_led_role2bus_org, dev, focus_type, led_role2lead, objid, role_name, s_role_name) ALWAYS;