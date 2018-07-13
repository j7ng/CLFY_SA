CREATE TABLE sa.table_n_tablealias (
  objid NUMBER,
  dev NUMBER,
  aliastablename VARCHAR2(50 BYTE),
  tablename VARCHAR2(50 BYTE)
);
ALTER TABLE sa.table_n_tablealias ADD SUPPLEMENTAL LOG GROUP dmtsora682147415_0 (aliastablename, dev, objid, tablename) ALWAYS;