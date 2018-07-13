CREATE TABLE sa.x_cingular_mrkt_info_bkup (
  mkt VARCHAR2(20 BYTE),
  npa VARCHAR2(20 BYTE),
  nxx VARCHAR2(20 BYTE),
  npanxx VARCHAR2(20 BYTE),
  rc_number VARCHAR2(20 BYTE),
  rc_name VARCHAR2(20 BYTE),
  rc_state VARCHAR2(20 BYTE),
  zip VARCHAR2(20 BYTE),
  mkt_type VARCHAR2(20 BYTE),
  account_num VARCHAR2(30 BYTE),
  market_code VARCHAR2(30 BYTE),
  dealer_code VARCHAR2(30 BYTE),
  submarketid VARCHAR2(30 BYTE)
);
ALTER TABLE sa.x_cingular_mrkt_info_bkup ADD SUPPLEMENTAL LOG GROUP dmtsora782271387_0 (account_num, dealer_code, market_code, mkt, mkt_type, npa, npanxx, nxx, rc_name, rc_number, rc_state, submarketid, zip) ALWAYS;