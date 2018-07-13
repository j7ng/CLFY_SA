CREATE TABLE sa.quarantine_ofs_update (
  x_smp VARCHAR2(30 BYTE),
  x_fin_cust_id VARCHAR2(40 BYTE),
  "NAME" VARCHAR2(80 BYTE),
  site_type VARCHAR2(4 BYTE)
);
ALTER TABLE sa.quarantine_ofs_update ADD SUPPLEMENTAL LOG GROUP dmtsora1888094369_0 ("NAME", site_type, x_fin_cust_id, x_smp) ALWAYS;