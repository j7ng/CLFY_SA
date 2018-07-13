CREATE TABLE sa.table_x_purch_hdr (
  objid NUMBER,
  x_rqst_source VARCHAR2(20 BYTE),
  x_rqst_type VARCHAR2(20 BYTE),
  x_rqst_date DATE,
  x_ics_applications VARCHAR2(30 BYTE),
  x_merchant_id VARCHAR2(30 BYTE),
  x_merchant_ref_number VARCHAR2(30 BYTE),
  x_offer_num VARCHAR2(10 BYTE),
  x_quantity NUMBER,
  x_merchant_product_sku VARCHAR2(30 BYTE),
  x_product_name VARCHAR2(30 BYTE),
  x_product_code VARCHAR2(30 BYTE),
  x_ignore_bad_cv VARCHAR2(10 BYTE),
  x_ignore_avs VARCHAR2(10 BYTE),
  x_user_po VARCHAR2(30 BYTE),
  x_avs VARCHAR2(30 BYTE),
  x_disable_avs VARCHAR2(30 BYTE),
  x_customer_hostname VARCHAR2(60 BYTE),
  x_customer_ipaddress VARCHAR2(30 BYTE),
  x_auth_request_id VARCHAR2(30 BYTE),
  x_auth_code VARCHAR2(30 BYTE),
  x_auth_type VARCHAR2(30 BYTE),
  x_ics_rcode NUMBER,
  x_ics_rflag VARCHAR2(30 BYTE),
  x_ics_rmsg VARCHAR2(255 BYTE),
  x_request_id VARCHAR2(30 BYTE),
  x_auth_avs VARCHAR2(30 BYTE),
  x_auth_response VARCHAR2(60 BYTE),
  x_auth_time VARCHAR2(20 BYTE),
  x_auth_rcode NUMBER,
  x_auth_rflag VARCHAR2(30 BYTE),
  x_auth_rmsg VARCHAR2(60 BYTE),
  x_auth_cv_result VARCHAR2(20 BYTE),
  x_score_factors VARCHAR2(20 BYTE),
  x_score_host_severity VARCHAR2(20 BYTE),
  x_score_rcode NUMBER,
  x_score_rflag VARCHAR2(30 BYTE),
  x_score_rmsg VARCHAR2(100 BYTE),
  x_score_result NUMBER,
  x_score_time_local VARCHAR2(20 BYTE),
  x_bill_request_time VARCHAR2(20 BYTE),
  x_bill_rcode NUMBER,
  x_bill_rflag VARCHAR2(30 BYTE),
  x_bill_rmsg VARCHAR2(60 BYTE),
  x_bill_trans_ref_no VARCHAR2(30 BYTE),
  x_customer_cc_number VARCHAR2(255 BYTE),
  x_customer_cc_expmo VARCHAR2(2 BYTE),
  x_customer_cc_expyr VARCHAR2(4 BYTE),
  x_customer_cc_cv_number VARCHAR2(20 BYTE),
  x_customer_firstname VARCHAR2(20 BYTE),
  x_customer_lastname VARCHAR2(20 BYTE),
  x_customer_phone VARCHAR2(20 BYTE),
  x_customer_email VARCHAR2(50 BYTE),
  x_bank_num VARCHAR2(30 BYTE),
  x_customer_acct VARCHAR2(30 BYTE),
  x_routing VARCHAR2(20 BYTE),
  x_aba_transit VARCHAR2(30 BYTE),
  x_bank_name VARCHAR2(20 BYTE),
  x_status VARCHAR2(10 BYTE),
  x_bill_address1 VARCHAR2(200 BYTE),
  x_bill_address2 VARCHAR2(200 BYTE),
  x_bill_city VARCHAR2(30 BYTE),
  x_bill_state VARCHAR2(40 BYTE),
  x_bill_zip VARCHAR2(20 BYTE),
  x_bill_country VARCHAR2(20 BYTE),
  x_esn VARCHAR2(20 BYTE),
  x_cc_lastfour VARCHAR2(4 BYTE),
  x_amount NUMBER(19,2),
  x_tax_amount NUMBER(19,2),
  x_auth_amount NUMBER(19,2),
  x_bill_amount NUMBER(19,2),
  x_user VARCHAR2(20 BYTE),
  x_purch_hdr2creditcard NUMBER,
  x_purch_hdr2bank_acct NUMBER,
  x_purch_hdr2contact NUMBER,
  x_purch_hdr2user NUMBER,
  x_purch_hdr2esn NUMBER,
  x_purch_hdr2x_rmsg_codes NUMBER,
  x_purch_hdr2cr_purch NUMBER,
  x_credit_code VARCHAR2(10 BYTE),
  x_credit_reason VARCHAR2(30 BYTE),
  x_e911_amount NUMBER,
  x_shipping_cost NUMBER(19,4),
  x_usf_taxamount NUMBER,
  x_rcrf_tax_amount NUMBER,
  x_discount_amount NUMBER,
  x_total_tax NUMBER
);
ALTER TABLE sa.table_x_purch_hdr ADD SUPPLEMENTAL LOG GROUP dmtsora1304322676_2 (x_amount, x_auth_amount, x_bill_amount, x_cc_lastfour, x_credit_code, x_credit_reason, x_e911_amount, x_purch_hdr2bank_acct, x_purch_hdr2contact, x_purch_hdr2creditcard, x_purch_hdr2cr_purch, x_purch_hdr2esn, x_purch_hdr2user, x_purch_hdr2x_rmsg_codes, x_tax_amount, x_user) ALWAYS;
ALTER TABLE sa.table_x_purch_hdr ADD SUPPLEMENTAL LOG GROUP dmtsora1304322676_1 (x_aba_transit, x_bank_name, x_bank_num, x_bill_address1, x_bill_address2, x_bill_city, x_bill_country, x_bill_rcode, x_bill_request_time, x_bill_rflag, x_bill_rmsg, x_bill_state, x_bill_trans_ref_no, x_bill_zip, x_customer_acct, x_customer_cc_cv_number, x_customer_cc_expmo, x_customer_cc_expyr, x_customer_cc_number, x_customer_email, x_customer_firstname, x_customer_lastname, x_customer_phone, x_esn, x_routing, x_score_factors, x_score_host_severity, x_score_rcode, x_score_result, x_score_rflag, x_score_rmsg, x_score_time_local, x_status) ALWAYS;
ALTER TABLE sa.table_x_purch_hdr ADD SUPPLEMENTAL LOG GROUP dmtsora1304322676_0 (objid, x_auth_avs, x_auth_code, x_auth_cv_result, x_auth_rcode, x_auth_request_id, x_auth_response, x_auth_rflag, x_auth_rmsg, x_auth_time, x_auth_type, x_avs, x_customer_hostname, x_customer_ipaddress, x_disable_avs, x_ics_applications, x_ics_rcode, x_ics_rflag, x_ics_rmsg, x_ignore_avs, x_ignore_bad_cv, x_merchant_id, x_merchant_product_sku, x_merchant_ref_number, x_offer_num, x_product_code, x_product_name, x_quantity, x_request_id, x_rqst_date, x_rqst_source, x_rqst_type, x_user_po) ALWAYS;
COMMENT ON TABLE sa.table_x_purch_hdr IS 'cc_Purchase Request Transaction History Header';
COMMENT ON COLUMN sa.table_x_purch_hdr.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_x_purch_hdr.x_rqst_source IS 'Indicates web, IVR/Clarify client.  name the form or webpage.';
COMMENT ON COLUMN sa.table_x_purch_hdr.x_rqst_type IS 'credit_card or check';
COMMENT ON COLUMN sa.table_x_purch_hdr.x_rqst_date IS 'date/time row was inserted';
COMMENT ON COLUMN sa.table_x_purch_hdr.x_ics_applications IS ' eg: =ics_auth    required.  names which cybersource apps were requested';
COMMENT ON COLUMN sa.table_x_purch_hdr.x_merchant_id IS ' eg =ICS2Test required.  assigned to us by CyberSource, may differ between test and live';
COMMENT ON COLUMN sa.table_x_purch_hdr.x_merchant_ref_number IS 'required we generate this number in num_scheme to uniquely identify this request';
COMMENT ON COLUMN sa.table_x_purch_hdr.x_offer_num IS 'show the offer name/number eg OFFER1, OFFER2 etc.';
COMMENT ON COLUMN sa.table_x_purch_hdr.x_quantity IS 'TBD';
COMMENT ON COLUMN sa.table_x_purch_hdr.x_merchant_product_sku IS 'TBD';
COMMENT ON COLUMN sa.table_x_purch_hdr.x_product_name IS 'TBD';
COMMENT ON COLUMN sa.table_x_purch_hdr.x_product_code IS 'TBD';
COMMENT ON COLUMN sa.table_x_purch_hdr.x_ignore_bad_cv IS 'eg =yes auth request from x_cc_parms';
COMMENT ON COLUMN sa.table_x_purch_hdr.x_ignore_avs IS 'auth request to ignore address verification';
COMMENT ON COLUMN sa.table_x_purch_hdr.x_user_po IS 'TBD';
COMMENT ON COLUMN sa.table_x_purch_hdr.x_avs IS '(score request) Value returned from address verification';
COMMENT ON COLUMN sa.table_x_purch_hdr.x_disable_avs IS 'score request Prevents ics_score from using the AVS (address verification)';
COMMENT ON COLUMN sa.table_x_purch_hdr.x_customer_hostname IS 'score request - WEB ONLY';
COMMENT ON COLUMN sa.table_x_purch_hdr.x_customer_ipaddress IS 'score request - WEB ONLY';
COMMENT ON COLUMN sa.table_x_purch_hdr.x_auth_request_id IS 'bill request reply value to us. eg =9520232566640167904518';
COMMENT ON COLUMN sa.table_x_purch_hdr.x_auth_code IS 'bill request - for verbal approvals';
COMMENT ON COLUMN sa.table_x_purch_hdr.x_auth_type IS 'bill request for verbal approvals';
COMMENT ON COLUMN sa.table_x_purch_hdr.x_ics_rcode IS 'ICS reply values long int  1,0, -1  1 = success, 0 - declined, -1 = system error';
COMMENT ON COLUMN sa.table_x_purch_hdr.x_ics_rflag IS 'ICS reply values, 1st char =S,D,E (success, declined, error) eg:  DINVALIDCARD, SOK, etc';
COMMENT ON COLUMN sa.table_x_purch_hdr.x_ics_rmsg IS 'ICS reply values Text description of rflag';
COMMENT ON COLUMN sa.table_x_purch_hdr.x_request_id IS 'ICS reply values eg =9520221610560167904518 - this is the number CyberSource uses to ID the request';
COMMENT ON COLUMN sa.table_x_purch_hdr.x_auth_avs IS 'auth reply eg X ';
COMMENT ON COLUMN sa.table_x_purch_hdr.x_auth_response IS 'auth reply if natwest bank sends a message directly.';
COMMENT ON COLUMN sa.table_x_purch_hdr.x_auth_time IS 'Time of reply in Cybersources peculiar format auth reply  eg =2000-03-02T183603Z';
COMMENT ON COLUMN sa.table_x_purch_hdr.x_auth_rcode IS 'auth reply long int  1,0, -1  1 = success, 0 - declined, -1 = system error';
COMMENT ON COLUMN sa.table_x_purch_hdr.x_auth_rflag IS 'auth reply values, 1st char =S,D,E (success, declined, error) eg:  DINVALIDCARD, SOK, etc';
COMMENT ON COLUMN sa.table_x_purch_hdr.x_auth_rmsg IS 'auth reply - Text description of rflag';
COMMENT ON COLUMN sa.table_x_purch_hdr.x_auth_cv_result IS 'auth reply eg =M';
COMMENT ON COLUMN sa.table_x_purch_hdr.x_score_factors IS 'score reply - returns code letter indicating reason for exceeding threshold';
COMMENT ON COLUMN sa.table_x_purch_hdr.x_score_host_severity IS 'score reply - returns code if email or host ipaddress was suspect';
COMMENT ON COLUMN sa.table_x_purch_hdr.x_score_rcode IS 'score reply long int  1,0, -1  1 = success, 0 - declined, -1 = system error';
COMMENT ON COLUMN sa.table_x_purch_hdr.x_score_rflag IS 'score reply values, 1st char =S,D,E (success, declined, error) eg:  DINVALIDCARD, SOK, etc';
COMMENT ON COLUMN sa.table_x_purch_hdr.x_score_rmsg IS 'score reply - Text description of rflag';
COMMENT ON COLUMN sa.table_x_purch_hdr.x_score_result IS 'score reply - will be a number between 0 and 99';
COMMENT ON COLUMN sa.table_x_purch_hdr.x_score_time_local IS 'Time of Score reply in Cybersources peculiar format auth reply    eg =2000-03-02T183603Z';
COMMENT ON COLUMN sa.table_x_purch_hdr.x_bill_request_time IS 'Time of Bill Request - reply in Cybersources peculiar format auth reply   eg =2000-03-02T183603Z';
COMMENT ON COLUMN sa.table_x_purch_hdr.x_bill_rcode IS 'bill reply long int  1,0, -1  1 = success, 0 - declined, -1 = system error';
COMMENT ON COLUMN sa.table_x_purch_hdr.x_bill_rflag IS 'bill reply values, 1st char =S,D,E (success, declined, error) eg:  DINVALIDCARD, SOK, etc';
COMMENT ON COLUMN sa.table_x_purch_hdr.x_bill_rmsg IS 'bill reply - Text description of rflag';
COMMENT ON COLUMN sa.table_x_purch_hdr.x_bill_trans_ref_no IS 'bill reply - tracks request on financial reconciliation reports. eg  =3349234020 ';
COMMENT ON COLUMN sa.table_x_purch_hdr.x_customer_cc_number IS 'encrypted (by app) except for last 4 characters';
COMMENT ON COLUMN sa.table_x_purch_hdr.x_customer_cc_expmo IS 'card expiration month number eg =12';
COMMENT ON COLUMN sa.table_x_purch_hdr.x_customer_cc_expyr IS 'card expiration year number eg =2001';
COMMENT ON COLUMN sa.table_x_purch_hdr.x_customer_cc_cv_number IS 'CVV2 number for additional card validation eg =47E';
COMMENT ON COLUMN sa.table_x_purch_hdr.x_customer_firstname IS 'cardholder first name  eg =Olga';
COMMENT ON COLUMN sa.table_x_purch_hdr.x_customer_lastname IS 'cardholder last name  eg =Smiff';
COMMENT ON COLUMN sa.table_x_purch_hdr.x_customer_phone IS 'Phone number credit card company has on file as billing address; usually not a TracFone';
COMMENT ON COLUMN sa.table_x_purch_hdr.x_customer_email IS 'customer email address, needed for purchase validation eg =test@cybersource.com';
COMMENT ON COLUMN sa.table_x_purch_hdr.x_bank_num IS 'Bank Number of the Customer. First part of MICR number';
COMMENT ON COLUMN sa.table_x_purch_hdr.x_customer_acct IS 'Customer account number.  2nd part of MICR number. encrypted by app except for last 4 characters';
COMMENT ON COLUMN sa.table_x_purch_hdr.x_routing IS 'Bank Routing Number';
COMMENT ON COLUMN sa.table_x_purch_hdr.x_aba_transit IS 'Bank ABA / Transit number on the check  eg:  64-5/610';
COMMENT ON COLUMN sa.table_x_purch_hdr.x_bank_name IS 'Name of the Bank eg:  Joes Bank';
COMMENT ON COLUMN sa.table_x_purch_hdr.x_status IS 'Status of the account A active, I inactive, or B black_flagged';
COMMENT ON COLUMN sa.table_x_purch_hdr.x_bill_address1 IS 'Line 1 of address which includes street number, street name, office, building, or suite number, etc';
COMMENT ON COLUMN sa.table_x_purch_hdr.x_bill_address2 IS 'Line 2 of address which typically includes office, building, or suite number, etc';
COMMENT ON COLUMN sa.table_x_purch_hdr.x_bill_city IS 'The city for the specified address';
COMMENT ON COLUMN sa.table_x_purch_hdr.x_bill_state IS 'The state for the specified address.  This should be a code like NJ';
COMMENT ON COLUMN sa.table_x_purch_hdr.x_bill_zip IS 'The zip or other postal code for the specified address';
COMMENT ON COLUMN sa.table_x_purch_hdr.x_bill_country IS 'required by CyberSource';
COMMENT ON COLUMN sa.table_x_purch_hdr.x_esn IS 'ESN number used to purchase this credit card';
COMMENT ON COLUMN sa.table_x_purch_hdr.x_cc_lastfour IS 'last 4 characters of the credit card in cleartext';
COMMENT ON COLUMN sa.table_x_purch_hdr.x_amount IS 'total $ for all red_card purchases in this transaction';
COMMENT ON COLUMN sa.table_x_purch_hdr.x_tax_amount IS 'total sales tax $ for all red_card purchases in this transaction';
COMMENT ON COLUMN sa.table_x_purch_hdr.x_auth_amount IS 'auth reply eg 1.00';
COMMENT ON COLUMN sa.table_x_purch_hdr.x_bill_amount IS 'bill reply.  = successfully billed $ amt of the transaction eg  =1.00';
COMMENT ON COLUMN sa.table_x_purch_hdr.x_user IS 'name of the user who performed this transaction';
COMMENT ON COLUMN sa.table_x_purch_hdr.x_purch_hdr2creditcard IS 'credit card used in this purchase transaction';
COMMENT ON COLUMN sa.table_x_purch_hdr.x_purch_hdr2bank_acct IS 'bank checking account used in this purchase transaction';
COMMENT ON COLUMN sa.table_x_purch_hdr.x_purch_hdr2contact IS 'customer who made this purchase';
COMMENT ON COLUMN sa.table_x_purch_hdr.x_purch_hdr2user IS 'CSR who did this transaction.  Empty for web or IVR purchases';
COMMENT ON COLUMN sa.table_x_purch_hdr.x_purch_hdr2esn IS 'esn related to this purchase transaction';
COMMENT ON COLUMN sa.table_x_purch_hdr.x_purch_hdr2x_rmsg_codes IS 'translation of CyberSource codes';
COMMENT ON COLUMN sa.table_x_purch_hdr.x_purch_hdr2cr_purch IS 'self-joins purchases to credits - refunds or chargebacks';
COMMENT ON COLUMN sa.table_x_purch_hdr.x_credit_code IS 'TBD';
COMMENT ON COLUMN sa.table_x_purch_hdr.x_credit_reason IS 'Reason for Granting a Refund';
COMMENT ON COLUMN sa.table_x_purch_hdr.x_e911_amount IS 'TBD';
COMMENT ON COLUMN sa.table_x_purch_hdr.x_usf_taxamount IS 'USF Tax Amount';
COMMENT ON COLUMN sa.table_x_purch_hdr.x_rcrf_tax_amount IS 'RCRF Tax Amount';
COMMENT ON COLUMN sa.table_x_purch_hdr.x_discount_amount IS 'Discount amount';
COMMENT ON COLUMN sa.table_x_purch_hdr.x_total_tax IS 'Combined all Tax Amount';