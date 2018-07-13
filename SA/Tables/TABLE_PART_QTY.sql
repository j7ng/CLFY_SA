CREATE TABLE sa.table_part_qty (
  objid NUMBER,
  quantity NUMBER,
  bom_type NUMBER,
  dev NUMBER,
  part_qty2part_info NUMBER(*,0),
  part_qty2part_incl NUMBER(*,0)
);
ALTER TABLE sa.table_part_qty ADD SUPPLEMENTAL LOG GROUP dmtsora1258209855_0 (bom_type, dev, objid, part_qty2part_incl, part_qty2part_info, quantity) ALWAYS;