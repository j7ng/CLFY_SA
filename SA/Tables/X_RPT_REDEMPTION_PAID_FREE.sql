CREATE TABLE sa.x_rpt_redemption_paid_free (
  units NUMBER,
  x_access NUMBER,
  x_smp VARCHAR2(30 BYTE),
  call_trans_objid NUMBER,
  part_number VARCHAR2(30 BYTE),
  part_objid NUMBER,
  description VARCHAR2(255 BYTE),
  part_type VARCHAR2(20 BYTE)
);
ALTER TABLE sa.x_rpt_redemption_paid_free ADD SUPPLEMENTAL LOG GROUP dmtsora1101460650_0 (call_trans_objid, description, part_number, part_objid, part_type, units, x_access, x_smp) ALWAYS;