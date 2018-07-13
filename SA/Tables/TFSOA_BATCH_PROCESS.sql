CREATE TABLE sa.tfsoa_batch_process (
  objid NUMBER,
  prog_hdr2prog_batch NUMBER,
  x_rqst_type VARCHAR2(20 BYTE),
  x_rqst_date DATE,
  x_ics_applications VARCHAR2(50 BYTE),
  x_merchant_id VARCHAR2(30 BYTE),
  x_auth_request_id VARCHAR2(30 BYTE),
  x_merchant_ref_number VARCHAR2(30 BYTE),
  x_amount NUMBER(19,2),
  x_customer_firstname VARCHAR2(20 BYTE),
  x_customer_lastname VARCHAR2(20 BYTE),
  x_bill_address1 VARCHAR2(200 BYTE),
  x_bill_city VARCHAR2(30 BYTE),
  x_bill_state VARCHAR2(40 BYTE),
  x_bill_zip VARCHAR2(20 BYTE),
  x_bill_country VARCHAR2(20 BYTE),
  x_customer_email VARCHAR2(50 BYTE),
  x_status VARCHAR2(20 BYTE),
  x_amount_plus_tax NUMBER,
  x_bill_address2 VARCHAR2(200 BYTE),
  pph_x_ignore_avs VARCHAR2(10 BYTE),
  pph_x_avs VARCHAR2(30 BYTE),
  pph_x_disable_avs VARCHAR2(30 BYTE),
  x_customer_hostname VARCHAR2(60 BYTE),
  x_customer_ipaddress VARCHAR2(30 BYTE),
  x_tax_amount NUMBER(19,2),
  x_e911_tax_amount NUMBER(19,2),
  x_usf_taxamount NUMBER,
  x_rcrf_tax_amount NUMBER(19,4),
  x_auth_request_id_2 VARCHAR2(30 BYTE),
  x_customer_phone VARCHAR2(20 BYTE),
  x_ecp_account_no VARCHAR2(400 BYTE),
  x_ecp_account_type VARCHAR2(20 BYTE),
  x_ecp_rdfi VARCHAR2(30 BYTE),
  x_bank_num VARCHAR2(30 BYTE),
  x_ecp_settlement_method VARCHAR2(30 BYTE),
  x_decline_avs_flags VARCHAR2(255 BYTE),
  x_ecp_payment_mode VARCHAR2(30 BYTE),
  x_ecp_verfication_level VARCHAR2(30 BYTE),
  x_ecp_debit_ref_number VARCHAR2(70 BYTE),
  x_customer_cc_number VARCHAR2(255 BYTE),
  x_customer_cc_expmo VARCHAR2(2 BYTE),
  x_customer_cc_expyr VARCHAR2(4 BYTE),
  x_customer_cvv_num VARCHAR2(20 BYTE),
  x_ignore_bad_cv VARCHAR2(30 BYTE),
  ccpt_x_ignore_avs VARCHAR2(30 BYTE),
  ccpt_x_avs VARCHAR2(30 BYTE),
  ccpt_x_disable_avs VARCHAR2(30 BYTE),
  creditcard2cert NUMBER,
  cc_hash VARCHAR2(255 BYTE),
  x_cust_cc_num_key VARCHAR2(400 BYTE),
  x_cert VARCHAR2(64 BYTE),
  x_key_algo VARCHAR2(128 BYTE),
  x_cc_algo VARCHAR2(128 BYTE),
  x_cust_cc_num_enc VARCHAR2(400 BYTE),
  process_status VARCHAR2(30 BYTE) DEFAULT 'NEW',
  row_insert_date DATE DEFAULT SYSDATE,
  row_update_date DATE DEFAULT SYSDATE,
  prog_purch_hdr_objid NUMBER,
  x_total_tax_amount NUMBER,
  x_priority NUMBER
);
COMMENT ON TABLE sa.tfsoa_batch_process IS 'SOA Batch Process table';
COMMENT ON COLUMN sa.tfsoa_batch_process.objid IS 'Internal Record ID';
COMMENT ON COLUMN sa.tfsoa_batch_process.prog_hdr2prog_batch IS 'Reference to x_program_batch';
COMMENT ON COLUMN sa.tfsoa_batch_process.x_rqst_type IS 'Transaction Type: CREDITCARD_PURCH, ACH_PURCH';
COMMENT ON COLUMN sa.tfsoa_batch_process.x_rqst_date IS 'Timestamp for transaction';
COMMENT ON COLUMN sa.tfsoa_batch_process.x_ics_applications IS 'Cyber Source Processes that are being requested, one or more comma separated: ics_auth, ics_bill,  ics_credit,ics_ecp_debit';
COMMENT ON COLUMN sa.tfsoa_batch_process.x_merchant_id IS 'Credit Card Merchant ID';
COMMENT ON COLUMN sa.tfsoa_batch_process.x_auth_request_id IS 'Authorization Request ID, Cybersource generated';
COMMENT ON COLUMN sa.tfsoa_batch_process.x_merchant_ref_number IS 'Transaction ID generated by CyberSource';
COMMENT ON COLUMN sa.tfsoa_batch_process.x_amount IS 'Total Dollar Amount';
COMMENT ON COLUMN sa.tfsoa_batch_process.x_customer_firstname IS 'Customer First Name';
COMMENT ON COLUMN sa.tfsoa_batch_process.x_customer_lastname IS 'Customer Last Name';
COMMENT ON COLUMN sa.tfsoa_batch_process.x_bill_address1 IS 'Billing Address 1';
COMMENT ON COLUMN sa.tfsoa_batch_process.x_bill_city IS 'Billing City';
COMMENT ON COLUMN sa.tfsoa_batch_process.x_bill_state IS 'Billing State';
COMMENT ON COLUMN sa.tfsoa_batch_process.x_bill_zip IS 'Billing Zip';
COMMENT ON COLUMN sa.tfsoa_batch_process.x_bill_country IS 'Billing Country';
COMMENT ON COLUMN sa.tfsoa_batch_process.x_customer_email IS 'Customer Email';
COMMENT ON COLUMN sa.tfsoa_batch_process.x_status IS 'Transaction Status: SUCCESS, ECPRETURNPROCESSED, SUCCESS';
COMMENT ON COLUMN sa.tfsoa_batch_process.x_amount_plus_tax IS 'x_amount+total tax amount';
COMMENT ON COLUMN sa.tfsoa_batch_process.x_bill_address2 IS 'Billing Address 2';
COMMENT ON COLUMN sa.tfsoa_batch_process.pph_x_ignore_avs IS 'Program Purchase Header falg to ingnore AVS';
COMMENT ON COLUMN sa.tfsoa_batch_process.pph_x_avs IS 'Program Purchase Header AVS code';
COMMENT ON COLUMN sa.tfsoa_batch_process.pph_x_disable_avs IS 'Program Purchase Header flag to disable AVS';
COMMENT ON COLUMN sa.tfsoa_batch_process.x_customer_hostname IS 'not in use, null';
COMMENT ON COLUMN sa.tfsoa_batch_process.x_customer_ipaddress IS 'not in use, null';
COMMENT ON COLUMN sa.tfsoa_batch_process.x_tax_amount IS 'TAX amount';
COMMENT ON COLUMN sa.tfsoa_batch_process.x_e911_tax_amount IS 'E911 Tax Amount';
COMMENT ON COLUMN sa.tfsoa_batch_process.x_usf_taxamount IS 'USF Tax Amount';
COMMENT ON COLUMN sa.tfsoa_batch_process.x_rcrf_tax_amount IS 'RCRF Tax Amount';
COMMENT ON COLUMN sa.tfsoa_batch_process.x_auth_request_id_2 IS 'Authorization Request Id 2';
COMMENT ON COLUMN sa.tfsoa_batch_process.x_customer_phone IS 'Customer Phone Number';
COMMENT ON COLUMN sa.tfsoa_batch_process.x_ecp_account_no IS 'ACH Program Transaction Acount Number';
COMMENT ON COLUMN sa.tfsoa_batch_process.x_ecp_account_type IS 'ACH Program Transaction Account Type';
COMMENT ON COLUMN sa.tfsoa_batch_process.x_ecp_rdfi IS 'ACH Program Transaction RDFI';
COMMENT ON COLUMN sa.tfsoa_batch_process.x_bank_num IS 'Bank Account Number';
COMMENT ON COLUMN sa.tfsoa_batch_process.x_ecp_settlement_method IS 'ACH Program Transaction Settlement Method';
COMMENT ON COLUMN sa.tfsoa_batch_process.x_decline_avs_flags IS 'ACH Program Transaction flag to decline AVS';
COMMENT ON COLUMN sa.tfsoa_batch_process.x_ecp_payment_mode IS 'ACH Program Transaction payment mode';
COMMENT ON COLUMN sa.tfsoa_batch_process.x_ecp_verfication_level IS 'ACH Program Transaction Verification Level';
COMMENT ON COLUMN sa.tfsoa_batch_process.x_ecp_debit_ref_number IS 'Ref number for ACH Program Transaction Debit account';
COMMENT ON COLUMN sa.tfsoa_batch_process.x_customer_cc_number IS 'Encrypted Credit Card Number';
COMMENT ON COLUMN sa.tfsoa_batch_process.x_customer_cc_expmo IS 'Credit card expiration month';
COMMENT ON COLUMN sa.tfsoa_batch_process.x_customer_cc_expyr IS 'Credit card expiration year';
COMMENT ON COLUMN sa.tfsoa_batch_process.x_customer_cvv_num IS 'CVV number for Credit Card';
COMMENT ON COLUMN sa.tfsoa_batch_process.x_ignore_bad_cv IS 'CC Program Transaction falg to ingnore CV';
COMMENT ON COLUMN sa.tfsoa_batch_process.ccpt_x_ignore_avs IS 'CC Program Transaction falg to ingnore AVS';
COMMENT ON COLUMN sa.tfsoa_batch_process.ccpt_x_avs IS 'CC Program Transaction AVS code';
COMMENT ON COLUMN sa.tfsoa_batch_process.ccpt_x_disable_avs IS 'CC Program Transaction flag to disable AVS';
COMMENT ON COLUMN sa.tfsoa_batch_process.creditcard2cert IS 'Reference to objid of table x_cert';
COMMENT ON COLUMN sa.tfsoa_batch_process.cc_hash IS 'Hash Value for Credit Card';
COMMENT ON COLUMN sa.tfsoa_batch_process.x_cust_cc_num_key IS 'Credit Card Number Public Key';
COMMENT ON COLUMN sa.tfsoa_batch_process.x_cert IS 'Certicate info';
COMMENT ON COLUMN sa.tfsoa_batch_process.x_key_algo IS 'Certificate KEY ALGO';
COMMENT ON COLUMN sa.tfsoa_batch_process.x_cc_algo IS 'Certificate Credit Card ALGO';
COMMENT ON COLUMN sa.tfsoa_batch_process.x_cust_cc_num_enc IS 'Credit Card Encrypted Value';
COMMENT ON COLUMN sa.tfsoa_batch_process.process_status IS 'Status of this process';
COMMENT ON COLUMN sa.tfsoa_batch_process.row_insert_date IS 'Insert date';
COMMENT ON COLUMN sa.tfsoa_batch_process.row_update_date IS 'Update date';
COMMENT ON COLUMN sa.tfsoa_batch_process.prog_purch_hdr_objid IS 'Reference to objid of table X_PROGRAM_PURCH_HDR';
COMMENT ON COLUMN sa.tfsoa_batch_process.x_total_tax_amount IS 'Total Tax Amount';