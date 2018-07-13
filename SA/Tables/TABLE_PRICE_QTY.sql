CREATE TABLE sa.table_price_qty (
  objid NUMBER,
  priced_qty NUMBER,
  p_qty_type NUMBER,
  dev NUMBER,
  priced_part2mod_level NUMBER(*,0),
  context_part2mod_level NUMBER(*,0),
  priced2vendor_part NUMBER
);
ALTER TABLE sa.table_price_qty ADD SUPPLEMENTAL LOG GROUP dmtsora1834272295_0 (context_part2mod_level, dev, objid, priced2vendor_part, priced_part2mod_level, priced_qty, p_qty_type) ALWAYS;
COMMENT ON COLUMN sa.table_price_qty.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_price_qty.priced_qty IS 'The quantity of the priced part being quoted. Default=1';
COMMENT ON COLUMN sa.table_price_qty.p_qty_type IS 'Type of price_qty; 0=is a standalone part, 1=is a parent or child part';
COMMENT ON COLUMN sa.table_price_qty.dev IS 'Row version number for mobile distribution purposes';