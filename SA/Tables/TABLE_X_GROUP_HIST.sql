CREATE TABLE sa.table_x_group_hist (
  objid NUMBER,
  x_start_date DATE,
  x_end_date DATE,
  x_action_date DATE,
  x_action_type VARCHAR2(30 BYTE),
  x_annual_plan NUMBER,
  grouphist2part_inst NUMBER,
  grouphist2x_promo_group NUMBER,
  x_old_esn VARCHAR2(30 BYTE)
);
ALTER TABLE sa.table_x_group_hist ADD SUPPLEMENTAL LOG GROUP dmtsora1006825242_0 (grouphist2part_inst, grouphist2x_promo_group, objid, x_action_date, x_action_type, x_annual_plan, x_end_date, x_old_esn, x_start_date) ALWAYS;
COMMENT ON TABLE sa.table_x_group_hist IS 'Added E.J. - esns related to promotion groups history';
COMMENT ON COLUMN sa.table_x_group_hist.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_x_group_hist.x_start_date IS 'Start Date';
COMMENT ON COLUMN sa.table_x_group_hist.x_end_date IS 'End Date';
COMMENT ON COLUMN sa.table_x_group_hist.x_action_date IS 'End Date';
COMMENT ON COLUMN sa.table_x_group_hist.x_action_type IS 'Action for History table insert';
COMMENT ON COLUMN sa.table_x_group_hist.x_annual_plan IS '0 = non annual plan, 1 = annual plan, 2 = pending annual plan';
COMMENT ON COLUMN sa.table_x_group_hist.grouphist2part_inst IS 'Promo Group Hist Related to esn';
COMMENT ON COLUMN sa.table_x_group_hist.grouphist2x_promo_group IS 'esn hist related to promo group';
COMMENT ON COLUMN sa.table_x_group_hist.x_old_esn IS 'TBD';