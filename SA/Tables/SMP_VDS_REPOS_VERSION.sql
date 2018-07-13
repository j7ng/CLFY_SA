CREATE TABLE sa.smp_vds_repos_version (
  app_name VARCHAR2(512 BYTE),
  "VERSION" NUMBER NOT NULL,
  upd_in_progress NUMBER NOT NULL,
  "STANDALONE" NUMBER DEFAULT 1
);
ALTER TABLE sa.smp_vds_repos_version ADD SUPPLEMENTAL LOG GROUP dmtsora1233178862_0 (app_name, "STANDALONE", upd_in_progress, "VERSION") ALWAYS;