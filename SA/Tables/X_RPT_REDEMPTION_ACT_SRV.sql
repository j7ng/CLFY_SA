CREATE TABLE sa.x_rpt_redemption_act_srv (
  units NUMBER,
  x_access NUMBER,
  call_trans_objid NUMBER,
  promotion_objid NUMBER,
  "ACTION" VARCHAR2(20 BYTE),
  promo_type VARCHAR2(30 BYTE),
  promo_code VARCHAR2(10 BYTE)
);
ALTER TABLE sa.x_rpt_redemption_act_srv ADD SUPPLEMENTAL LOG GROUP dmtsora1012939048_0 ("ACTION", call_trans_objid, promotion_objid, promo_code, promo_type, units, x_access) ALWAYS;