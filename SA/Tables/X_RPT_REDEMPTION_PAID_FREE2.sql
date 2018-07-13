CREATE TABLE sa.x_rpt_redemption_paid_free2 (
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
  transaction_type VARCHAR2(20 BYTE)
);
ALTER TABLE sa.x_rpt_redemption_paid_free2 ADD SUPPLEMENTAL LOG GROUP dmtsora650536268_0 (call_trans_objid, description, part_number, part_objid, part_type, state_value, transaction_type, units, x_access, x_red_date, x_smp) ALWAYS;