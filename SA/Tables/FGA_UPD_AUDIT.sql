CREATE TABLE sa.fga_upd_audit (
  db_user VARCHAR2(30 BYTE),
  "TIMESTAMP" DATE,
  table_name VARCHAR2(30 BYTE)
);
ALTER TABLE sa.fga_upd_audit ADD SUPPLEMENTAL LOG GROUP dmtsora1884051684_0 (db_user, table_name, "TIMESTAMP") ALWAYS;