CREATE TABLE sa.x_program_purch_hdr (
  objid NUMBER,
  x_rqst_source VARCHAR2(20 BYTE),
  x_rqst_type VARCHAR2(20 BYTE),
  x_rqst_date DATE,
  x_ics_applications VARCHAR2(50 BYTE),
  x_merchant_id VARCHAR2(30 BYTE),
  x_merchant_ref_number VARCHAR2(30 BYTE),
  x_offer_num VARCHAR2(10 BYTE),
  x_quantity NUMBER,
  x_merchant_product_sku VARCHAR2(30 BYTE),
  x_payment_line2program NUMBER,
  x_product_code VARCHAR2(30 BYTE),
  x_ignore_avs VARCHAR2(10 BYTE),
  x_user_po VARCHAR2(30 BYTE),
  x_avs VARCHAR2(30 BYTE),
  x_disable_avs VARCHAR2(30 BYTE),
  x_customer_hostname VARCHAR2(60 BYTE),
  x_customer_ipaddress VARCHAR2(30 BYTE),
  x_auth_request_id VARCHAR2(30 BYTE),
  x_auth_code VARCHAR2(30 BYTE),
  x_auth_type VARCHAR2(30 BYTE),
  x_ics_rcode VARCHAR2(10 BYTE),
  x_ics_rflag VARCHAR2(30 BYTE),
  x_ics_rmsg VARCHAR2(255 BYTE),
  x_request_id VARCHAR2(30 BYTE),
  x_auth_avs VARCHAR2(30 BYTE),
  x_auth_response VARCHAR2(60 BYTE),
  x_auth_time VARCHAR2(20 BYTE),
  x_auth_rcode NUMBER,
  x_auth_rflag VARCHAR2(30 BYTE),
  x_auth_rmsg VARCHAR2(255 BYTE),
  x_bill_request_time VARCHAR2(20 BYTE),
  x_bill_rcode NUMBER,
  x_bill_rflag VARCHAR2(30 BYTE),
  x_bill_rmsg VARCHAR2(60 BYTE),
  x_bill_trans_ref_no VARCHAR2(30 BYTE),
  x_customer_firstname VARCHAR2(20 BYTE),
  x_customer_lastname VARCHAR2(20 BYTE),
  x_customer_phone VARCHAR2(20 BYTE),
  x_customer_email VARCHAR2(50 BYTE),
  x_status VARCHAR2(20 BYTE),
  x_bill_address1 VARCHAR2(200 BYTE),
  x_bill_address2 VARCHAR2(200 BYTE),
  x_bill_city VARCHAR2(30 BYTE),
  x_bill_state VARCHAR2(60 BYTE),
  x_bill_zip VARCHAR2(60 BYTE),
  x_bill_country VARCHAR2(20 BYTE),
  x_esn VARCHAR2(20 BYTE),
  x_amount NUMBER(19,2),
  x_tax_amount NUMBER,
  x_auth_amount NUMBER(19,2),
  x_bill_amount NUMBER(19,2),
  x_user VARCHAR2(20 BYTE),
  x_credit_code VARCHAR2(10 BYTE),
  purch_hdr2creditcard NUMBER,
  purch_hdr2bank_acct NUMBER,
  purch_hdr2user NUMBER,
  purch_hdr2esn NUMBER,
  purch_hdr2rmsg_codes NUMBER,
  purch_hdr2cr_purch NUMBER,
  prog_hdr2x_pymt_src NUMBER,
  prog_hdr2web_user NUMBER,
  prog_hdr2prog_batch NUMBER,
  x_payment_type VARCHAR2(30 BYTE),
  x_e911_tax_amount NUMBER DEFAULT 0,
  x_usf_taxamount NUMBER,
  x_rcrf_tax_amount NUMBER,
  x_process_date DATE,
  x_discount_amount NUMBER,
  x_priority NUMBER
);
ALTER TABLE sa.x_program_purch_hdr ADD SUPPLEMENTAL LOG GROUP dmtsora56169861_1 (prog_hdr2prog_batch, prog_hdr2web_user, prog_hdr2x_pymt_src, purch_hdr2bank_acct, purch_hdr2creditcard, purch_hdr2cr_purch, purch_hdr2esn, purch_hdr2rmsg_codes, purch_hdr2user, x_amount, x_auth_amount, x_bill_address1, x_bill_address2, x_bill_amount, x_bill_city, x_bill_country, x_bill_rflag, x_bill_rmsg, x_bill_state, x_bill_trans_ref_no, x_bill_zip, x_credit_code, x_customer_email, x_customer_firstname, x_customer_lastname, x_customer_phone, x_e911_tax_amount, x_esn, x_payment_type, x_status, x_tax_amount, x_user, x_usf_taxamount) ALWAYS;
ALTER TABLE sa.x_program_purch_hdr ADD SUPPLEMENTAL LOG GROUP dmtsora56169861_0 (objid, x_auth_avs, x_auth_code, x_auth_rcode, x_auth_request_id, x_auth_response, x_auth_rflag, x_auth_rmsg, x_auth_time, x_auth_type, x_avs, x_bill_rcode, x_bill_request_time, x_customer_hostname, x_customer_ipaddress, x_disable_avs, x_ics_applications, x_ics_rcode, x_ics_rflag, x_ics_rmsg, x_ignore_avs, x_merchant_id, x_merchant_product_sku, x_merchant_ref_number, x_offer_num, x_payment_line2program, x_product_code, x_quantity, x_request_id, x_rqst_date, x_rqst_source, x_rqst_type, x_user_po) ALWAYS;
ALTER TABLE sa.x_program_purch_hdr ADD SUPPLEMENTAL LOG GROUP dmtsora1564892679_1 (prog_hdr2prog_batch, prog_hdr2web_user, prog_hdr2x_pymt_src, purch_hdr2bank_acct, purch_hdr2creditcard, purch_hdr2cr_purch, purch_hdr2esn, purch_hdr2rmsg_codes, purch_hdr2user, x_amount, x_auth_amount, x_bill_address1, x_bill_address2, x_bill_amount, x_bill_city, x_bill_country, x_bill_rflag, x_bill_rmsg, x_bill_state, x_bill_trans_ref_no, x_bill_zip, x_credit_code, x_customer_email, x_customer_firstname, x_customer_lastname, x_customer_phone, x_e911_tax_amount, x_esn, x_payment_type, x_status, x_tax_amount, x_user) ALWAYS;
COMMENT ON TABLE sa.x_program_purch_hdr IS 'Billing Program Main Purchase Table, This table holds the information required to clear the CC charge.';
COMMENT ON COLUMN sa.x_program_purch_hdr.objid IS 'Internal Record ID';
COMMENT ON COLUMN sa.x_program_purch_hdr.x_rqst_source IS 'Application that originates the transaction';
COMMENT ON COLUMN sa.x_program_purch_hdr.x_rqst_type IS 'Transaction Type: CREDITCARD_PURCH, ACH_PURCH';
COMMENT ON COLUMN sa.x_program_purch_hdr.x_rqst_date IS 'Timestamp for transaction';
COMMENT ON COLUMN sa.x_program_purch_hdr.x_ics_applications IS 'Cyber Source Processes that are being requested, one or more comma separated: ics_auth, ics_bill,  ics_credit,ics_ecp_debit';
COMMENT ON COLUMN sa.x_program_purch_hdr.x_merchant_id IS 'Credit Card Merchant ID';
COMMENT ON COLUMN sa.x_program_purch_hdr.x_merchant_ref_number IS 'Transaction ID generated by CyberSource';
COMMENT ON COLUMN sa.x_program_purch_hdr.x_offer_num IS 'Not used, currently defaulting to: offer0';
COMMENT ON COLUMN sa.x_program_purch_hdr.x_quantity IS 'Number of items included in the purchase, currently defaulting to 1';
COMMENT ON COLUMN sa.x_program_purch_hdr.x_merchant_product_sku IS 'Not in use, SKU of the item sold, currently null';
COMMENT ON COLUMN sa.x_program_purch_hdr.x_payment_line2program IS 'not in use, null';
COMMENT ON COLUMN sa.x_program_purch_hdr.x_product_code IS 'not in use, null';
COMMENT ON COLUMN sa.x_program_purch_hdr.x_ignore_avs IS 'Flag to validate AVS: YES,NO';
COMMENT ON COLUMN sa.x_program_purch_hdr.x_user_po IS 'not in use, null';
COMMENT ON COLUMN sa.x_program_purch_hdr.x_avs IS 'CC AVS Code';
COMMENT ON COLUMN sa.x_program_purch_hdr.x_disable_avs IS 'Flag to disable AVS: True,False';
COMMENT ON COLUMN sa.x_program_purch_hdr.x_customer_hostname IS 'not in use, null';
COMMENT ON COLUMN sa.x_program_purch_hdr.x_customer_ipaddress IS 'not in use, null';
COMMENT ON COLUMN sa.x_program_purch_hdr.x_auth_request_id IS 'Authorization Request ID, Cybersource generated';
COMMENT ON COLUMN sa.x_program_purch_hdr.x_auth_code IS 'Authorization Code';
COMMENT ON COLUMN sa.x_program_purch_hdr.x_auth_type IS 'Authorization Type,  null';
COMMENT ON COLUMN sa.x_program_purch_hdr.x_ics_rcode IS 'ICS Response Code';
COMMENT ON COLUMN sa.x_program_purch_hdr.x_ics_rflag IS 'ICS Response Flag: SOK,DCARDREFUSED';
COMMENT ON COLUMN sa.x_program_purch_hdr.x_ics_rmsg IS 'ICS  Response Message';
COMMENT ON COLUMN sa.x_program_purch_hdr.x_request_id IS 'Request ID';
COMMENT ON COLUMN sa.x_program_purch_hdr.x_auth_avs IS 'AVS Authorization';
COMMENT ON COLUMN sa.x_program_purch_hdr.x_auth_response IS 'Authorization Response';
COMMENT ON COLUMN sa.x_program_purch_hdr.x_auth_time IS 'Authorization Timestamp';
COMMENT ON COLUMN sa.x_program_purch_hdr.x_auth_rcode IS 'Authorization Response Code';
COMMENT ON COLUMN sa.x_program_purch_hdr.x_auth_rflag IS 'Authorization Respose Flag';
COMMENT ON COLUMN sa.x_program_purch_hdr.x_auth_rmsg IS 'Authorization Response Message';
COMMENT ON COLUMN sa.x_program_purch_hdr.x_bill_request_time IS 'Billing Request Timestamp';
COMMENT ON COLUMN sa.x_program_purch_hdr.x_bill_rcode IS 'Billing Response Code';
COMMENT ON COLUMN sa.x_program_purch_hdr.x_bill_rflag IS 'Billing Response Flag';
COMMENT ON COLUMN sa.x_program_purch_hdr.x_bill_rmsg IS 'Billing Response Message';
COMMENT ON COLUMN sa.x_program_purch_hdr.x_bill_trans_ref_no IS 'Billing Transfer Reference Number';
COMMENT ON COLUMN sa.x_program_purch_hdr.x_customer_firstname IS 'Customer First Name';
COMMENT ON COLUMN sa.x_program_purch_hdr.x_customer_lastname IS 'Customer Last Name';
COMMENT ON COLUMN sa.x_program_purch_hdr.x_customer_phone IS 'Customer Phone Number';
COMMENT ON COLUMN sa.x_program_purch_hdr.x_customer_email IS 'Customer Email';
COMMENT ON COLUMN sa.x_program_purch_hdr.x_status IS 'Transaction Status: SUCCESS,ECPRETURNPROCESSED,SUCCESS';
COMMENT ON COLUMN sa.x_program_purch_hdr.x_bill_address1 IS 'Billing Address 1';
COMMENT ON COLUMN sa.x_program_purch_hdr.x_bill_address2 IS 'Billing Address 2';
COMMENT ON COLUMN sa.x_program_purch_hdr.x_bill_city IS 'Billing City';
COMMENT ON COLUMN sa.x_program_purch_hdr.x_bill_state IS 'Billing State';
COMMENT ON COLUMN sa.x_program_purch_hdr.x_bill_zip IS 'Billing Zip';
COMMENT ON COLUMN sa.x_program_purch_hdr.x_bill_country IS 'Billing Country';
COMMENT ON COLUMN sa.x_program_purch_hdr.x_esn IS 'Phone Serial Number';
COMMENT ON COLUMN sa.x_program_purch_hdr.x_amount IS 'Total Dollar Amount';
COMMENT ON COLUMN sa.x_program_purch_hdr.x_tax_amount IS 'TAX amount';
COMMENT ON COLUMN sa.x_program_purch_hdr.x_auth_amount IS 'Authorization Amount';
COMMENT ON COLUMN sa.x_program_purch_hdr.x_bill_amount IS 'Billing Amount';
COMMENT ON COLUMN sa.x_program_purch_hdr.x_user IS 'User Login';
COMMENT ON COLUMN sa.x_program_purch_hdr.x_credit_code IS 'Credit Score Received';
COMMENT ON COLUMN sa.x_program_purch_hdr.purch_hdr2creditcard IS 'Reference to table_x_credit__card';
COMMENT ON COLUMN sa.x_program_purch_hdr.purch_hdr2bank_acct IS 'Reference to table_x_bank_account';
COMMENT ON COLUMN sa.x_program_purch_hdr.purch_hdr2user IS 'Reference  to table_user';
COMMENT ON COLUMN sa.x_program_purch_hdr.purch_hdr2esn IS 'Reference to table_part_inst';
COMMENT ON COLUMN sa.x_program_purch_hdr.purch_hdr2rmsg_codes IS 'Reference to table_x_purch_codes';
COMMENT ON COLUMN sa.x_program_purch_hdr.purch_hdr2cr_purch IS 'Self Reference for Refund Transactions';
COMMENT ON COLUMN sa.x_program_purch_hdr.prog_hdr2x_pymt_src IS 'Reference to Payment Source';
COMMENT ON COLUMN sa.x_program_purch_hdr.prog_hdr2web_user IS 'Reference to table_web_user';
COMMENT ON COLUMN sa.x_program_purch_hdr.prog_hdr2prog_batch IS 'Reference to x_program_batch';
COMMENT ON COLUMN sa.x_program_purch_hdr.x_payment_type IS 'Payment Type: PAYNOW ENROLLMENT REFUND';
COMMENT ON COLUMN sa.x_program_purch_hdr.x_e911_tax_amount IS 'E911 Tax Amount';
COMMENT ON COLUMN sa.x_program_purch_hdr.x_usf_taxamount IS 'USF Tax Amount';
COMMENT ON COLUMN sa.x_program_purch_hdr.x_rcrf_tax_amount IS 'RCRF Tax Amount';
COMMENT ON COLUMN sa.x_program_purch_hdr.x_process_date IS 'Processing Timestamp';
COMMENT ON COLUMN sa.x_program_purch_hdr.x_discount_amount IS 'Discount amount';