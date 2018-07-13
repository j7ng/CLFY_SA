CREATE TABLE sa.report_cc_app (
  db CHAR(8 BYTE),
  "COUNT" NUMBER,
  x_rqst_source VARCHAR2(20 BYTE),
  x_rqst_type VARCHAR2(20 BYTE),
  x_auth_rmsg VARCHAR2(60 BYTE),
  x_ics_rmsg VARCHAR2(255 BYTE),
  hour_date DATE
);