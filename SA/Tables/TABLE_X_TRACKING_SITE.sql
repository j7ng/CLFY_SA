CREATE TABLE sa.table_x_tracking_site (
  objid NUMBER,
  x_site_id VARCHAR2(20 BYTE),
  x_site_desc VARCHAR2(50 BYTE)
);
ALTER TABLE sa.table_x_tracking_site ADD SUPPLEMENTAL LOG GROUP dmtsora1124594692_0 (objid, x_site_desc, x_site_id) ALWAYS;
COMMENT ON TABLE sa.table_x_tracking_site IS 'Contains the Site records for online tracking';
COMMENT ON COLUMN sa.table_x_tracking_site.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_x_tracking_site.x_site_id IS 'Site ID';
COMMENT ON COLUMN sa.table_x_tracking_site.x_site_desc IS 'Site Description';