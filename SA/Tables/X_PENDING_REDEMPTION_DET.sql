CREATE TABLE sa.x_pending_redemption_det (
  pend_red_det2pend_red NUMBER,
  pend_red2x_promotion NUMBER,
  x_pend_red2site_part NUMBER,
  x_pend_type VARCHAR2(20 BYTE),
  pend_redemption2esn NUMBER,
  x_case_id VARCHAR2(50 BYTE),
  x_granted_from2x_call_trans NUMBER,
  redeem_in2call_trans NUMBER,
  process_flag CHAR CONSTRAINT process_flag_chk CHECK (process_flag in('I','D','U')),
  process_date DATE DEFAULT sysdate,
  pend_red2prog_purch_hdr NUMBER
);
ALTER TABLE sa.x_pending_redemption_det ADD SUPPLEMENTAL LOG GROUP dmtsora48502813_0 (pend_red2prog_purch_hdr, pend_red2x_promotion, pend_redemption2esn, pend_red_det2pend_red, process_date, process_flag, redeem_in2call_trans, x_case_id, x_granted_from2x_call_trans, x_pend_red2site_part, x_pend_type) ALWAYS;
COMMENT ON TABLE sa.x_pending_redemption_det IS 'Transaction log for pending redemptions.  It tracks the creation and processing of records in the table_x_pending_redemptions.';
COMMENT ON COLUMN sa.x_pending_redemption_det.pend_red_det2pend_red IS 'Reference objid of table_x_pending_redemption';
COMMENT ON COLUMN sa.x_pending_redemption_det.pend_red2x_promotion IS 'References the objid for table_x_promotion';
COMMENT ON COLUMN sa.x_pending_redemption_det.x_pend_red2site_part IS 'References the objid for table_site_part';
COMMENT ON COLUMN sa.x_pending_redemption_det.x_pend_type IS 'Type of Pending Redemption Transaction';
COMMENT ON COLUMN sa.x_pending_redemption_det.pend_redemption2esn IS 'Reference the objid from table_part_inst that corresponds to the phone.';
COMMENT ON COLUMN sa.x_pending_redemption_det.x_case_id IS 'References id_number from table_case, in case a case was used to create the pending transaction.';
COMMENT ON COLUMN sa.x_pending_redemption_det.x_granted_from2x_call_trans IS 'Reference the objid from table_x_call_trans that that was used to create the record in the table_x_pending_redemption.';
COMMENT ON COLUMN sa.x_pending_redemption_det.redeem_in2call_trans IS 'Reference the objid from table_x_call_trans that that was used to redeem the benefits iin the table_x_pending_redemption.';
COMMENT ON COLUMN sa.x_pending_redemption_det.process_flag IS 'Process Type: I=Inserted, D=Deleted';
COMMENT ON COLUMN sa.x_pending_redemption_det.process_date IS 'Date record was created';
COMMENT ON COLUMN sa.x_pending_redemption_det.pend_red2prog_purch_hdr IS 'Reference to objid of x_program_purch_hdr';