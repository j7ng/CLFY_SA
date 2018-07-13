CREATE TABLE sa.x_biz_purch_hdr (
  objid NUMBER,
  x_rqst_source VARCHAR2(20 BYTE),
  channel VARCHAR2(50 BYTE),
  ecom_org_id VARCHAR2(150 BYTE),
  order_type VARCHAR2(50 BYTE),
  c_orderid VARCHAR2(50 BYTE),
  account_id VARCHAR2(50 BYTE),
  x_auth_request_id VARCHAR2(40 BYTE),
  groupidentifier VARCHAR2(20 BYTE),
  x_rqst_type VARCHAR2(20 BYTE),
  x_rqst_date DATE,
  x_ics_applications VARCHAR2(50 BYTE),
  x_merchant_id VARCHAR2(30 BYTE),
  x_merchant_ref_number VARCHAR2(50 BYTE),
  x_offer_num VARCHAR2(10 BYTE),
  x_quantity NUMBER,
  x_ignore_avs VARCHAR2(10 BYTE),
  x_avs VARCHAR2(30 BYTE),
  x_disable_avs VARCHAR2(30 BYTE),
  x_customer_hostname VARCHAR2(60 BYTE),
  x_customer_ipaddress VARCHAR2(30 BYTE),
  x_auth_code VARCHAR2(30 BYTE),
  x_ics_rcode VARCHAR2(10 BYTE),
  x_ics_rflag VARCHAR2(30 BYTE),
  x_ics_rmsg VARCHAR2(255 BYTE),
  x_request_id VARCHAR2(40 BYTE),
  x_auth_request_token VARCHAR2(255 BYTE),
  x_auth_avs VARCHAR2(30 BYTE),
  x_auth_response VARCHAR2(60 BYTE),
  x_auth_time VARCHAR2(20 BYTE),
  x_auth_rcode VARCHAR2(10 BYTE),
  x_auth_rflag VARCHAR2(30 BYTE),
  x_auth_rmsg VARCHAR2(255 BYTE),
  x_bill_request_time VARCHAR2(20 BYTE),
  x_bill_rcode VARCHAR2(10 BYTE),
  x_bill_rflag VARCHAR2(30 BYTE),
  x_bill_rmsg VARCHAR2(255 BYTE),
  x_bill_trans_ref_no VARCHAR2(30 BYTE),
  x_score_rcode VARCHAR2(10 BYTE),
  x_score_rflag VARCHAR2(30 BYTE),
  x_score_rmsg VARCHAR2(255 BYTE),
  x_customer_firstname VARCHAR2(20 BYTE),
  x_customer_lastname VARCHAR2(20 BYTE),
  x_customer_phone VARCHAR2(20 BYTE),
  x_customer_email VARCHAR2(50 BYTE),
  x_status VARCHAR2(20 BYTE),
  x_bill_address1 VARCHAR2(200 BYTE),
  x_bill_address2 VARCHAR2(200 BYTE),
  x_bill_city VARCHAR2(100 BYTE),
  x_bill_state VARCHAR2(50 BYTE),
  x_bill_zip VARCHAR2(40 BYTE),
  x_bill_country VARCHAR2(100 BYTE),
  x_ship_address1 VARCHAR2(200 BYTE),
  x_ship_address2 VARCHAR2(200 BYTE),
  x_ship_city VARCHAR2(30 BYTE),
  x_ship_state VARCHAR2(40 BYTE),
  x_ship_zip VARCHAR2(20 BYTE),
  x_ship_country VARCHAR2(20 BYTE),
  x_esn VARCHAR2(20 BYTE),
  x_amount NUMBER(19,2),
  x_tax_amount NUMBER(19,2),
  x_sales_tax_amount NUMBER(19,2),
  x_e911_tax_amount NUMBER,
  x_usf_taxamount NUMBER,
  x_rcrf_tax_amount NUMBER,
  x_add_tax1 NUMBER,
  x_add_tax2 NUMBER,
  discount_amount NUMBER,
  freight_amount NUMBER,
  x_auth_amount NUMBER,
  x_bill_amount NUMBER,
  x_user VARCHAR2(80 BYTE),
  purch_hdr2creditcard NUMBER,
  purch_hdr2bank_acct NUMBER,
  purch_hdr2other_funds NUMBER,
  prog_hdr2x_pymt_src NUMBER,
  prog_hdr2web_user NUMBER,
  x_payment_type VARCHAR2(50 BYTE),
  x_process_date DATE,
  x_promo_code VARCHAR2(50 BYTE),
  x_credit_reason VARCHAR2(50 BYTE),
  purch_hdr2altpymtsource NUMBER,
  rma_id VARCHAR2(50 BYTE),
  tf_extract_flag VARCHAR2(1 BYTE),
  tf_extract_date DATE,
  agent_id VARCHAR2(30 BYTE),
  CONSTRAINT biz_purch_hdr_unique UNIQUE (objid),
  CONSTRAINT x_merchant_ref_number_unique UNIQUE (x_merchant_ref_number)
);
COMMENT ON COLUMN sa.x_biz_purch_hdr.objid IS 'Sequence number';
COMMENT ON COLUMN sa.x_biz_purch_hdr.x_rqst_source IS 'WEB/ CSR/ IVR/ APP etc.,';
COMMENT ON COLUMN sa.x_biz_purch_hdr.channel IS 'B2B/ B2C/ VAS';
COMMENT ON COLUMN sa.x_biz_purch_hdr.ecom_org_id IS 'ecommerce org id';
COMMENT ON COLUMN sa.x_biz_purch_hdr.order_type IS '(Order/pre order)';
COMMENT ON COLUMN sa.x_biz_purch_hdr.c_orderid IS 'from OFS/ e-commerce(Order_id)';
COMMENT ON COLUMN sa.x_biz_purch_hdr.account_id IS 'from OFS/ e-commerce';
COMMENT ON COLUMN sa.x_biz_purch_hdr.x_auth_request_id IS 'from Cybersource';
COMMENT ON COLUMN sa.x_biz_purch_hdr.groupidentifier IS 'from OFS/ e-commerce';
COMMENT ON COLUMN sa.x_biz_purch_hdr.x_rqst_type IS 'CREDITCARD_PURCH or ACH_PURCH or PAYPAL_PURCH or MONEYGRAM_PURCH';
COMMENT ON COLUMN sa.x_biz_purch_hdr.x_rqst_date IS 'SYSDATE';
COMMENT ON COLUMN sa.x_biz_purch_hdr.x_ics_applications IS 'Cybersource applications (ics_auth, ics_score, ics_bill or ics_credit)(operation type)';
COMMENT ON COLUMN sa.x_biz_purch_hdr.x_merchant_id IS 'Cybersource merchant id';
COMMENT ON COLUMN sa.x_biz_purch_hdr.x_merchant_ref_number IS 'TracFone generated ID';
COMMENT ON COLUMN sa.x_biz_purch_hdr.x_offer_num IS '1 or 0';
COMMENT ON COLUMN sa.x_biz_purch_hdr.x_quantity IS 'number';
COMMENT ON COLUMN sa.x_biz_purch_hdr.x_ignore_avs IS 'comes from Payment service, most of the cases value will be Yes or No';
COMMENT ON COLUMN sa.x_biz_purch_hdr.x_avs IS '1 or 0 depends on X_IGNORE_AVS';
COMMENT ON COLUMN sa.x_biz_purch_hdr.x_disable_avs IS 'true or false (depends on IGNORE_AVS)';
COMMENT ON COLUMN sa.x_biz_purch_hdr.x_customer_hostname IS 'Payment services has to recognize the host name';
COMMENT ON COLUMN sa.x_biz_purch_hdr.x_customer_ipaddress IS 'Payment services has to recognize the IP Addresses';
COMMENT ON COLUMN sa.x_biz_purch_hdr.x_auth_code IS 'Auth code from Cybersource';
COMMENT ON COLUMN sa.x_biz_purch_hdr.x_ics_rcode IS 'Final Result from Cybersource (1 or 100 for Success, remaining numbers are for decline)';
COMMENT ON COLUMN sa.x_biz_purch_hdr.x_ics_rflag IS 'SOK or DECLINE or REJECT';
COMMENT ON COLUMN sa.x_biz_purch_hdr.x_ics_rmsg IS 'Decline or success message from Cybersource';
COMMENT ON COLUMN sa.x_biz_purch_hdr.x_request_id IS 'Cybersource generated ID';
COMMENT ON COLUMN sa.x_biz_purch_hdr.x_auth_request_token IS 'Cybersource generated Token (will be used while settlement - ics_bill)';
COMMENT ON COLUMN sa.x_biz_purch_hdr.x_auth_avs IS 'AVS Response from Cybersource';
COMMENT ON COLUMN sa.x_biz_purch_hdr.x_auth_response IS 'Response code from Cybersource';
COMMENT ON COLUMN sa.x_biz_purch_hdr.x_auth_time IS 'Time';
COMMENT ON COLUMN sa.x_biz_purch_hdr.x_auth_rcode IS 'AUTH Status RCODE (1 or 100 or any decline code)';
COMMENT ON COLUMN sa.x_biz_purch_hdr.x_auth_rflag IS 'SOK or DECLINE or REJECT';
COMMENT ON COLUMN sa.x_biz_purch_hdr.x_auth_rmsg IS 'Decline or success message from Cybersource';
COMMENT ON COLUMN sa.x_biz_purch_hdr.x_bill_request_time IS 'Time';
COMMENT ON COLUMN sa.x_biz_purch_hdr.x_bill_rcode IS 'BILL Status RCODE (1 or 100 or any decline code)';
COMMENT ON COLUMN sa.x_biz_purch_hdr.x_bill_rflag IS 'SOK or DECLINE or REJECT';
COMMENT ON COLUMN sa.x_biz_purch_hdr.x_bill_rmsg IS 'Decline or success message from Cybersource';
COMMENT ON COLUMN sa.x_biz_purch_hdr.x_bill_trans_ref_no IS 'Cybersource generated (and sends to Paymentech)';
COMMENT ON COLUMN sa.x_biz_purch_hdr.x_score_rcode IS 'Score status (for Fraud shield)';
COMMENT ON COLUMN sa.x_biz_purch_hdr.x_score_rflag IS 'Score status (for Fraud shield)';
COMMENT ON COLUMN sa.x_biz_purch_hdr.x_score_rmsg IS 'Score status (for Fraud shield)';
COMMENT ON COLUMN sa.x_biz_purch_hdr.x_customer_firstname IS 'Customer Info';
COMMENT ON COLUMN sa.x_biz_purch_hdr.x_customer_lastname IS 'Customer Info';
COMMENT ON COLUMN sa.x_biz_purch_hdr.x_customer_phone IS 'Customer Info';
COMMENT ON COLUMN sa.x_biz_purch_hdr.x_customer_email IS 'Customer Info';
COMMENT ON COLUMN sa.x_biz_purch_hdr.x_status IS 'Payment Status (FAILED or SUCCESS or PROCESSED or INCOMPLETE)';
COMMENT ON COLUMN sa.x_biz_purch_hdr.x_bill_address1 IS 'Credit card address';
COMMENT ON COLUMN sa.x_biz_purch_hdr.x_bill_address2 IS 'Credit card address';
COMMENT ON COLUMN sa.x_biz_purch_hdr.x_bill_city IS 'Credit card address';
COMMENT ON COLUMN sa.x_biz_purch_hdr.x_bill_state IS 'Credit card address';
COMMENT ON COLUMN sa.x_biz_purch_hdr.x_bill_zip IS 'Credit card address';
COMMENT ON COLUMN sa.x_biz_purch_hdr.x_bill_country IS 'Credit card address (should be able to accept International credit cards)';
COMMENT ON COLUMN sa.x_biz_purch_hdr.x_ship_address1 IS 'Ship address';
COMMENT ON COLUMN sa.x_biz_purch_hdr.x_ship_address2 IS 'Ship address';
COMMENT ON COLUMN sa.x_biz_purch_hdr.x_ship_city IS 'Ship address';
COMMENT ON COLUMN sa.x_biz_purch_hdr.x_ship_state IS 'Ship address';
COMMENT ON COLUMN sa.x_biz_purch_hdr.x_ship_zip IS 'Ship address';
COMMENT ON COLUMN sa.x_biz_purch_hdr.x_ship_country IS 'UNITED STATES ONLY';
COMMENT ON COLUMN sa.x_biz_purch_hdr.x_esn IS 'Usually NULL';
COMMENT ON COLUMN sa.x_biz_purch_hdr.x_amount IS 'MSRP of the final checkout amount';
COMMENT ON COLUMN sa.x_biz_purch_hdr.x_tax_amount IS 'Consolidated Sales tax';
COMMENT ON COLUMN sa.x_biz_purch_hdr.x_sales_tax_amount IS 'Sales tax';
COMMENT ON COLUMN sa.x_biz_purch_hdr.x_e911_tax_amount IS 'Tax Amounts';
COMMENT ON COLUMN sa.x_biz_purch_hdr.x_usf_taxamount IS 'Tax Amounts';
COMMENT ON COLUMN sa.x_biz_purch_hdr.x_rcrf_tax_amount IS 'Tax Amounts';
COMMENT ON COLUMN sa.x_biz_purch_hdr.x_add_tax1 IS 'Tax Amounts';
COMMENT ON COLUMN sa.x_biz_purch_hdr.x_add_tax2 IS 'Tax Amounts';
COMMENT ON COLUMN sa.x_biz_purch_hdr.discount_amount IS 'Any discounts';
COMMENT ON COLUMN sa.x_biz_purch_hdr.freight_amount IS 'Shipping Charges';
COMMENT ON COLUMN sa.x_biz_purch_hdr.x_auth_amount IS 'Consolidated AUTH amount (No Partial AUTH for this phase)';
COMMENT ON COLUMN sa.x_biz_purch_hdr.x_bill_amount IS 'Consolidated BILL amount - MSRP + all Taxes + surcharges + Shipping - Discount (No Partial Settlement for this phase)';
COMMENT ON COLUMN sa.x_biz_purch_hdr.x_user IS 'User login name';
COMMENT ON COLUMN sa.x_biz_purch_hdr.purch_hdr2creditcard IS 'Credit card OBJID';
COMMENT ON COLUMN sa.x_biz_purch_hdr.purch_hdr2bank_acct IS 'Bank Account (for ACH) OBJID';
COMMENT ON COLUMN sa.x_biz_purch_hdr.purch_hdr2other_funds IS 'for Other funding source OBJIDs';
COMMENT ON COLUMN sa.x_biz_purch_hdr.prog_hdr2x_pymt_src IS 'X_PAYMENT_SOURCE OBJID';
COMMENT ON COLUMN sa.x_biz_purch_hdr.prog_hdr2web_user IS 'Table_web_user Objid';
COMMENT ON COLUMN sa.x_biz_purch_hdr.x_payment_type IS 'AUTHORIZATION or SETTLEMENT or DECISION_MANAGER or REFUND';
COMMENT ON COLUMN sa.x_biz_purch_hdr.x_process_date IS 'for BI purpose. Create a new Trigger on this column (same as program purch hdr trigger)';
COMMENT ON COLUMN sa.x_biz_purch_hdr.x_promo_code IS 'For Promocodes';
COMMENT ON COLUMN sa.x_biz_purch_hdr.purch_hdr2altpymtsource IS 'Alternate Payment Source OBJID';