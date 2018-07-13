CREATE TABLE sa.table_x_discount_hist (
  objid NUMBER,
  x_discount_amount NUMBER(10,2),
  x_esn VARCHAR2(30 BYTE),
  x_disc_hist2x_promo NUMBER,
  x_disc_hist2x_purch_hdr NUMBER
);
ALTER TABLE sa.table_x_discount_hist ADD SUPPLEMENTAL LOG GROUP dmtsora6593925_0 (objid, x_discount_amount, x_disc_hist2x_promo, x_disc_hist2x_purch_hdr, x_esn) ALWAYS;