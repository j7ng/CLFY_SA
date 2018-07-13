CREATE TABLE sa.table_dataset (
  objid NUMBER,
  interface VARCHAR2(40 BYTE),
  dataset_name VARCHAR2(20 BYTE),
  description VARCHAR2(255 BYTE),
  filter_by VARCHAR2(255 BYTE),
  appl_id VARCHAR2(20 BYTE),
  strtobjno NUMBER,
  dev NUMBER
);
ALTER TABLE sa.table_dataset ADD SUPPLEMENTAL LOG GROUP dmtsora394586206_0 (appl_id, dataset_name, description, dev, filter_by, interface, objid, strtobjno) ALWAYS;