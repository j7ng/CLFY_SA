CREATE TABLE sa.table_exc_sit_role (
  objid NUMBER,
  dev NUMBER,
  role_name VARCHAR2(80 BYTE),
  "ACTIVE" NUMBER,
  focus_type NUMBER,
  server_id NUMBER,
  exc_sit_role2site NUMBER,
  exc_sit_role2exchange NUMBER
);
ALTER TABLE sa.table_exc_sit_role ADD SUPPLEMENTAL LOG GROUP dmtsora1576218033_0 ("ACTIVE", dev, exc_sit_role2exchange, exc_sit_role2site, focus_type, objid, role_name, server_id) ALWAYS;