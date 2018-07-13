CREATE TABLE sa.table_x79esc_per_role (
  objid NUMBER,
  dev NUMBER,
  role_name VARCHAR2(80 BYTE),
  focus_type NUMBER,
  "ACTIVE" NUMBER,
  server_id NUMBER,
  esc_per2x79person NUMBER,
  esc_per2x79escal NUMBER
);
ALTER TABLE sa.table_x79esc_per_role ADD SUPPLEMENTAL LOG GROUP dmtsora1226304039_0 ("ACTIVE", dev, esc_per2x79escal, esc_per2x79person, focus_type, objid, role_name, server_id) ALWAYS;