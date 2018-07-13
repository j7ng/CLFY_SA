CREATE TABLE sa.table_probdesc_array_1 (
  objid NUMBER,
  seq_num NUMBER,
  "DATA" RAW(253)
);
ALTER TABLE sa.table_probdesc_array_1 ADD SUPPLEMENTAL LOG GROUP dmtsora27231908_0 ("DATA", objid, seq_num) ALWAYS;