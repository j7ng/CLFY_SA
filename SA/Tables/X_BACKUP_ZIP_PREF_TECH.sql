CREATE TABLE sa.x_backup_zip_pref_tech (
  zip_code VARCHAR2(5 BYTE),
  "STATE" VARCHAR2(2 BYTE),
  county VARCHAR2(50 BYTE),
  digpri_tec VARCHAR2(10 BYTE),
  gsm VARCHAR2(5 BYTE)
);
ALTER TABLE sa.x_backup_zip_pref_tech ADD SUPPLEMENTAL LOG GROUP dmtsora546652208_0 (county, digpri_tec, gsm, "STATE", zip_code) ALWAYS;