CREATE TABLE sa.ja_dups2 (
  mdn_objid NUMBER
);
ALTER TABLE sa.ja_dups2 ADD SUPPLEMENTAL LOG GROUP dmtsora702667546_0 (mdn_objid) ALWAYS;