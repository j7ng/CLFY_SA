CREATE TABLE sa.sp_tables (
  "OWNER" VARCHAR2(300 BYTE),
  owner_name VARCHAR2(300 BYTE)
);
ALTER TABLE sa.sp_tables ADD SUPPLEMENTAL LOG GROUP dmtsora784491284_0 ("OWNER", owner_name) ALWAYS;