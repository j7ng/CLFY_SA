CREATE TABLE sa.table_x79ttr_per_role (
  objid NUMBER,
  dev NUMBER,
  role_name VARCHAR2(80 BYTE),
  focus_type NUMBER,
  "ACTIVE" NUMBER,
  server_id NUMBER,
  ttr_per2x79person NUMBER,
  ttr_per2x79telcom_tr NUMBER
);
ALTER TABLE sa.table_x79ttr_per_role ADD SUPPLEMENTAL LOG GROUP dmtsora389471253_0 ("ACTIVE", dev, focus_type, objid, role_name, server_id, ttr_per2x79person, ttr_per2x79telcom_tr) ALWAYS;