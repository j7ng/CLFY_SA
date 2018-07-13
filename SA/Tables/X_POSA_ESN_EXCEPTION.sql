CREATE TABLE sa.x_posa_esn_exception (
  esn VARCHAR2(80 BYTE),
  original_site_id VARCHAR2(80 BYTE),
  new_site_id VARCHAR2(80 BYTE),
  "ACTION" VARCHAR2(100 BYTE),
  creation_date DATE,
  created_by VARCHAR2(80 BYTE),
  last_updated DATE,
  last_updated_by VARCHAR2(80 BYTE)
);
ALTER TABLE sa.x_posa_esn_exception ADD SUPPLEMENTAL LOG GROUP dmtsora798589943_0 ("ACTION", created_by, creation_date, esn, last_updated, last_updated_by, new_site_id, original_site_id) ALWAYS;