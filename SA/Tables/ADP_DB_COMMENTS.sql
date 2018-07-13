CREATE TABLE sa.adp_db_comments (
  seq_num NUMBER(*,0),
  "TIME" DATE,
  comments VARCHAR2(255 BYTE)
);
ALTER TABLE sa.adp_db_comments ADD SUPPLEMENTAL LOG GROUP dmtsora1478921107_0 (comments, seq_num, "TIME") ALWAYS;