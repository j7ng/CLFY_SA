CREATE TABLE sa.xsu_solix_response (
  responseto VARCHAR2(20 BYTE),
  requestid VARCHAR2(50 BYTE),
  firstname VARCHAR2(100 BYTE),
  lastname VARCHAR2(100 BYTE),
  middlename VARCHAR2(100 BYTE),
  homenumber VARCHAR2(50 BYTE),
  address VARCHAR2(200 BYTE),
  city VARCHAR2(100 BYTE),
  zip VARCHAR2(20 BYTE),
  "ACCOUNT" VARCHAR2(100 BYTE),
  match_code VARCHAR2(50 BYTE),
  x_error NUMBER,
  batchdate DATE
);