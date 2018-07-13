CREATE TABLE sa.table_x_pending_redemption (
  objid NUMBER,
  pend_red2x_promotion NUMBER,
  x_pend_red2site_part NUMBER,
  x_pend_type VARCHAR2(20 BYTE),
  pend_redemption2esn NUMBER,
  x_case_id VARCHAR2(50 BYTE),
  x_granted_from2x_call_trans NUMBER,
  redeem_in2call_trans NUMBER,
  pend_red2prog_purch_hdr NUMBER
);
ALTER TABLE sa.table_x_pending_redemption ADD SUPPLEMENTAL LOG GROUP dmtsora286698784_0 (objid, pend_red2prog_purch_hdr, pend_red2x_promotion, pend_redemption2esn, redeem_in2call_trans, x_case_id, x_granted_from2x_call_trans, x_pend_red2site_part, x_pend_type) ALWAYS;
COMMENT ON TABLE sa.table_x_pending_redemption IS 'Contains batch promotions that have been given to customers and whose redemption is pending';
COMMENT ON COLUMN sa.table_x_pending_redemption.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_x_pending_redemption.pend_red2x_promotion IS 'Pending redemptions for a given promotion code';
COMMENT ON COLUMN sa.table_x_pending_redemption.x_pend_red2site_part IS 'Pending Redemption for a Site Part';
COMMENT ON COLUMN sa.table_x_pending_redemption.x_pend_type IS 'Type of pending redemption, e.g. Service Units or Batch';
COMMENT ON COLUMN sa.table_x_pending_redemption.pend_redemption2esn IS 'Pending redemptions for a given Inactive ESN';
COMMENT ON COLUMN sa.table_x_pending_redemption.x_case_id IS 'case id associated to the creation of the record (optional)';
COMMENT ON COLUMN sa.table_x_pending_redemption.x_granted_from2x_call_trans IS 'Pending';
COMMENT ON COLUMN sa.table_x_pending_redemption.redeem_in2call_trans IS 'TBD';