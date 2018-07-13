CREATE TABLE sa.table_keywd_elm (
  objid NUMBER,
  keyword VARCHAR2(15 BYTE),
  dev NUMBER,
  keywd_elm2query NUMBER(*,0)
);
ALTER TABLE sa.table_keywd_elm ADD SUPPLEMENTAL LOG GROUP dmtsora802265897_0 (dev, keywd_elm2query, keyword, objid) ALWAYS;