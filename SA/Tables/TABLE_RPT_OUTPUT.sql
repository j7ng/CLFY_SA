CREATE TABLE sa.table_rpt_output (
  objid NUMBER,
  title VARCHAR2(80 BYTE),
  output1 LONG,
  dev NUMBER
);
ALTER TABLE sa.table_rpt_output ADD SUPPLEMENTAL LOG GROUP dmtsora2138513080_0 (dev, objid, title) ALWAYS;