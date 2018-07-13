CREATE TABLE sa.x_nonusage_comm (
  x_esn VARCHAR2(20 BYTE),
  x_exp_deact_date DATE,
  x_last_redemp_date DATE,
  x_last_call_date DATE,
  x_deact_type VARCHAR2(20 BYTE),
  x_product_line VARCHAR2(20 BYTE),
  x_membership_name VARCHAR2(50 BYTE),
  x_purpose VARCHAR2(50 BYTE),
  x_toss_cust_id VARCHAR2(20 BYTE),
  x_carrier_id NUMBER,
  x_deact_flag NUMBER,
  x_rundate DATE,
  x_load_date DATE
);