CREATE TABLE sa.deployment_tracking_0208_2100 (
  cr VARCHAR2(30 BYTE),
  script VARCHAR2(100 BYTE),
  "TAG" VARCHAR2(30 BYTE),
  expected_rev VARCHAR2(30 BYTE),
  deployed_rev VARCHAR2(100 BYTE),
  deployed_time DATE,
  deployed_by VARCHAR2(30 BYTE)
);