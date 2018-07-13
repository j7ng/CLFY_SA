CREATE TABLE sa.tmobile_lines (
  msisdn VARCHAR2(30 BYTE),
  imei VARCHAR2(30 BYTE),
  status VARCHAR2(30 BYTE),
  status_date DATE,
  sim VARCHAR2(30 BYTE),
  line_status VARCHAR2(30 BYTE),
  current_parent VARCHAR2(200 BYTE),
  updated_parent VARCHAR2(30 BYTE),
  update_yn VARCHAR2(30 BYTE)
);
ALTER TABLE sa.tmobile_lines ADD SUPPLEMENTAL LOG GROUP dmtsora1947424598_0 (current_parent, imei, line_status, msisdn, sim, status, status_date, updated_parent, update_yn) ALWAYS;