CREATE TABLE sa.table_hgbst_show_array_1 (
  objid NUMBER,
  seq_num NUMBER,
  "DATA" RAW(253)
);
ALTER TABLE sa.table_hgbst_show_array_1 ADD SUPPLEMENTAL LOG GROUP dmtsora1983650036_0 ("DATA", objid, seq_num) ALWAYS;