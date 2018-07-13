CREATE TABLE sa.x_pending_redemption_det_npb (
  pend_red_det2pend_red NUMBER,
  pend_red2x_promotion NUMBER,
  x_pend_red2site_part NUMBER,
  x_pend_type VARCHAR2(20 BYTE),
  pend_redemption2esn NUMBER,
  x_case_id VARCHAR2(50 BYTE),
  x_granted_from2x_call_trans NUMBER,
  redeem_in2call_trans NUMBER,
  process_flag CHAR,
  process_date DATE,
  pend_red2prog_purch_hdr NUMBER
);