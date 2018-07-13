CREATE TABLE sa.sp_sa_table_with_chained (
  table_name VARCHAR2(100 BYTE),
  analysis_started DATE,
  analysis_end DATE,
  no_of_chained_rows NUMBER
);
ALTER TABLE sa.sp_sa_table_with_chained ADD SUPPLEMENTAL LOG GROUP dmtsora655922347_0 (analysis_end, analysis_started, no_of_chained_rows, table_name) ALWAYS;