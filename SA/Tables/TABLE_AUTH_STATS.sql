CREATE TABLE sa.table_auth_stats (
  objid NUMBER,
  dev NUMBER,
  total_qoh NUMBER,
  as_of_date DATE,
  invest_val NUMBER(19,4),
  auth_stats2part_auth NUMBER
);
ALTER TABLE sa.table_auth_stats ADD SUPPLEMENTAL LOG GROUP dmtsora848540408_0 (as_of_date, auth_stats2part_auth, dev, invest_val, objid, total_qoh) ALWAYS;