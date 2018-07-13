CREATE TABLE sa.table_x_cc_parms (
  objid NUMBER,
  x_eff_date DATE,
  x_max_purch_amt NUMBER,
  x_max_trans_per_month NUMBER,
  x_max_purch_amt_per_month NUMBER,
  x_timeout NUMBER,
  x_retries NUMBER,
  x_merchant_id VARCHAR2(30 BYTE),
  x_ignore_bad_cv VARCHAR2(10 BYTE),
  x_currency VARCHAR2(10 BYTE),
  x_server_host VARCHAR2(40 BYTE),
  x_server_port VARCHAR2(10 BYTE),
  x_ics_fraud_threshold NUMBER,
  x_merchant_descriptor VARCHAR2(50 BYTE),
  x_merchant_descriptor_contact VARCHAR2(50 BYTE),
  x_score_threshold NUMBER,
  x_score_host_hedge VARCHAR2(10 BYTE),
  x_score_time_hedge VARCHAR2(10 BYTE),
  x_score_velocity_hedge VARCHAR2(10 BYTE),
  x_score_category_gift VARCHAR2(10 BYTE),
  x_score_category_time VARCHAR2(30 BYTE),
  x_score_category_longterm VARCHAR2(10 BYTE),
  x_inv_alarm_threshold NUMBER,
  x_elapsed_time NUMBER,
  x_timeout_max NUMBER,
  x_notify VARCHAR2(60 BYTE),
  x_cc_esn_max NUMBER,
  x_ccparm_hist LONG,
  x_active_card_limit VARCHAR2(5 BYTE),
  x_min_purch_amt VARCHAR2(10 BYTE),
  x_bus_org VARCHAR2(30 BYTE),
  x_biz_order_dtl_flag VARCHAR2(1 BYTE)
);
ALTER TABLE sa.table_x_cc_parms ADD SUPPLEMENTAL LOG GROUP dmtsora198393933_0 (objid, x_active_card_limit, x_bus_org, x_cc_esn_max, x_currency, x_eff_date, x_elapsed_time, x_ics_fraud_threshold, x_ignore_bad_cv, x_inv_alarm_threshold, x_max_purch_amt, x_max_purch_amt_per_month, x_max_trans_per_month, x_merchant_descriptor, x_merchant_descriptor_contact, x_merchant_id, x_min_purch_amt, x_notify, x_retries, x_score_category_gift, x_score_category_longterm, x_score_category_time, x_score_host_hedge, x_score_threshold, x_score_time_hedge, x_score_velocity_hedge, x_server_host, x_server_port, x_timeout, x_timeout_max) ALWAYS;
COMMENT ON TABLE sa.table_x_cc_parms IS 'holds parameters to govern operations of Cybersource Interface';
COMMENT ON COLUMN sa.table_x_cc_parms.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_x_cc_parms.x_eff_date IS 'This table uses effective-dated rows; rows wont be updated, new row inserted for any change';
COMMENT ON COLUMN sa.table_x_cc_parms.x_max_purch_amt IS 'preliminary fraud checking default';
COMMENT ON COLUMN sa.table_x_cc_parms.x_max_trans_per_month IS 'preliminary fraud checking default';
COMMENT ON COLUMN sa.table_x_cc_parms.x_max_purch_amt_per_month IS 'preliminary fraud checking default';
COMMENT ON COLUMN sa.table_x_cc_parms.x_timeout IS 'Threshold for request timeout - elapsed time (ie long)';
COMMENT ON COLUMN sa.table_x_cc_parms.x_retries IS 'number of times the CSR can push the "retries" button on form 1209 before the form closes automatically';
COMMENT ON COLUMN sa.table_x_cc_parms.x_merchant_id IS 'identifying ID for all Topp purchases through CyberSource';
COMMENT ON COLUMN sa.table_x_cc_parms.x_ignore_bad_cv IS 'eg =yes tells CyberSource to ignore CVV2 values when considering thresholds';
COMMENT ON COLUMN sa.table_x_cc_parms.x_currency IS 'eg =usd for US Dollars';
COMMENT ON COLUMN sa.table_x_cc_parms.x_server_host IS ' eg =ics2test.ic3.com   This is the address we"re sending requests to. Lets us toggle from test to live';
COMMENT ON COLUMN sa.table_x_cc_parms.x_server_port IS 'eg =8080 This is the port number we"re sending to.';
COMMENT ON COLUMN sa.table_x_cc_parms.x_ics_fraud_threshold IS 'requests that score above this number get rejected.  may use either Classic or IFS4 scale';
COMMENT ON COLUMN sa.table_x_cc_parms.x_merchant_descriptor IS 'displays on the customer s monthly cc_statement eg: Topp Telecom Prepaid Cellular Airtime Units';
COMMENT ON COLUMN sa.table_x_cc_parms.x_merchant_descriptor_contact IS 'displays on the customer s monthly cc_statement eg: call Topp Support 1-800-555-1212';
COMMENT ON COLUMN sa.table_x_cc_parms.x_score_threshold IS 'Acceptable level of risk for ordering each product';
COMMENT ON COLUMN sa.table_x_cc_parms.x_score_host_hedge IS 'eg =off - this checks the email and ipaddress, typically off for non-web requests';
COMMENT ON COLUMN sa.table_x_cc_parms.x_score_time_hedge IS 'eg - low,normal,high,off - sets concern based on time of day';
COMMENT ON COLUMN sa.table_x_cc_parms.x_score_velocity_hedge IS 'risk based on number of orders placed with this card within last 15 minutes. Low, Normal, High, Off';
COMMENT ON COLUMN sa.table_x_cc_parms.x_score_category_gift IS 'assess risk if the ship-to and bill-to addresses specify different states or countries. Yes or No';
COMMENT ON COLUMN sa.table_x_cc_parms.x_score_category_time IS 'normal, late, all, off -  expected hours for purchase of the item';
COMMENT ON COLUMN sa.table_x_cc_parms.x_score_category_longterm IS 'Monitor the purchase frequency of the merchant_product_sku - day, week, month, once, off';
COMMENT ON COLUMN sa.table_x_cc_parms.x_inv_alarm_threshold IS 'threshold for minimum desired count of rows in table_x_cc_red_inv';
COMMENT ON COLUMN sa.table_x_cc_parms.x_elapsed_time IS 'query will test all ETIMEOUTS in table_x_purch_hdr since this elapsed time';
COMMENT ON COLUMN sa.table_x_cc_parms.x_timeout_max IS 'timeout alarm: when timeout count exceeds this value within elapsed time, send email notification';
COMMENT ON COLUMN sa.table_x_cc_parms.x_notify IS 'name of the person who should be notified when the alarms exceed the thresholds';
COMMENT ON COLUMN sa.table_x_cc_parms.x_cc_esn_max IS '30-day maximum number of credit cards that can be used to buy airtime for the same ESN';
COMMENT ON COLUMN sa.table_x_cc_parms.x_ccparm_hist IS 'multi-line text for history of parameter';
COMMENT ON COLUMN sa.table_x_cc_parms.x_active_card_limit IS 'TBD';
COMMENT ON COLUMN sa.table_x_cc_parms.x_min_purch_amt IS 'TBD';
COMMENT ON COLUMN sa.table_x_cc_parms.x_bus_org IS 'Business Organization, should be unique';