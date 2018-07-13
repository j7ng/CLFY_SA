CREATE TABLE sa.mtm_x_sec_grp2_x_sec_func0 (
  x_sec_grp2x_sec_func NUMBER NOT NULL,
  x_sec_func2x_sec_grp NUMBER NOT NULL
);
ALTER TABLE sa.mtm_x_sec_grp2_x_sec_func0 ADD SUPPLEMENTAL LOG GROUP dmtsora1587068748_0 (x_sec_func2x_sec_grp, x_sec_grp2x_sec_func) ALWAYS;
COMMENT ON TABLE sa.mtm_x_sec_grp2_x_sec_func0 IS 'Security functions info for security groups';
COMMENT ON COLUMN sa.mtm_x_sec_grp2_x_sec_func0.x_sec_grp2x_sec_func IS 'Reference to objid of table table_x_sec_grp';
COMMENT ON COLUMN sa.mtm_x_sec_grp2_x_sec_func0.x_sec_func2x_sec_grp IS 'Reference to objid in table_x_sec_func';