CREATE TABLE sa.x_pre_val_purch_hdr (
  objid NUMBER NOT NULL,
  x_rqst_source VARCHAR2(20 BYTE),
  x_rqst_type VARCHAR2(20 BYTE),
  x_rqst_date DATE,
  x_payment_type VARCHAR2(30 BYTE),
  x_brand_name VARCHAR2(30 BYTE),
  x_language VARCHAR2(12 BYTE),
  x_card_type VARCHAR2(30 BYTE),
  x_new_registration VARCHAR2(1 BYTE),
  x_calling_module_id VARCHAR2(30 BYTE),
  x_web_user_login_id VARCHAR2(50 BYTE),
  x_agent VARCHAR2(30 BYTE),
  x_skip_enrollment VARCHAR2(10 BYTE),
  x_merchant_id VARCHAR2(30 BYTE),
  x_esn VARCHAR2(20 BYTE),
  x_merchant_ref_number VARCHAR2(30 BYTE),
  x_customer_hostname VARCHAR2(60 BYTE),
  x_customer_ipaddress VARCHAR2(30 BYTE),
  x_customer_firstname VARCHAR2(20 BYTE),
  x_customer_lastname VARCHAR2(20 BYTE),
  x_customer_phone VARCHAR2(20 BYTE),
  x_customer_email VARCHAR2(50 BYTE),
  x_bill_address1 VARCHAR2(200 BYTE),
  x_bill_address2 VARCHAR2(200 BYTE),
  x_bill_city VARCHAR2(30 BYTE),
  x_bill_state VARCHAR2(40 BYTE),
  x_bill_zip VARCHAR2(20 BYTE),
  x_bill_country VARCHAR2(20 BYTE),
  x_amount NUMBER(19,2),
  x_auth_amount NUMBER(19,2),
  x_bill_amount NUMBER(19,2),
  x_e911_amount NUMBER,
  x_usf_taxamount NUMBER,
  x_rcrf_tax_amount NUMBER,
  x_discount_amount NUMBER,
  x_tax_amount NUMBER(19,2),
  x_preval_purch2creditcard NUMBER,
  x_preval_purch2bank_acct NUMBER,
  x_preval_purch2user NUMBER,
  x_preval_purch2esn NUMBER,
  x_preval_purch2pymt_src NUMBER,
  x_preval_purch2web_user NUMBER,
  x_preval_purch2contact NUMBER,
  x_preval_purch2rmsg_codes NUMBER,
  x_error_number VARCHAR2(20 BYTE),
  x_ecom_org_id VARCHAR2(150 BYTE),
  x_c_orderid VARCHAR2(50 BYTE),
  x_account_id VARCHAR2(50 BYTE),
  x_idn_user_change_last VARCHAR2(50 BYTE),
  x_dte_change_last DATE
);
COMMENT ON TABLE sa.x_pre_val_purch_hdr IS 'This table is created to log data related to failed transactions ';
COMMENT ON COLUMN sa.x_pre_val_purch_hdr.objid IS 'Primary key column of X_PRE_VAL_PURCH_HDR table';
COMMENT ON COLUMN sa.x_pre_val_purch_hdr.x_rqst_source IS 'This call stores the source which initiated this transaction request. Possible values APP,BEAST,CENTENE,HANDSET,HMO,IVR,MB_WEB,NETCSR,NETHANDSET,NETWEB,TAS,VMBC,WAP,WEB,WEBCSR,WMKIOSK ';
COMMENT ON COLUMN sa.x_pre_val_purch_hdr.x_rqst_type IS 'Request type with valid values: cc_purch, CREDITCARD_PURCH, ACH_PURCH ';
COMMENT ON COLUMN sa.x_pre_val_purch_hdr.x_rqst_date IS 'Date when this trasaction happened ';
COMMENT ON COLUMN sa.x_pre_val_purch_hdr.x_payment_type IS 'Possible values: ENROLLMENT, PAYNOW, PURCHASE ';
COMMENT ON COLUMN sa.x_pre_val_purch_hdr.x_brand_name IS 'Brand name ';
COMMENT ON COLUMN sa.x_pre_val_purch_hdr.x_language IS 'Language  ';
COMMENT ON COLUMN sa.x_pre_val_purch_hdr.x_card_type IS 'Credit card type: Master card or visa, etc';
COMMENT ON COLUMN sa.x_pre_val_purch_hdr.x_new_registration IS 'This determines if its a new registration or not; possible values Y or N ';
COMMENT ON COLUMN sa.x_pre_val_purch_hdr.x_calling_module_id IS 'Which module is calling CBO method ';
COMMENT ON COLUMN sa.x_pre_val_purch_hdr.x_web_user_login_id IS 'Web user login id ';
COMMENT ON COLUMN sa.x_pre_val_purch_hdr.x_agent IS 'Agent name ';
COMMENT ON COLUMN sa.x_pre_val_purch_hdr.x_skip_enrollment IS 'Request parameter to tell if we need to skip enrollment ';
COMMENT ON COLUMN sa.x_pre_val_purch_hdr.x_merchant_id IS 'Merchant id from TABLE_X_CC_PARMS ';
COMMENT ON COLUMN sa.x_pre_val_purch_hdr.x_esn IS 'ESN ';
COMMENT ON COLUMN sa.x_pre_val_purch_hdr.x_merchant_ref_number IS 'Merchant reference number ';
COMMENT ON COLUMN sa.x_pre_val_purch_hdr.x_customer_hostname IS 'Server name ';
COMMENT ON COLUMN sa.x_pre_val_purch_hdr.x_customer_ipaddress IS 'IP address from which customer logged in ';
COMMENT ON COLUMN sa.x_pre_val_purch_hdr.x_customer_firstname IS 'Customer first name ';
COMMENT ON COLUMN sa.x_pre_val_purch_hdr.x_customer_lastname IS 'Customer last name ';
COMMENT ON COLUMN sa.x_pre_val_purch_hdr.x_customer_phone IS 'Customer phone number ';
COMMENT ON COLUMN sa.x_pre_val_purch_hdr.x_customer_email IS 'Customer email id ';
COMMENT ON COLUMN sa.x_pre_val_purch_hdr.x_bill_address1 IS 'Billing address line 1 ';
COMMENT ON COLUMN sa.x_pre_val_purch_hdr.x_bill_address2 IS 'Billing address line 2 ';
COMMENT ON COLUMN sa.x_pre_val_purch_hdr.x_bill_city IS 'Billing address city ';
COMMENT ON COLUMN sa.x_pre_val_purch_hdr.x_bill_state IS 'Billing address state ';
COMMENT ON COLUMN sa.x_pre_val_purch_hdr.x_bill_zip IS 'Billing address zip code ';
COMMENT ON COLUMN sa.x_pre_val_purch_hdr.x_bill_country IS 'Billing address country ';
COMMENT ON COLUMN sa.x_pre_val_purch_hdr.x_amount IS ' Amount';
COMMENT ON COLUMN sa.x_pre_val_purch_hdr.x_auth_amount IS 'Authorized amount ';
COMMENT ON COLUMN sa.x_pre_val_purch_hdr.x_bill_amount IS 'Bill amount ';
COMMENT ON COLUMN sa.x_pre_val_purch_hdr.x_e911_amount IS 'E911 amount ';
COMMENT ON COLUMN sa.x_pre_val_purch_hdr.x_usf_taxamount IS 'USF tax amount ';
COMMENT ON COLUMN sa.x_pre_val_purch_hdr.x_rcrf_tax_amount IS 'RCRF tax amount ';
COMMENT ON COLUMN sa.x_pre_val_purch_hdr.x_discount_amount IS 'Discount amount ';
COMMENT ON COLUMN sa.x_pre_val_purch_hdr.x_tax_amount IS 'Tax amount ';
COMMENT ON COLUMN sa.x_pre_val_purch_hdr.x_preval_purch2creditcard IS 'Objid of TABLE_X_CREDIT_CARD ';
COMMENT ON COLUMN sa.x_pre_val_purch_hdr.x_preval_purch2bank_acct IS ' Objid of TABLE_X_BANK_ACCOUNT ';
COMMENT ON COLUMN sa.x_pre_val_purch_hdr.x_preval_purch2user IS 'Agent user objid from table_user ';
COMMENT ON COLUMN sa.x_pre_val_purch_hdr.x_preval_purch2esn IS 'PART_SERIAL_NO in TABLE_PART_INST ';
COMMENT ON COLUMN sa.x_pre_val_purch_hdr.x_preval_purch2pymt_src IS ' ';
COMMENT ON COLUMN sa.x_pre_val_purch_hdr.x_preval_purch2web_user IS ' Objid of TABLE_WEB_USER';
COMMENT ON COLUMN sa.x_pre_val_purch_hdr.x_preval_purch2contact IS 'Objid of TABLE_CONTACT';
COMMENT ON COLUMN sa.x_pre_val_purch_hdr.x_preval_purch2rmsg_codes IS 'Objid of TABLE_X_PURCH_CODES ';
COMMENT ON COLUMN sa.x_pre_val_purch_hdr.x_error_number IS 'CBO error number; we get it from TABLE_X_PURCH_CODES.X_CODE_NUM ';
COMMENT ON COLUMN sa.x_pre_val_purch_hdr.x_ecom_org_id IS ' ';
COMMENT ON COLUMN sa.x_pre_val_purch_hdr.x_c_orderid IS ' ';
COMMENT ON COLUMN sa.x_pre_val_purch_hdr.x_account_id IS ' ';
COMMENT ON COLUMN sa.x_pre_val_purch_hdr.x_idn_user_change_last IS 'User who logged this record into DB ';
COMMENT ON COLUMN sa.x_pre_val_purch_hdr.x_dte_change_last IS 'Date when this record is entered into DB ';