CREATE TABLE sa.error_log_stg (
  x_esn VARCHAR2(30 BYTE),
  "ERROR" VARCHAR2(2000 BYTE),
  insert_date DATE,
  login_name VARCHAR2(50 BYTE),
  fix VARCHAR2(2000 BYTE)
);