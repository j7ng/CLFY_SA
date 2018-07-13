CREATE TABLE sa.table_behavior (
  objid NUMBER,
  module_name VARCHAR2(80 BYTE),
  user_label VARCHAR2(80 BYTE),
  pcode_time DATE,
  source_time DATE,
  cust_ind NUMBER,
  dev NUMBER
);
ALTER TABLE sa.table_behavior ADD SUPPLEMENTAL LOG GROUP dmtsora1452616769_0 (cust_ind, dev, module_name, objid, pcode_time, source_time, user_label) ALWAYS;