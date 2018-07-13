CREATE TABLE sa.table_bug_module (
  objid NUMBER,
  title VARCHAR2(250 BYTE),
  revision VARCHAR2(255 BYTE),
  status NUMBER,
  dev NUMBER,
  bug_module2bug NUMBER(*,0),
  bug_module2module NUMBER(*,0)
);
ALTER TABLE sa.table_bug_module ADD SUPPLEMENTAL LOG GROUP dmtsora1806703179_0 (bug_module2bug, bug_module2module, dev, objid, revision, status, title) ALWAYS;