CREATE TABLE sa.x_rpt_red2 (
  action_type VARCHAR2(30 BYTE),
  promo_objid NUMBER,
  promo_code VARCHAR2(30 BYTE),
  esn VARCHAR2(30 BYTE),
  esn_po_number VARCHAR2(30 BYTE),
  cellnum VARCHAR2(30 BYTE),
  cellnum_account_num VARCHAR2(32 BYTE),
  cellnum_insert_date DATE,
  redemption_date DATE,
  card_smp VARCHAR2(30 BYTE),
  card_number VARCHAR2(30 BYTE),
  card_units NUMBER,
  card_access NUMBER,
  activation_date DATE,
  activation_zipcode VARCHAR2(20 BYTE),
  call_trans_objid NUMBER,
  sourcesystem VARCHAR2(30 BYTE),
  carrier_objid NUMBER,
  carrier_id NUMBER,
  carrier_mkt_name VARCHAR2(30 BYTE),
  carrier_mkt_address NUMBER,
  carrier_mkt_add1 VARCHAR2(200 BYTE),
  carrier_mkt_add2 VARCHAR2(200 BYTE),
  carrier_mkt_city VARCHAR2(30 BYTE),
  carrier_mkt_state VARCHAR2(40 BYTE),
  carrier_mkt_zip VARCHAR2(20 BYTE),
  carrier_grp_objid NUMBER,
  carrier_grp_id NUMBER,
  carrier_grp_name VARCHAR2(30 BYTE),
  carrier_grp_address_objid NUMBER,
  carrier_grp_add1 VARCHAR2(200 BYTE),
  carrier_grp_add2 VARCHAR2(200 BYTE),
  carrier_grp_city VARCHAR2(30 BYTE),
  carrier_grp_state VARCHAR2(40 BYTE),
  carrier_grp_zip VARCHAR2(20 BYTE),
  user_objid NUMBER,
  user_login_name VARCHAR2(30 BYTE),
  user_first_name VARCHAR2(30 BYTE),
  user_last_name VARCHAR2(30 BYTE),
  cust_first_name VARCHAR2(30 BYTE),
  cust_last_name VARCHAR2(30 BYTE),
  cust_add1 VARCHAR2(200 BYTE),
  cust_add2 VARCHAR2(200 BYTE),
  cust_city VARCHAR2(30 BYTE),
  cust_state VARCHAR2(40 BYTE),
  cust_zip VARCHAR2(20 BYTE),
  cust_home_phone VARCHAR2(20 BYTE),
  card_dealer_objid NUMBER,
  card_dealer_id VARCHAR2(80 BYTE),
  card_dealer_name VARCHAR2(80 BYTE),
  card_part_number_objid NUMBER,
  card_part_number VARCHAR2(30 BYTE),
  card_part_number_description VARCHAR2(255 BYTE),
  dealer_objid NUMBER,
  esn_dealer_id VARCHAR2(80 BYTE),
  esn_dealer_name VARCHAR2(80 BYTE),
  esn_part_number_objid NUMBER,
  esn_part_number VARCHAR2(30 BYTE),
  esn_part_number_description VARCHAR2(255 BYTE),
  click_plan_id NUMBER,
  personality_id NUMBER
);
ALTER TABLE sa.x_rpt_red2 ADD SUPPLEMENTAL LOG GROUP dmtsora2117133394_1 (card_dealer_id, card_dealer_name, card_dealer_objid, card_part_number, card_part_number_description, card_part_number_objid, carrier_grp_state, carrier_grp_zip, click_plan_id, cust_add1, cust_add2, cust_city, cust_first_name, cust_home_phone, cust_last_name, cust_state, cust_zip, dealer_objid, esn_dealer_id, esn_dealer_name, esn_part_number, esn_part_number_description, esn_part_number_objid, personality_id, user_first_name, user_last_name, user_login_name, user_objid) ALWAYS;
ALTER TABLE sa.x_rpt_red2 ADD SUPPLEMENTAL LOG GROUP dmtsora2117133394_0 (action_type, activation_date, activation_zipcode, call_trans_objid, card_access, card_number, card_smp, card_units, carrier_grp_add1, carrier_grp_add2, carrier_grp_address_objid, carrier_grp_city, carrier_grp_id, carrier_grp_name, carrier_grp_objid, carrier_id, carrier_mkt_add1, carrier_mkt_add2, carrier_mkt_address, carrier_mkt_city, carrier_mkt_name, carrier_mkt_state, carrier_mkt_zip, carrier_objid, cellnum, cellnum_account_num, cellnum_insert_date, esn, esn_po_number, promo_code, promo_objid, redemption_date, sourcesystem) ALWAYS;