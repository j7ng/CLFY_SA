CREATE TABLE sa.table_x79auth (
  objid NUMBER,
  dev NUMBER,
  "STATE" NUMBER,
  activity_type NUMBER,
  auth_time VARCHAR2(30 BYTE),
  server_id NUMBER,
  auth2x79person NUMBER,
  auth2x79tr_hist NUMBER,
  auth2x79telcom_tr NUMBER
);
ALTER TABLE sa.table_x79auth ADD SUPPLEMENTAL LOG GROUP dmtsora1137782436_0 (activity_type, auth2x79person, auth2x79telcom_tr, auth2x79tr_hist, auth_time, dev, objid, server_id, "STATE") ALWAYS;