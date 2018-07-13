CREATE TABLE sa.table_exc_usr_role (
  objid NUMBER,
  dev NUMBER,
  role_name VARCHAR2(80 BYTE),
  "ACTIVE" NUMBER,
  focus_type NUMBER,
  server_id NUMBER,
  exc_usr_role2user NUMBER,
  exc_usr_role2exchange NUMBER
);
ALTER TABLE sa.table_exc_usr_role ADD SUPPLEMENTAL LOG GROUP dmtsora1141121586_0 ("ACTIVE", dev, exc_usr_role2exchange, exc_usr_role2user, focus_type, objid, role_name, server_id) ALWAYS;