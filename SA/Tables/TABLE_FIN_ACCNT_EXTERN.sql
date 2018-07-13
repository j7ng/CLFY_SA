CREATE TABLE sa.table_fin_accnt_extern (
  objid NUMBER,
  dev NUMBER,
  last_update DATE,
  ext_src VARCHAR2(30 BYTE),
  ext_ref VARCHAR2(64 BYTE),
  fin_accnt_extern2fin_accnt NUMBER
);
ALTER TABLE sa.table_fin_accnt_extern ADD SUPPLEMENTAL LOG GROUP dmtsora1296884280_0 (dev, ext_ref, ext_src, fin_accnt_extern2fin_accnt, last_update, objid) ALWAYS;