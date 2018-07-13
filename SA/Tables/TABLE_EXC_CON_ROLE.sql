CREATE TABLE sa.table_exc_con_role (
  objid NUMBER,
  dev NUMBER,
  role_name VARCHAR2(80 BYTE),
  "ACTIVE" NUMBER,
  focus_type NUMBER,
  server_id NUMBER,
  exc_con_role2contact NUMBER,
  exc_con_role2exchange NUMBER
);
ALTER TABLE sa.table_exc_con_role ADD SUPPLEMENTAL LOG GROUP dmtsora970648646_0 ("ACTIVE", dev, exc_con_role2contact, exc_con_role2exchange, focus_type, objid, role_name, server_id) ALWAYS;