CREATE TABLE sa.x_ach_prog_trans (
  objid NUMBER(10) NOT NULL,
  x_bank_num VARCHAR2(30 BYTE),
  x_ecp_account_no VARCHAR2(400 BYTE) NOT NULL,
  x_ecp_account_type VARCHAR2(20 BYTE),
  x_ecp_rdfi VARCHAR2(400 BYTE),
  x_ecp_settlement_method VARCHAR2(30 BYTE),
  x_ecp_payment_mode VARCHAR2(30 BYTE),
  x_ecp_debit_request_id VARCHAR2(30 BYTE),
  x_ecp_verfication_level VARCHAR2(30 BYTE),
  x_ecp_ref_number VARCHAR2(70 BYTE),
  x_ecp_debit_ref_number VARCHAR2(70 BYTE),
  x_ecp_debit_avs VARCHAR2(1 BYTE),
  x_ecp_debit_avs_raw VARCHAR2(2 BYTE),
  x_ecp_rcode VARCHAR2(5 BYTE),
  x_ecp_trans_id VARCHAR2(30 BYTE),
  x_ecp_ref_no VARCHAR2(30 BYTE),
  x_ecp_result_code VARCHAR2(10 BYTE),
  x_ecp_rflag VARCHAR2(30 BYTE),
  x_ecp_rmsg VARCHAR2(255 BYTE),
  x_ecp_credit_ref_number VARCHAR2(70 BYTE),
  x_ecp_credit_trans_id VARCHAR2(100 BYTE),
  x_decline_avs_flags VARCHAR2(255 BYTE),
  ach_trans2x_purch_hdr NUMBER,
  ach_trans2x_bank_account NUMBER,
  ach_trans2pgm_enrolled NUMBER
);
ALTER TABLE sa.x_ach_prog_trans ADD SUPPLEMENTAL LOG GROUP dmtsora1531630210_0 (ach_trans2pgm_enrolled, ach_trans2x_bank_account, ach_trans2x_purch_hdr, objid, x_bank_num, x_decline_avs_flags, x_ecp_account_no, x_ecp_account_type, x_ecp_credit_ref_number, x_ecp_credit_trans_id, x_ecp_debit_avs, x_ecp_debit_avs_raw, x_ecp_debit_ref_number, x_ecp_debit_request_id, x_ecp_payment_mode, x_ecp_rcode, x_ecp_rdfi, x_ecp_ref_no, x_ecp_ref_number, x_ecp_result_code, x_ecp_rflag, x_ecp_rmsg, x_ecp_settlement_method, x_ecp_trans_id, x_ecp_verfication_level) ALWAYS;
COMMENT ON TABLE sa.x_ach_prog_trans IS 'Billing Program ACH Transaction Detail';
COMMENT ON COLUMN sa.x_ach_prog_trans.objid IS 'Internal Record ID';
COMMENT ON COLUMN sa.x_ach_prog_trans.x_bank_num IS 'Bank Number';
COMMENT ON COLUMN sa.x_ach_prog_trans.x_ecp_account_no IS 'ECP Account Number';
COMMENT ON COLUMN sa.x_ach_prog_trans.x_ecp_account_type IS 'ECP Account Type';
COMMENT ON COLUMN sa.x_ach_prog_trans.x_ecp_rdfi IS 'ECP RDFI';
COMMENT ON COLUMN sa.x_ach_prog_trans.x_ecp_settlement_method IS 'ECP Settlement Method';
COMMENT ON COLUMN sa.x_ach_prog_trans.x_ecp_payment_mode IS 'ECP Payment Mode';
COMMENT ON COLUMN sa.x_ach_prog_trans.x_ecp_debit_request_id IS 'ECP Debit Request ID';
COMMENT ON COLUMN sa.x_ach_prog_trans.x_ecp_verfication_level IS 'ECP Verification Level';
COMMENT ON COLUMN sa.x_ach_prog_trans.x_ecp_ref_number IS 'ECP Reference Number';
COMMENT ON COLUMN sa.x_ach_prog_trans.x_ecp_debit_ref_number IS 'ECP Debit Reference Number';
COMMENT ON COLUMN sa.x_ach_prog_trans.x_ecp_debit_avs IS 'ECP Debit AVS';
COMMENT ON COLUMN sa.x_ach_prog_trans.x_ecp_debit_avs_raw IS 'ECP Debit AVS Raw';
COMMENT ON COLUMN sa.x_ach_prog_trans.x_ecp_rcode IS 'ECP RCODE';
COMMENT ON COLUMN sa.x_ach_prog_trans.x_ecp_trans_id IS 'ECP Transaction ID';
COMMENT ON COLUMN sa.x_ach_prog_trans.x_ecp_ref_no IS 'ECP Reference Number';
COMMENT ON COLUMN sa.x_ach_prog_trans.x_ecp_result_code IS 'ECP Result Code';
COMMENT ON COLUMN sa.x_ach_prog_trans.x_ecp_rflag IS 'ECP RFLAG';
COMMENT ON COLUMN sa.x_ach_prog_trans.x_ecp_rmsg IS 'ECP RMSG';
COMMENT ON COLUMN sa.x_ach_prog_trans.x_ecp_credit_ref_number IS 'ECP Credit Reference Number';
COMMENT ON COLUMN sa.x_ach_prog_trans.x_ecp_credit_trans_id IS 'ECP Credit Transaction ID';
COMMENT ON COLUMN sa.x_ach_prog_trans.x_decline_avs_flags IS 'Decline AVS Flag';
COMMENT ON COLUMN sa.x_ach_prog_trans.ach_trans2x_purch_hdr IS 'Reference to objid in  x_program_puch_hdr';
COMMENT ON COLUMN sa.x_ach_prog_trans.ach_trans2x_bank_account IS 'Reference to objid in table_x_bank_account';
COMMENT ON COLUMN sa.x_ach_prog_trans.ach_trans2pgm_enrolled IS 'Reference to objid in x_program_enrolled';