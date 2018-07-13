CREATE TABLE sa.table_x_group2esn (
  objid NUMBER,
  x_annual_plan NUMBER,
  groupesn2part_inst NUMBER,
  groupesn2x_promo_group NUMBER,
  x_end_date DATE,
  x_start_date DATE,
  groupesn2x_promotion NUMBER
);
ALTER TABLE sa.table_x_group2esn ADD SUPPLEMENTAL LOG GROUP dmtsora235000028_0 (groupesn2part_inst, groupesn2x_promotion, groupesn2x_promo_group, objid, x_annual_plan, x_end_date, x_start_date) ALWAYS;
COMMENT ON TABLE sa.table_x_group2esn IS 'Added J.R. - esns related to promotion groups for flashes';
COMMENT ON COLUMN sa.table_x_group2esn.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_x_group2esn.x_annual_plan IS '0 = non annual plan, 1 = annual plan, 2 = pending annual plan';
COMMENT ON COLUMN sa.table_x_group2esn.groupesn2part_inst IS 'Promo Group Related to esn';
COMMENT ON COLUMN sa.table_x_group2esn.groupesn2x_promo_group IS 'esn related to promo group';
COMMENT ON COLUMN sa.table_x_group2esn.x_end_date IS 'End Date';
COMMENT ON COLUMN sa.table_x_group2esn.x_start_date IS 'Start Date';
COMMENT ON COLUMN sa.table_x_group2esn.groupesn2x_promotion IS 'Relation to Promotion Record';