CREATE TABLE sa.table_x_sec_grp (
  objid NUMBER,
  dev NUMBER,
  x_grp_id VARCHAR2(10 BYTE),
  x_grp_name VARCHAR2(50 BYTE),
  x_grp_desc VARCHAR2(100 BYTE),
  x_create_date DATE,
  x_grp_validate_flag VARCHAR2(35 BYTE),
  x_sec_grp2x_threshold NUMBER,
  x_sourcesystem VARCHAR2(20 BYTE)
);
ALTER TABLE sa.table_x_sec_grp ADD SUPPLEMENTAL LOG GROUP dmtsora1926650241_0 (dev, objid, x_create_date, x_grp_desc, x_grp_id, x_grp_name, x_grp_validate_flag, x_sec_grp2x_threshold, x_sourcesystem) ALWAYS;
COMMENT ON TABLE sa.table_x_sec_grp IS 'Contains security groups to assign to users';
COMMENT ON COLUMN sa.table_x_sec_grp.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_x_sec_grp.dev IS 'Row version number for mobile distribution purposes';
COMMENT ON COLUMN sa.table_x_sec_grp.x_grp_id IS 'Group Identification Number';
COMMENT ON COLUMN sa.table_x_sec_grp.x_grp_name IS 'TBD';
COMMENT ON COLUMN sa.table_x_sec_grp.x_grp_desc IS 'TBD';
COMMENT ON COLUMN sa.table_x_sec_grp.x_create_date IS 'Date in which group was created';
COMMENT ON COLUMN sa.table_x_sec_grp.x_grp_validate_flag IS 'Flags if group is valid or invalid';
COMMENT ON COLUMN sa.table_x_sec_grp.x_sec_grp2x_threshold IS 'Threshold information for each group';
COMMENT ON COLUMN sa.table_x_sec_grp.x_sourcesystem IS 'Application ';