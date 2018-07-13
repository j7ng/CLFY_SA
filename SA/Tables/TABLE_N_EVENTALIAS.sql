CREATE TABLE sa.table_n_eventalias (
  objid NUMBER,
  dev NUMBER,
  aliaseventname VARCHAR2(50 BYTE),
  itemtype VARCHAR2(50 BYTE),
  subtype VARCHAR2(50 BYTE),
  eventname VARCHAR2(50 BYTE),
  signature VARCHAR2(255 BYTE),
  stub LONG
);
ALTER TABLE sa.table_n_eventalias ADD SUPPLEMENTAL LOG GROUP dmtsora436296775_0 (aliaseventname, dev, eventname, itemtype, objid, signature, subtype) ALWAYS;