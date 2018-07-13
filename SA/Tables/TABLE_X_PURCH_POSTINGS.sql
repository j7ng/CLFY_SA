CREATE TABLE sa.table_x_purch_postings (
  objid NUMBER,
  x_clarify_post_dt DATE,
  x_orafin_post_flag NUMBER,
  x_orafin_post_dt DATE,
  x_merchant_ref_number VARCHAR2(30 BYTE),
  x_bill_trans_ref_no VARCHAR2(30 BYTE),
  x_request_id VARCHAR2(30 BYTE),
  x_auth_request_id VARCHAR2(30 BYTE),
  x_state VARCHAR2(10 BYTE),
  x_bill_zip VARCHAR2(20 BYTE),
  x_cc_lastfour VARCHAR2(4 BYTE),
  x_tax_amount NUMBER(19,2),
  x_purchase_amount NUMBER(19,2),
  x_total_purch_amt NUMBER(19,2),
  x_rqst_type VARCHAR2(20 BYTE)
);
ALTER TABLE sa.table_x_purch_postings ADD SUPPLEMENTAL LOG GROUP dmtsora1242590928_0 (objid, x_auth_request_id, x_bill_trans_ref_no, x_bill_zip, x_cc_lastfour, x_clarify_post_dt, x_merchant_ref_number, x_orafin_post_dt, x_orafin_post_flag, x_purchase_amount, x_request_id, x_rqst_type, x_state, x_tax_amount, x_total_purch_amt) ALWAYS;
COMMENT ON TABLE sa.table_x_purch_postings IS 'credit-card purchase postings sent to Oracle Financials';
COMMENT ON COLUMN sa.table_x_purch_postings.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_x_purch_postings.x_clarify_post_dt IS 'TBD';
COMMENT ON COLUMN sa.table_x_purch_postings.x_orafin_post_flag IS '1 = reserved, 0 = available';
COMMENT ON COLUMN sa.table_x_purch_postings.x_orafin_post_dt IS 'TBD';
COMMENT ON COLUMN sa.table_x_purch_postings.x_merchant_ref_number IS 'Clarify generates this number in num_scheme to uniquely identify this request';
COMMENT ON COLUMN sa.table_x_purch_postings.x_bill_trans_ref_no IS 'CyberSource assigns this number and uses it on Financial reports to uniquely identify each purchase';
COMMENT ON COLUMN sa.table_x_purch_postings.x_request_id IS 'ICS reply values eg =9520221610560167904518 - this is the number CyberSource uses to ID the request';
COMMENT ON COLUMN sa.table_x_purch_postings.x_auth_request_id IS 'bill request reply value to us. eg =9520232566640167904518';
COMMENT ON COLUMN sa.table_x_purch_postings.x_state IS 'eg NJ = New Jersey';
COMMENT ON COLUMN sa.table_x_purch_postings.x_bill_zip IS 'The zip or other postal code for the specified address';
COMMENT ON COLUMN sa.table_x_purch_postings.x_cc_lastfour IS 'last 4 characters of the credit card in cleartext';
COMMENT ON COLUMN sa.table_x_purch_postings.x_tax_amount IS 'TBD';
COMMENT ON COLUMN sa.table_x_purch_postings.x_purchase_amount IS 'doesn"t include x_tax_amount';
COMMENT ON COLUMN sa.table_x_purch_postings.x_total_purch_amt IS 'includes x_tax_amount';
COMMENT ON COLUMN sa.table_x_purch_postings.x_rqst_type IS 'credit_card or check';