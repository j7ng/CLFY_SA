CREATE TABLE sa.table_x_mtm_ffc2conf_hdr (
  objid NUMBER,
  dev NUMBER,
  mtm_ffc2conf_hdr NUMBER,
  mtm_ffc2ff_center NUMBER
);
ALTER TABLE sa.table_x_mtm_ffc2conf_hdr ADD SUPPLEMENTAL LOG GROUP dmtsora1972924752_0 (dev, mtm_ffc2conf_hdr, mtm_ffc2ff_center, objid) ALWAYS;
COMMENT ON TABLE sa.table_x_mtm_ffc2conf_hdr IS 'Many to many relation between case type/title and fulfillment center';
COMMENT ON COLUMN sa.table_x_mtm_ffc2conf_hdr.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_x_mtm_ffc2conf_hdr.dev IS 'Row version number for mobile distribution purposes';
COMMENT ON COLUMN sa.table_x_mtm_ffc2conf_hdr.mtm_ffc2conf_hdr IS 'TBD';
COMMENT ON COLUMN sa.table_x_mtm_ffc2conf_hdr.mtm_ffc2ff_center IS 'TBD';