CREATE TABLE sa.table_with_chained_rows_a (
  "OWNER" VARCHAR2(10 BYTE),
  table_name VARCHAR2(100 BYTE),
  analysis_started DATE,
  analysis_end DATE,
  no_of_chained_rows NUMBER
);
ALTER TABLE sa.table_with_chained_rows_a ADD SUPPLEMENTAL LOG GROUP dmtsora872217629_0 (analysis_end, analysis_started, no_of_chained_rows, "OWNER", table_name) ALWAYS;