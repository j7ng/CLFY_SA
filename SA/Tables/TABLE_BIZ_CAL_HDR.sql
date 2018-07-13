CREATE TABLE sa.table_biz_cal_hdr (
  objid NUMBER,
  dev NUMBER,
  biz_cal_hdr2site NUMBER(*,0),
  biz_cal_hdr2exchange NUMBER,
  biz_cal_hdr2site_part NUMBER
);
ALTER TABLE sa.table_biz_cal_hdr ADD SUPPLEMENTAL LOG GROUP dmtsora1629659974_0 (biz_cal_hdr2exchange, biz_cal_hdr2site, biz_cal_hdr2site_part, dev, objid) ALWAYS;
COMMENT ON TABLE sa.table_biz_cal_hdr IS 'Header which groups the details of a business calendar';
COMMENT ON COLUMN sa.table_biz_cal_hdr.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_biz_cal_hdr.dev IS 'Row version number for mobile distribution purposes';
COMMENT ON COLUMN sa.table_biz_cal_hdr.biz_cal_hdr2site IS 'If owned by a site, the owning site';
COMMENT ON COLUMN sa.table_biz_cal_hdr.biz_cal_hdr2exchange IS 'If owned by an exchange, the owning exchange';
COMMENT ON COLUMN sa.table_biz_cal_hdr.biz_cal_hdr2site_part IS 'If owned by an installed part, the owing installed part';