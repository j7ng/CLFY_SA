CREATE TABLE sa.table_x79tr_txt (
  objid NUMBER,
  dev NUMBER,
  server_id NUMBER,
  addl_trouble LONG,
  info2x79telcom_tr NUMBER,
  stat2x79telcom_tr NUMBER
);
ALTER TABLE sa.table_x79tr_txt ADD SUPPLEMENTAL LOG GROUP dmtsora2033688998_0 (dev, info2x79telcom_tr, objid, server_id, stat2x79telcom_tr) ALWAYS;