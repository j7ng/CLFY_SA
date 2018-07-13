CREATE TABLE sa.red2_2 (
  units NUMBER,
  x_access NUMBER,
  call_trans_objid NUMBER,
  promotion_objid NUMBER,
  "ACTION" VARCHAR2(20 BYTE),
  promo_type VARCHAR2(30 BYTE),
  promo_code VARCHAR2(10 BYTE),
  x_revenue_type VARCHAR2(20 BYTE),
  transaction_type VARCHAR2(20 BYTE),
  ct_x_service_id VARCHAR2(30 BYTE),
  ct_x_min VARCHAR2(30 BYTE),
  ct_x_transact_date DATE,
  ct_objid NUMBER,
  ct_x_sourcesystem VARCHAR2(30 BYTE),
  ct_x_call_trans2user NUMBER,
  ct_call_trans2site_part NUMBER,
  cd_x_code_name VARCHAR2(20 BYTE)
);
ALTER TABLE sa.red2_2 ADD SUPPLEMENTAL LOG GROUP dmtsora1558443420_0 ("ACTION", call_trans_objid, cd_x_code_name, ct_call_trans2site_part, ct_objid, ct_x_call_trans2user, ct_x_min, ct_x_service_id, ct_x_sourcesystem, ct_x_transact_date, promotion_objid, promo_code, promo_type, transaction_type, units, x_access, x_revenue_type) ALWAYS;