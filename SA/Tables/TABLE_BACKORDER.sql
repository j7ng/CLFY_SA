CREATE TABLE sa.table_backorder (
  objid NUMBER,
  backorder_qty NUMBER,
  exp_ship_date DATE,
  dev NUMBER,
  backorder2demand_dtl NUMBER(*,0),
  backorder2part_info NUMBER(*,0)
);
ALTER TABLE sa.table_backorder ADD SUPPLEMENTAL LOG GROUP dmtsora1364095167_0 (backorder2demand_dtl, backorder2part_info, backorder_qty, dev, exp_ship_date, objid) ALWAYS;