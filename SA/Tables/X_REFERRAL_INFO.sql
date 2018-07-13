CREATE TABLE sa.x_referral_info (
  "BATCH" VARCHAR2(50 BYTE),
  "TRANSACTION" VARCHAR2(50 BYTE),
  first_name VARCHAR2(30 BYTE),
  last_name VARCHAR2(30 BYTE),
  address1 VARCHAR2(200 BYTE),
  address2 VARCHAR2(200 BYTE),
  city VARCHAR2(30 BYTE),
  "STATE" VARCHAR2(40 BYTE),
  zip VARCHAR2(20 BYTE),
  offer VARCHAR2(100 BYTE),
  enter_date DATE,
  deal_objid NUMBER,
  deal_name VARCHAR2(80 BYTE),
  deal_id VARCHAR2(80 BYTE),
  esn VARCHAR2(30 BYTE),
  esn_referred VARCHAR2(30 BYTE),
  status VARCHAR2(50 BYTE),
  red_code VARCHAR2(30 BYTE),
  receive_date DATE,
  times_processed NUMBER(7),
  esn_referred_act_date DATE
);
ALTER TABLE sa.x_referral_info ADD SUPPLEMENTAL LOG GROUP dmtsora1549404823_0 (address1, address2, "BATCH", city, deal_id, deal_name, deal_objid, enter_date, esn, esn_referred, esn_referred_act_date, first_name, last_name, offer, receive_date, red_code, "STATE", status, times_processed, "TRANSACTION", zip) ALWAYS;