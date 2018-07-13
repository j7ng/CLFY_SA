CREATE TABLE sa.table_x_mtm_case_hdr_dtl (
  objid NUMBER,
  dev NUMBER,
  x_mandatory NUMBER,
  x_order NUMBER,
  x_legacy_rule VARCHAR2(100 BYTE),
  x_legacy_name VARCHAR2(30 BYTE),
  x_read_only NUMBER,
  mtm_conf2conf_hdr NUMBER,
  mtm_conf2conf_dtl NUMBER
);
ALTER TABLE sa.table_x_mtm_case_hdr_dtl ADD SUPPLEMENTAL LOG GROUP dmtsora1937216333_0 (dev, mtm_conf2conf_dtl, mtm_conf2conf_hdr, objid, x_legacy_name, x_legacy_rule, x_mandatory, x_order, x_read_only) ALWAYS;
COMMENT ON TABLE sa.table_x_mtm_case_hdr_dtl IS 'Many to Many relation between case conf header and case conf detail';
COMMENT ON COLUMN sa.table_x_mtm_case_hdr_dtl.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_x_mtm_case_hdr_dtl.dev IS 'Row version number for mobile distribution purposes';
COMMENT ON COLUMN sa.table_x_mtm_case_hdr_dtl.x_mandatory IS 'Field is required 0=No 1=Yes';
COMMENT ON COLUMN sa.table_x_mtm_case_hdr_dtl.x_order IS 'display Order, should be consecutive for a given header';
COMMENT ON COLUMN sa.table_x_mtm_case_hdr_dtl.x_legacy_rule IS 'Legacy Rule';
COMMENT ON COLUMN sa.table_x_mtm_case_hdr_dtl.x_legacy_name IS 'Legacy Name';
COMMENT ON COLUMN sa.table_x_mtm_case_hdr_dtl.x_read_only IS 'Read only fields after the case is created 0=No 1=Yes';
COMMENT ON COLUMN sa.table_x_mtm_case_hdr_dtl.mtm_conf2conf_hdr IS 'TBD';
COMMENT ON COLUMN sa.table_x_mtm_case_hdr_dtl.mtm_conf2conf_dtl IS 'TBD';