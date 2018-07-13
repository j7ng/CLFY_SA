CREATE TABLE sa.table_x_parent_hist (
  objid NUMBER,
  x_begin_date DATE,
  x_end_date DATE,
  x_parent_hist2x_carrier_group NUMBER,
  x_parent_hist2x_parent NUMBER
);
ALTER TABLE sa.table_x_parent_hist ADD SUPPLEMENTAL LOG GROUP dmtsora706238386_0 (objid, x_begin_date, x_end_date, x_parent_hist2x_carrier_group, x_parent_hist2x_parent) ALWAYS;
COMMENT ON TABLE sa.table_x_parent_hist IS 'Carrier parent history';
COMMENT ON COLUMN sa.table_x_parent_hist.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_x_parent_hist.x_begin_date IS 'The date the group was related to the parent';
COMMENT ON COLUMN sa.table_x_parent_hist.x_end_date IS 'The date the group was unrelated from the parent';
COMMENT ON COLUMN sa.table_x_parent_hist.x_parent_hist2x_carrier_group IS 'Relation to carrier group';
COMMENT ON COLUMN sa.table_x_parent_hist.x_parent_hist2x_parent IS 'Relation to parent history';