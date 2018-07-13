CREATE TABLE sa.x_sec_grp_hist (
  objid NUMBER,
  dev NUMBER,
  x_grp_id VARCHAR2(10 BYTE),
  x_grp_name VARCHAR2(50 BYTE),
  x_grp_desc VARCHAR2(100 BYTE),
  x_create_date DATE,
  x_grp_validate_flag VARCHAR2(35 BYTE),
  x_sec_grp2x_threshold NUMBER,
  x_sourcesystem VARCHAR2(20 BYTE),
  sec_grp_hist2sec_grp NUMBER,
  sec_grp_hist2user NUMBER,
  x_change_date DATE,
  osuser VARCHAR2(30 BYTE),
  triggering_record_type VARCHAR2(6 BYTE)
);
COMMENT ON TABLE sa.x_sec_grp_hist IS 'This is a historic log for all the changes performed on table_x_sec_grp';
COMMENT ON COLUMN sa.x_sec_grp_hist.objid IS 'Internal Reference ID';
COMMENT ON COLUMN sa.x_sec_grp_hist.dev IS 'not used.';
COMMENT ON COLUMN sa.x_sec_grp_hist.x_grp_id IS 'Group ID';
COMMENT ON COLUMN sa.x_sec_grp_hist.x_grp_name IS 'Group Name';
COMMENT ON COLUMN sa.x_sec_grp_hist.x_grp_desc IS 'Group Description';
COMMENT ON COLUMN sa.x_sec_grp_hist.x_create_date IS 'Date ofsecurity group creation';
COMMENT ON COLUMN sa.x_sec_grp_hist.x_grp_validate_flag IS 'Validate Flag: 0,1';
COMMENT ON COLUMN sa.x_sec_grp_hist.x_sec_grp2x_threshold IS 'Reference to table_x_sec_threshold';
COMMENT ON COLUMN sa.x_sec_grp_hist.x_sourcesystem IS 'not used.';
COMMENT ON COLUMN sa.x_sec_grp_hist.sec_grp_hist2sec_grp IS 'Reference to table_x_sec_grp';
COMMENT ON COLUMN sa.x_sec_grp_hist.sec_grp_hist2user IS 'Reference to table_user, record creator';
COMMENT ON COLUMN sa.x_sec_grp_hist.x_change_date IS 'Timestamp for change';
COMMENT ON COLUMN sa.x_sec_grp_hist.osuser IS 'Operating System User ID';
COMMENT ON COLUMN sa.x_sec_grp_hist.triggering_record_type IS 'Type of change: INSERT,UPDATE,DELETE';