CREATE TABLE sa.file_versions (
  file_name VARCHAR2(60 BYTE),
  file_version VARCHAR2(10 BYTE),
  last_update_dt DATE
);
ALTER TABLE sa.file_versions ADD SUPPLEMENTAL LOG GROUP dmtsora16645091_0 (file_name, file_version, last_update_dt) ALWAYS;