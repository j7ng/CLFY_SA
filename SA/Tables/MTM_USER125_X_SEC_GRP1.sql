CREATE TABLE sa.mtm_user125_x_sec_grp1 (
  user2x_sec_grp NUMBER NOT NULL,
  x_sec_grp2user NUMBER NOT NULL
);
ALTER TABLE sa.mtm_user125_x_sec_grp1 ADD SUPPLEMENTAL LOG GROUP dmtsora967417530_0 (user2x_sec_grp, x_sec_grp2user) ALWAYS;
COMMENT ON TABLE sa.mtm_user125_x_sec_grp1 IS 'Security group info for clarify users, equivalent to role membership.';
COMMENT ON COLUMN sa.mtm_user125_x_sec_grp1.user2x_sec_grp IS 'Reference to objid of table  table_user';
COMMENT ON COLUMN sa.mtm_user125_x_sec_grp1.x_sec_grp2user IS 'Reference to objid of table  table_x_sec_grp';