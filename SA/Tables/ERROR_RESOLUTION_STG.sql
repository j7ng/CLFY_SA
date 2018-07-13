CREATE TABLE sa.error_resolution_stg (
  esn VARCHAR2(30 BYTE),
  reason VARCHAR2(2000 BYTE),
  insert_date DATE,
  login_name VARCHAR2(50 BYTE),
  invoked_by VARCHAR2(100 BYTE),
  log_type VARCHAR2(10 BYTE),
  brand VARCHAR2(75 BYTE)
);