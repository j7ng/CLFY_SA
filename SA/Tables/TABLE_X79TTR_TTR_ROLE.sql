CREATE TABLE sa.table_x79ttr_ttr_role (
  objid NUMBER,
  dev NUMBER,
  role_name VARCHAR2(80 BYTE),
  "ACTIVE" NUMBER,
  server_id NUMBER,
  play2x79telcom_tr NUMBER,
  for2x79telcom_tr NUMBER
);
ALTER TABLE sa.table_x79ttr_ttr_role ADD SUPPLEMENTAL LOG GROUP dmtsora1845955256_0 ("ACTIVE", dev, for2x79telcom_tr, objid, play2x79telcom_tr, role_name, server_id) ALWAYS;