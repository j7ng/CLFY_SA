CREATE TABLE sa.table_keyphrase_array_2 (
  objid NUMBER,
  seq_num NUMBER,
  "DATA" RAW(253)
);
ALTER TABLE sa.table_keyphrase_array_2 ADD SUPPLEMENTAL LOG GROUP dmtsora321461975_0 ("DATA", objid, seq_num) ALWAYS;