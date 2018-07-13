CREATE TABLE sa.x_migr_conf (
  "WAIT" VARCHAR2(1 BYTE) CONSTRAINT x_migr_chk_wa CHECK ("WAIT" in ('Y','N')),
  "TYPE" VARCHAR2(100 BYTE),
  title VARCHAR2(100 BYTE),
  status VARCHAR2(100 BYTE),
  "ACTIVE" VARCHAR2(1 BYTE) CONSTRAINT x_migr_chk_ac CHECK ("ACTIVE" in ('Y','N')),
  CONSTRAINT x_migr_uni UNIQUE ("TYPE",title,status,"ACTIVE")
);
ALTER TABLE sa.x_migr_conf ADD SUPPLEMENTAL LOG GROUP dmtsora885776323_0 ("ACTIVE", status, title, "TYPE", "WAIT") ALWAYS;
COMMENT ON TABLE sa.x_migr_conf IS 'used by obsolete procedure migra_intellitrack.phone_receive.  It determines if a case type/title participates is the integration process process.';
COMMENT ON COLUMN sa.x_migr_conf."WAIT" IS 'Wait for Processing: Y/N';
COMMENT ON COLUMN sa.x_migr_conf."TYPE" IS 'Case Type';
COMMENT ON COLUMN sa.x_migr_conf.title IS 'Case Title';
COMMENT ON COLUMN sa.x_migr_conf.status IS 'Status of Case';
COMMENT ON COLUMN sa.x_migr_conf."ACTIVE" IS 'Configuration Record Active or Not: Y/N';