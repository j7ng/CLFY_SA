CREATE TABLE sa.adp_db_header (
  db_name VARCHAR2(128 BYTE) NOT NULL,
  create_date DATE,
  last_full_backup DATE,
  last_incr_backup DATE,
  up_since DATE,
  last_modify DATE,
  site_id NUMBER,
  site_id_offline NUMBER,
  db_rev NUMBER,
  schema_rev NUMBER,
  cust_int_sch_rev NUMBER,
  gmt_diff NUMBER(*,0),
  cust_schema_rev VARCHAR2(64 BYTE),
  flags NUMBER,
  clarify_schema_date DATE,
  cust_schema_date DATE,
  site_num_bits NUMBER
);
ALTER TABLE sa.adp_db_header ADD SUPPLEMENTAL LOG GROUP dmtsora632085429_0 (clarify_schema_date, create_date, cust_int_sch_rev, cust_schema_date, cust_schema_rev, db_name, db_rev, flags, gmt_diff, last_full_backup, last_incr_backup, last_modify, schema_rev, site_id, site_id_offline, site_num_bits, up_since) ALWAYS;