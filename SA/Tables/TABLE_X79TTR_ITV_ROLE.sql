CREATE TABLE sa.table_x79ttr_itv_role (
  objid NUMBER,
  dev NUMBER,
  role_name VARCHAR2(80 BYTE),
  focus_type NUMBER,
  "ACTIVE" NUMBER,
  server_id NUMBER,
  ttr_itv2x79interval NUMBER,
  ttr_itv2x79telcom_tr NUMBER
);
ALTER TABLE sa.table_x79ttr_itv_role ADD SUPPLEMENTAL LOG GROUP dmtsora1757433654_0 ("ACTIVE", dev, focus_type, objid, role_name, server_id, ttr_itv2x79interval, ttr_itv2x79telcom_tr) ALWAYS;