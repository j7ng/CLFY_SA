CREATE TABLE sa.x_payment_log (
  x_response_xml CLOB,
  merchant_ref_number VARCHAR2(4000 BYTE),
  request_id VARCHAR2(4000 BYTE),
  ics_rflag VARCHAR2(4000 BYTE),
  ics_rcode VARCHAR2(4000 BYTE),
  auth_rcode VARCHAR2(4000 BYTE),
  auth_amount VARCHAR2(4000 BYTE),
  auth_code VARCHAR2(4000 BYTE),
  auth_id VARCHAR2(4000 BYTE),
  pmt_network_trans_id VARCHAR2(4000 BYTE),
  bill_rcode VARCHAR2(4000 BYTE),
  bill_amount VARCHAR2(4000 BYTE),
  bill_trans_ref_no VARCHAR2(4000 BYTE),
  ach_debit_rcode VARCHAR2(4000 BYTE),
  ach_debit_amount VARCHAR2(4000 BYTE),
  ach_debit_trans_ref_no VARCHAR2(4000 BYTE),
  afs_rcode VARCHAR2(4000 BYTE),
  afs_address_info_code VARCHAR2(4000 BYTE),
  afs_suspicious_info_code VARCHAR2(4000 BYTE),
  bin_country VARCHAR2(4000 BYTE),
  card_type VARCHAR2(4000 BYTE),
  card_scheme VARCHAR2(4000 BYTE),
  card_issuer VARCHAR2(4000 BYTE),
  faultcode VARCHAR2(4000 BYTE),
  faultstring VARCHAR2(4000 BYTE),
  x_process_status VARCHAR2(30 BYTE),
  insert_date DATE,
  last_update_date DATE
);
COMMENT ON COLUMN sa.x_payment_log.merchant_ref_number IS 'Merchant Reference Number.';
COMMENT ON COLUMN sa.x_payment_log.request_id IS 'Request ID.';
COMMENT ON COLUMN sa.x_payment_log.ics_rflag IS 'ICS RFLAG.';
COMMENT ON COLUMN sa.x_payment_log.ics_rcode IS 'ICS RCODE.';
COMMENT ON COLUMN sa.x_payment_log.auth_rcode IS 'Authentication RCODE.';
COMMENT ON COLUMN sa.x_payment_log.auth_amount IS 'Authentication Amount.';
COMMENT ON COLUMN sa.x_payment_log.auth_id IS 'Authentication ID.';
COMMENT ON COLUMN sa.x_payment_log.pmt_network_trans_id IS 'Payment Network Trans ID.';
COMMENT ON COLUMN sa.x_payment_log.bill_rcode IS 'Bill RCODE.';
COMMENT ON COLUMN sa.x_payment_log.bill_amount IS 'Bill Amount.';
COMMENT ON COLUMN sa.x_payment_log.bill_trans_ref_no IS 'Bill Trans Ref Number.';
COMMENT ON COLUMN sa.x_payment_log.ach_debit_rcode IS 'ACH Debit RCODE.';
COMMENT ON COLUMN sa.x_payment_log.ach_debit_amount IS 'ACH Debit Amount.';
COMMENT ON COLUMN sa.x_payment_log.ach_debit_trans_ref_no IS 'ACH Trans Reference Number.';
COMMENT ON COLUMN sa.x_payment_log.afs_rcode IS 'AFS RCODE.';
COMMENT ON COLUMN sa.x_payment_log.afs_address_info_code IS 'AFS Address Info Code.';
COMMENT ON COLUMN sa.x_payment_log.afs_suspicious_info_code IS 'AFS Suspecious Info Code.';
COMMENT ON COLUMN sa.x_payment_log.bin_country IS 'Country.';
COMMENT ON COLUMN sa.x_payment_log.card_type IS 'Card Type.';
COMMENT ON COLUMN sa.x_payment_log.card_scheme IS 'Card Scheme.';
COMMENT ON COLUMN sa.x_payment_log.card_issuer IS 'Card Issuer.';