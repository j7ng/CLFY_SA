CREATE TABLE sa.x_trac_kmart_cross_ref (
  trac_item_num VARCHAR2(30 BYTE),
  kmart_item_num VARCHAR2(30 BYTE),
  card_desc VARCHAR2(100 BYTE),
  trac_sell_price NUMBER,
  kmart_sell_price NUMBER
);
ALTER TABLE sa.x_trac_kmart_cross_ref ADD SUPPLEMENTAL LOG GROUP dmtsora1697837066_0 (card_desc, kmart_item_num, kmart_sell_price, trac_item_num, trac_sell_price) ALWAYS;