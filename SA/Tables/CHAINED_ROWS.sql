CREATE TABLE sa.chained_rows (
  owner_name VARCHAR2(30 BYTE),
  table_name VARCHAR2(30 BYTE),
  cluster_name VARCHAR2(30 BYTE),
  partition_name VARCHAR2(30 BYTE),
  subpartition_name VARCHAR2(30 BYTE),
  head_rowid ROWID,
  analyze_timestamp DATE
);