CREATE TABLE sa.table_keyphrase_array_3 (
  objid NUMBER,
  seq_num NUMBER,
  "DATA" RAW(253)
);
ALTER TABLE sa.table_keyphrase_array_3 ADD SUPPLEMENTAL LOG GROUP dmtsora2122773526_0 ("DATA", objid, seq_num) ALWAYS;