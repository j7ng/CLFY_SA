CREATE TABLE sa.table_rpr_inst_qty (
  objid NUMBER,
  quantity NUMBER,
  dev NUMBER,
  inst_qty2part_info NUMBER,
  child2rpr_inst_qty NUMBER,
  orig_qty2demand_dtl NUMBER
);
ALTER TABLE sa.table_rpr_inst_qty ADD SUPPLEMENTAL LOG GROUP dmtsora348559384_0 (child2rpr_inst_qty, dev, inst_qty2part_info, objid, orig_qty2demand_dtl, quantity) ALWAYS;