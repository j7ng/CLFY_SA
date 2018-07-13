CREATE TABLE sa.x_daily_acts_stg (
  objid NUMBER,
  x_service_id VARCHAR2(30 BYTE),
  ofs_cust_id VARCHAR2(30 BYTE)
);
ALTER TABLE sa.x_daily_acts_stg ADD SUPPLEMENTAL LOG GROUP dmtsora1659728459_0 (objid, ofs_cust_id, x_service_id) ALWAYS;