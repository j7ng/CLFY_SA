CREATE TABLE sa.table_key_word (
  objid NUMBER,
  key_word VARCHAR2(255 BYTE),
  dev NUMBER
);
ALTER TABLE sa.table_key_word ADD SUPPLEMENTAL LOG GROUP dmtsora1370359402_0 (dev, key_word, objid) ALWAYS;