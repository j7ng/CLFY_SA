CREATE TABLE sa.table_disp_req (
  objid NUMBER,
  dev NUMBER,
  node_id VARCHAR2(3 BYTE),
  table_name VARCHAR2(30 BYTE),
  row_id NUMBER,
  taken_ind NUMBER
);
ALTER TABLE sa.table_disp_req ADD SUPPLEMENTAL LOG GROUP dmtsora1075472728_0 (dev, node_id, objid, row_id, table_name, taken_ind) ALWAYS;