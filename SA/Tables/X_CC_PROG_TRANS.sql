CREATE TABLE sa.x_cc_prog_trans (
  objid NUMBER(10) NOT NULL,
  x_ignore_bad_cv VARCHAR2(30 BYTE),
  x_ignore_avs VARCHAR2(30 BYTE),
  x_avs VARCHAR2(30 BYTE),
  x_disable_avs VARCHAR2(30 BYTE),
  x_auth_avs VARCHAR2(30 BYTE),
  x_auth_cv_result VARCHAR2(30 BYTE),
  x_score_factors VARCHAR2(30 BYTE),
  x_score_host_severity VARCHAR2(30 BYTE),
  x_score_rcode NUMBER,
  x_score_rflag VARCHAR2(30 BYTE),
  x_score_rmsg VARCHAR2(60 BYTE),
  x_score_result VARCHAR2(30 BYTE),
  x_score_time_local VARCHAR2(60 BYTE),
  x_customer_cc_number VARCHAR2(255 BYTE),
  x_customer_cc_expmo VARCHAR2(2 BYTE),
  x_customer_cc_expyr VARCHAR2(4 BYTE),
  x_customer_cvv_num VARCHAR2(20 BYTE),
  x_cc_lastfour VARCHAR2(4 BYTE),
  x_cc_trans2x_credit_card NUMBER(10),
  x_cc_trans2x_purch_hdr NUMBER(10)
);
ALTER TABLE sa.x_cc_prog_trans ADD SUPPLEMENTAL LOG GROUP dmtsora461697877_0 (objid, x_auth_avs, x_auth_cv_result, x_avs, x_cc_lastfour, x_cc_trans2x_credit_card, x_cc_trans2x_purch_hdr, x_customer_cc_expmo, x_customer_cc_expyr, x_customer_cc_number, x_customer_cvv_num, x_disable_avs, x_ignore_avs, x_ignore_bad_cv, x_score_factors, x_score_host_severity, x_score_rcode, x_score_result, x_score_rflag, x_score_rmsg, x_score_time_local) ALWAYS;
COMMENT ON TABLE sa.x_cc_prog_trans IS 'Billing Program Credit Card Transaction Detail';
COMMENT ON COLUMN sa.x_cc_prog_trans.objid IS 'Internal Record ID';
COMMENT ON COLUMN sa.x_cc_prog_trans.x_ignore_bad_cv IS 'Ignore Bad CV Flag';
COMMENT ON COLUMN sa.x_cc_prog_trans.x_ignore_avs IS 'Ignore AVS Flag';
COMMENT ON COLUMN sa.x_cc_prog_trans.x_avs IS 'AVS';
COMMENT ON COLUMN sa.x_cc_prog_trans.x_disable_avs IS 'Disable AVS Flag';
COMMENT ON COLUMN sa.x_cc_prog_trans.x_auth_avs IS 'Authorize AVS';
COMMENT ON COLUMN sa.x_cc_prog_trans.x_auth_cv_result IS 'Authorize CV Result';
COMMENT ON COLUMN sa.x_cc_prog_trans.x_score_factors IS 'Score Factors';
COMMENT ON COLUMN sa.x_cc_prog_trans.x_score_host_severity IS 'Score Host Severity';
COMMENT ON COLUMN sa.x_cc_prog_trans.x_score_rcode IS 'Score RCODE';
COMMENT ON COLUMN sa.x_cc_prog_trans.x_score_rflag IS 'Score RFLAG';
COMMENT ON COLUMN sa.x_cc_prog_trans.x_score_rmsg IS 'Score RMSG';
COMMENT ON COLUMN sa.x_cc_prog_trans.x_score_result IS 'Score Result';
COMMENT ON COLUMN sa.x_cc_prog_trans.x_score_time_local IS 'Score Local Time';
COMMENT ON COLUMN sa.x_cc_prog_trans.x_customer_cc_number IS 'Custome Credit Card Number';
COMMENT ON COLUMN sa.x_cc_prog_trans.x_customer_cc_expmo IS 'Customer Credit Card Expiration Month';
COMMENT ON COLUMN sa.x_cc_prog_trans.x_customer_cc_expyr IS 'Customer Credit Card Expiration Year';
COMMENT ON COLUMN sa.x_cc_prog_trans.x_customer_cvv_num IS 'Customer CVV Number';
COMMENT ON COLUMN sa.x_cc_prog_trans.x_cc_lastfour IS 'Credit Card Last 4 Digits';
COMMENT ON COLUMN sa.x_cc_prog_trans.x_cc_trans2x_credit_card IS 'Reference to objid in table_x_credit_card';
COMMENT ON COLUMN sa.x_cc_prog_trans.x_cc_trans2x_purch_hdr IS 'Reference to objid in table_x_program_purch_hdr';