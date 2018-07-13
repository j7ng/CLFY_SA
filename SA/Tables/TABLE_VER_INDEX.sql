CREATE TABLE sa.table_ver_index (
  objid NUMBER,
  data_id NUMBER,
  data_type NUMBER,
  "VERSION" NUMBER,
  dev NUMBER,
  ver_index2srvr NUMBER(*,0)
);
ALTER TABLE sa.table_ver_index ADD SUPPLEMENTAL LOG GROUP dmtsora606652821_0 (data_id, data_type, dev, objid, "VERSION", ver_index2srvr) ALWAYS;