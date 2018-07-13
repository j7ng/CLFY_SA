CREATE TABLE sa.table_rqst_queue (
  objid NUMBER,
  dev NUMBER,
  fields VARCHAR2(255 BYTE),
  ovf_fields LONG,
  queue2rqst_inst NUMBER
);
ALTER TABLE sa.table_rqst_queue ADD SUPPLEMENTAL LOG GROUP dmtsora331252008_0 (dev, fields, objid, queue2rqst_inst) ALWAYS;