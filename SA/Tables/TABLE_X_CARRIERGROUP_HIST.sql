CREATE TABLE sa.table_x_carriergroup_hist (
  objid NUMBER,
  x_start_date DATE,
  x_end_date DATE,
  x_cargrp_hist2x_car NUMBER,
  x_cargrp_hist2x_cargrp NUMBER
);
ALTER TABLE sa.table_x_carriergroup_hist ADD SUPPLEMENTAL LOG GROUP dmtsora453520377_0 (objid, x_cargrp_hist2x_car, x_cargrp_hist2x_cargrp, x_end_date, x_start_date) ALWAYS;
COMMENT ON TABLE sa.table_x_carriergroup_hist IS 'Added A.P. - Stores history for carrier markets, when they change group';
COMMENT ON COLUMN sa.table_x_carriergroup_hist.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_x_carriergroup_hist.x_start_date IS 'Start Date';
COMMENT ON COLUMN sa.table_x_carriergroup_hist.x_end_date IS 'End Date';
COMMENT ON COLUMN sa.table_x_carriergroup_hist.x_cargrp_hist2x_car IS 'carrier history';
COMMENT ON COLUMN sa.table_x_carriergroup_hist.x_cargrp_hist2x_cargrp IS 'Carrier Group Releated to Carrier';