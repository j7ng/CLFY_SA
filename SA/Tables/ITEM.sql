CREATE TABLE sa.item (
  ordid NUMBER(4) NOT NULL,
  itemid NUMBER(4) NOT NULL,
  prodid NUMBER(6),
  actualprice NUMBER(8,2),
  qty NUMBER(8),
  itemtot NUMBER(8,2)
);
ALTER TABLE sa.item ADD SUPPLEMENTAL LOG GROUP dmtsora79950914_0 (actualprice, itemid, itemtot, ordid, prodid, qty) ALWAYS;