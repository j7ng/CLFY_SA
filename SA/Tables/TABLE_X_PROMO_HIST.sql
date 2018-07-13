CREATE TABLE sa.table_x_promo_hist (
  objid NUMBER,
  promo_hist2x_call_trans NUMBER,
  promo_hist2x_promotion NUMBER,
  granted_from2x_call_trans NUMBER,
  update_stamp DATE
);
ALTER TABLE sa.table_x_promo_hist ADD SUPPLEMENTAL LOG GROUP dmtsora920395448_0 (granted_from2x_call_trans, objid, promo_hist2x_call_trans, promo_hist2x_promotion) ALWAYS;
COMMENT ON TABLE sa.table_x_promo_hist IS 'Stores carrier account history information';
COMMENT ON COLUMN sa.table_x_promo_hist.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_x_promo_hist.promo_hist2x_call_trans IS 'History of redeemed promotions by service';
COMMENT ON COLUMN sa.table_x_promo_hist.promo_hist2x_promotion IS 'History of redeemed promotions by code';
COMMENT ON COLUMN sa.table_x_promo_hist.granted_from2x_call_trans IS 'Pending';
COMMENT ON COLUMN sa.table_x_promo_hist.update_stamp IS 'UPDATE TIME';