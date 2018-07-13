CREATE TABLE sa.x_dbms_jobs_tracking (
  what VARCHAR2(4000 BYTE),
  last_date DATE,
  failures NUMBER,
  "INTERVAL" VARCHAR2(200 BYTE) NOT NULL
);
ALTER TABLE sa.x_dbms_jobs_tracking ADD SUPPLEMENTAL LOG GROUP dmtsora2055572239_0 (failures, "INTERVAL", last_date, what) ALWAYS;