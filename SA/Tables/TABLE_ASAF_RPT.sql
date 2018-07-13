CREATE TABLE sa.table_asaf_rpt (
  objid NUMBER,
  title VARCHAR2(80 BYTE),
  sqr_text LONG,
  dev NUMBER
);
ALTER TABLE sa.table_asaf_rpt ADD SUPPLEMENTAL LOG GROUP dmtsora986388200_0 (dev, objid, title) ALWAYS;