CREATE TABLE sa.red2 (
  units NUMBER,
  x_access NUMBER,
  x_smp VARCHAR2(30 BYTE),
  call_trans_objid NUMBER,
  part_number VARCHAR2(30 BYTE),
  part_objid NUMBER,
  description VARCHAR2(255 BYTE),
  part_type VARCHAR2(20 BYTE),
  state_value VARCHAR2(20 BYTE),
  x_red_date DATE,
  transaction_type VARCHAR2(20 BYTE),
  v_promo_objid NUMBER,
  v_promo_code VARCHAR2(30 BYTE),
  v_promo_trans VARCHAR2(30 BYTE),
  ct_x_service_id VARCHAR2(30 BYTE),
  ct_x_min VARCHAR2(30 BYTE),
  ct_objid NUMBER,
  ct_x_sourcesystem VARCHAR2(30 BYTE),
  ct_x_call_trans2user NUMBER,
  ct_call_trans2site_part NUMBER,
  cd_x_code_name VARCHAR2(20 BYTE)
);
ALTER TABLE sa.red2 ADD SUPPLEMENTAL LOG GROUP dmtsora1298538752_0 (call_trans_objid, cd_x_code_name, ct_call_trans2site_part, ct_objid, ct_x_call_trans2user, ct_x_min, ct_x_service_id, ct_x_sourcesystem, description, part_number, part_objid, part_type, state_value, transaction_type, units, v_promo_code, v_promo_objid, v_promo_trans, x_access, x_red_date, x_smp) ALWAYS;