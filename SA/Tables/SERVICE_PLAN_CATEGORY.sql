CREATE TABLE sa.service_plan_category (
  service_plan_category VARCHAR2(50 BYTE) NOT NULL,
  bus_org_id VARCHAR2(50 BYTE) NOT NULL,
  script1 VARCHAR2(50 BYTE),
  script2 VARCHAR2(50 BYTE),
  script3 VARCHAR2(50 BYTE),
  script4 VARCHAR2(50 BYTE),
  script5 VARCHAR2(50 BYTE),
  script6 VARCHAR2(50 BYTE),
  script7 VARCHAR2(50 BYTE),
  script8 VARCHAR2(50 BYTE),
  script9 VARCHAR2(50 BYTE),
  script10 VARCHAR2(50 BYTE),
  PRIMARY KEY (service_plan_category,bus_org_id)
);