CREATE TABLE sa.table_n_columnalias (
  objid NUMBER,
  dev NUMBER,
  aliascolumnname VARCHAR2(50 BYTE),
  columnname VARCHAR2(50 BYTE),
  n_colname2n_tablealias NUMBER
);
ALTER TABLE sa.table_n_columnalias ADD SUPPLEMENTAL LOG GROUP dmtsora1826329218_0 (aliascolumnname, columnname, dev, n_colname2n_tablealias, objid) ALWAYS;