CREATE TABLE sa.table_x79ttr_loc_role (
  objid NUMBER,
  dev NUMBER,
  role_name VARCHAR2(80 BYTE),
  focus_type NUMBER,
  "ACTIVE" NUMBER,
  server_id NUMBER,
  ttr_loc2x79location NUMBER,
  ttr_loc2x79telcom_tr NUMBER
);
ALTER TABLE sa.table_x79ttr_loc_role ADD SUPPLEMENTAL LOG GROUP dmtsora209969035_0 ("ACTIVE", dev, focus_type, objid, role_name, server_id, ttr_loc2x79location, ttr_loc2x79telcom_tr) ALWAYS;