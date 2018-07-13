CREATE TABLE sa.table_nrw_resources (
  objid NUMBER,
  dev NUMBER,
  n_resourceid NUMBER,
  n_resourcename VARCHAR2(255 BYTE)
);
ALTER TABLE sa.table_nrw_resources ADD SUPPLEMENTAL LOG GROUP dmtsora1572682101_0 (dev, n_resourceid, n_resourcename, objid) ALWAYS;