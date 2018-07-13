CREATE TABLE sa.sp_table_chainrows_analysis (
  table_name VARCHAR2(100 BYTE),
  analysis_started DATE,
  analysis_end DATE,
  no_of_chained_rows NUMBER,
  total_no_of_rows NUMBER,
  "OWNER" VARCHAR2(10 BYTE),
  long_datatype VARCHAR2(13 BYTE),
  no_of_chained_rows_left VARCHAR2(25 BYTE),
  bytes_mb NUMBER(10,2),
  no_of_indexes NUMBER
);
ALTER TABLE sa.sp_table_chainrows_analysis ADD SUPPLEMENTAL LOG GROUP dmtsora447468258_0 (analysis_end, analysis_started, bytes_mb, long_datatype, no_of_chained_rows, no_of_chained_rows_left, no_of_indexes, "OWNER", table_name, total_no_of_rows) ALWAYS;