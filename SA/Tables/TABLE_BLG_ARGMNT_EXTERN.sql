CREATE TABLE sa.table_blg_argmnt_extern (
  objid NUMBER,
  dev NUMBER,
  last_update DATE,
  ext_src VARCHAR2(30 BYTE),
  ext_ref VARCHAR2(64 BYTE),
  blg_argmnt_extern2blg_argmnt NUMBER
);
ALTER TABLE sa.table_blg_argmnt_extern ADD SUPPLEMENTAL LOG GROUP dmtsora1191923286_0 (blg_argmnt_extern2blg_argmnt, dev, ext_ref, ext_src, last_update, objid) ALWAYS;