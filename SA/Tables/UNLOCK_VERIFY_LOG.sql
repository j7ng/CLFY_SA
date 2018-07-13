CREATE TABLE sa.unlock_verify_log (
  esn VARCHAR2(30 BYTE),
  mdn VARCHAR2(30 BYTE),
  time_stamp TIMESTAMP DEFAULT systimestamp,
  check_result VARCHAR2(100 BYTE),
  trade_value NUMBER,
  paid_days NUMBER,
  active_days NUMBER,
  err_code VARCHAR2(20 BYTE),
  err_msg VARCHAR2(100 BYTE),
  login_name VARCHAR2(50 BYTE),
  overwrite VARCHAR2(10 BYTE)
);