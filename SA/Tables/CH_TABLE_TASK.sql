CREATE TABLE sa.ch_table_task (
  owner_name VARCHAR2(30 BYTE),
  table_name VARCHAR2(30 BYTE),
  cluster_name VARCHAR2(30 BYTE),
  partition_name VARCHAR2(30 BYTE),
  subpartition_name VARCHAR2(30 BYTE),
  head_rowid ROWID,
  analyze_timestamp DATE
);
ALTER TABLE sa.ch_table_task ADD SUPPLEMENTAL LOG GROUP dmtsora659261496_0 (analyze_timestamp, cluster_name, head_rowid, owner_name, partition_name, subpartition_name, table_name) ALWAYS;