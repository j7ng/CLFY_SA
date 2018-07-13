CREATE TABLE sa.table_keyphrase_array_1 (
  objid NUMBER,
  seq_num NUMBER,
  "DATA" RAW(253)
);
ALTER TABLE sa.table_keyphrase_array_1 ADD SUPPLEMENTAL LOG GROUP dmtsora179549266_0 ("DATA", objid, seq_num) ALWAYS;