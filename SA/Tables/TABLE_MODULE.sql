CREATE TABLE sa.table_module (
  objid NUMBER,
  title VARCHAR2(250 BYTE),
  revision VARCHAR2(16 BYTE),
  dev NUMBER,
  module2fix_bug NUMBER(*,0),
  module2act_entry NUMBER(*,0)
);
ALTER TABLE sa.table_module ADD SUPPLEMENTAL LOG GROUP dmtsora551352318_0 (dev, module2act_entry, module2fix_bug, objid, revision, title) ALWAYS;