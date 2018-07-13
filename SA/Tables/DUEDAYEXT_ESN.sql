CREATE TABLE sa.duedayext_esn (
  esn VARCHAR2(30 BYTE),
  cust_id VARCHAR2(50 BYTE),
  phone_id VARCHAR2(50 BYTE),
  first_name VARCHAR2(50 BYTE),
  last_name VARCHAR2(50 BYTE),
  home_phone VARCHAR2(50 BYTE),
  email VARCHAR2(50 BYTE),
  red_date DATE,
  expect_deact_date DATE,
  days_until_deact NUMBER,
  correct_due_date DATE,
  updt_yn VARCHAR2(20 BYTE),
  updt_dt DATE
);
ALTER TABLE sa.duedayext_esn ADD SUPPLEMENTAL LOG GROUP dmtsora1810042329_0 (correct_due_date, cust_id, days_until_deact, email, esn, expect_deact_date, first_name, home_phone, last_name, phone_id, red_date, updt_dt, updt_yn) ALWAYS;