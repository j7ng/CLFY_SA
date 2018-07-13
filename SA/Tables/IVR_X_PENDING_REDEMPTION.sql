CREATE TABLE sa.ivr_x_pending_redemption (
  channel VARCHAR2(100 BYTE),
  objid NUMBER,
  pend_red2x_promotion NUMBER,
  x_pend_red2site_part NUMBER,
  x_pend_type VARCHAR2(20 BYTE),
  promo_hist_objid NUMBER
);
ALTER TABLE sa.ivr_x_pending_redemption ADD SUPPLEMENTAL LOG GROUP dmtsora3140937_0 (channel, objid, pend_red2x_promotion, promo_hist_objid, x_pend_red2site_part, x_pend_type) ALWAYS;