CREATE TABLE sa.x_rebate_referral_info (
  coupon_ref_no VARCHAR2(50 BYTE) NOT NULL,
  batch_no VARCHAR2(50 BYTE),
  first_name VARCHAR2(30 BYTE),
  last_name VARCHAR2(30 BYTE),
  address VARCHAR2(200 BYTE),
  city VARCHAR2(30 BYTE),
  "STATE" VARCHAR2(40 BYTE),
  zip VARCHAR2(20 BYTE),
  country VARCHAR2(80 BYTE),
  email VARCHAR2(80 BYTE),
  phone VARCHAR2(30 BYTE),
  esn VARCHAR2(30 BYTE),
  esn_referred VARCHAR2(30 BYTE),
  pin_code VARCHAR2(30 BYTE),
  activate_date DATE,
  offer VARCHAR2(100 BYTE),
  offer_type VARCHAR2(30 BYTE),
  promotion_type VARCHAR2(30 BYTE),
  dealer_objid NUMBER,
  dealer_id VARCHAR2(80 BYTE),
  dealer_name VARCHAR2(80 BYTE),
  part_number VARCHAR2(30 BYTE),
  status VARCHAR2(50 BYTE),
  refurb_esn CHAR,
  times_processed NUMBER,
  coupon_create_date DATE,
  rec_create_date DATE,
  last_update_date DATE,
  processed_date DATE
);
ALTER TABLE sa.x_rebate_referral_info ADD SUPPLEMENTAL LOG GROUP dmtsora926688192_0 (activate_date, address, batch_no, city, country, coupon_create_date, coupon_ref_no, dealer_id, dealer_name, dealer_objid, email, esn, esn_referred, first_name, last_name, last_update_date, offer, offer_type, part_number, phone, pin_code, processed_date, promotion_type, rec_create_date, refurb_esn, "STATE", status, times_processed, zip) ALWAYS;