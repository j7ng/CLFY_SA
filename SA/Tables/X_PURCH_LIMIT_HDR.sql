CREATE TABLE sa.x_purch_limit_hdr (
  objid NUMBER,
  x_trans_date DATE,
  x_imei VARCHAR2(20 BYTE),
  x_mdn VARCHAR2(20 BYTE),
  x_trans_amount NUMBER,
  x_last_trans_date DATE,
  x_thres_balance NUMBER,
  x_trans_count NUMBER,
  x_last4_ccn NUMBER,
  x_err_number NUMBER
);
ALTER TABLE sa.x_purch_limit_hdr ADD SUPPLEMENTAL LOG GROUP dmtsora1828738577_0 (objid, x_err_number, x_imei, x_last4_ccn, x_last_trans_date, x_mdn, x_thres_balance, x_trans_amount, x_trans_count, x_trans_date) ALWAYS;
COMMENT ON TABLE sa.x_purch_limit_hdr IS 'Billing Programs Purchase Error Log.  It stores errors capture during credit card processing.';
COMMENT ON COLUMN sa.x_purch_limit_hdr.objid IS 'Internal Record ID';
COMMENT ON COLUMN sa.x_purch_limit_hdr.x_trans_date IS 'Timestamp for the transaction';
COMMENT ON COLUMN sa.x_purch_limit_hdr.x_imei IS 'Phone Serial Number, also knows as ESN';
COMMENT ON COLUMN sa.x_purch_limit_hdr.x_mdn IS 'Mobile Number, also knows as MIN';
COMMENT ON COLUMN sa.x_purch_limit_hdr.x_trans_amount IS 'Dollar Amount for the transaction';
COMMENT ON COLUMN sa.x_purch_limit_hdr.x_last_trans_date IS 'Date of last transaction';
COMMENT ON COLUMN sa.x_purch_limit_hdr.x_thres_balance IS 'Threshold amount';
COMMENT ON COLUMN sa.x_purch_limit_hdr.x_trans_count IS 'Number of transactions attempted';
COMMENT ON COLUMN sa.x_purch_limit_hdr.x_last4_ccn IS 'Last 4 digits of the credit card';
COMMENT ON COLUMN sa.x_purch_limit_hdr.x_err_number IS 'Error Code Generated';