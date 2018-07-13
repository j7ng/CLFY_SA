CREATE TABLE sa.table_rqst_pending (
  objid NUMBER,
  dev NUMBER,
  start_time DATE,
  is_activation NUMBER,
  pending2rqst_inst NUMBER,
  pending2n_attributevalue NUMBER
);
ALTER TABLE sa.table_rqst_pending ADD SUPPLEMENTAL LOG GROUP dmtsora718139612_0 (dev, is_activation, objid, pending2n_attributevalue, pending2rqst_inst, start_time) ALWAYS;