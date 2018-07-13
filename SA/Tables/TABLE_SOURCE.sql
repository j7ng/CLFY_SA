CREATE TABLE sa.table_source (
  objid NUMBER,
  sequence_num NUMBER,
  code_chunk LONG,
  dev NUMBER,
  source2behavior NUMBER(*,0)
);
ALTER TABLE sa.table_source ADD SUPPLEMENTAL LOG GROUP dmtsora671915954_0 (dev, objid, sequence_num, source2behavior) ALWAYS;