CREATE TABLE sa.rec_count (
  counter NUMBER
);
ALTER TABLE sa.rec_count ADD SUPPLEMENTAL LOG GROUP dmtsora1837777173_0 (counter) ALWAYS;