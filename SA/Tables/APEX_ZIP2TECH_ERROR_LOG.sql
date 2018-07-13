CREATE TABLE sa.apex_zip2tech_error_log (
  assoc_bkp NUMBER,
  db VARCHAR2(30 BYTE),
  user_name VARCHAR2(50 BYTE),
  log_date DATE,
  zip VARCHAR2(5 BYTE),
  "STATE" VARCHAR2(2 BYTE),
  county VARCHAR2(50 BYTE),
  pref1 VARCHAR2(20 BYTE),
  pref2 VARCHAR2(20 BYTE),
  service VARCHAR2(20 BYTE),
  language VARCHAR2(2 BYTE),
  sitetype VARCHAR2(30 BYTE),
  techkey VARCHAR2(20 BYTE),
  err_summary VARCHAR2(4000 BYTE)
);