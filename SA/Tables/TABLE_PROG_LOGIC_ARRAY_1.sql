CREATE TABLE sa.table_prog_logic_array_1 (
  objid NUMBER,
  seq_num NUMBER,
  "DATA" RAW(253)
);
ALTER TABLE sa.table_prog_logic_array_1 ADD SUPPLEMENTAL LOG GROUP dmtsora1803364030_0 ("DATA", objid, seq_num) ALWAYS;