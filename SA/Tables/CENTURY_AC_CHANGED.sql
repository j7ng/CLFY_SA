CREATE TABLE sa.century_ac_changed (
  esn VARCHAR2(30 BYTE),
  line VARCHAR2(30 BYTE),
  dealer_code VARCHAR2(30 BYTE),
  voicemail VARCHAR2(30 BYTE),
  vm_code VARCHAR2(30 BYTE),
  call_waiting VARCHAR2(30 BYTE),
  cw_code VARCHAR2(30 BYTE),
  rate_plan VARCHAR2(30 BYTE),
  acct_no VARCHAR2(30 BYTE),
  market_code VARCHAR2(30 BYTE),
  insert_date DATE,
  modify_date DATE,
  email_request_id NUMBER
);
ALTER TABLE sa.century_ac_changed ADD SUPPLEMENTAL LOG GROUP dmtsora1412570557_0 (acct_no, call_waiting, cw_code, dealer_code, email_request_id, esn, insert_date, line, market_code, modify_date, rate_plan, vm_code, voicemail) ALWAYS;