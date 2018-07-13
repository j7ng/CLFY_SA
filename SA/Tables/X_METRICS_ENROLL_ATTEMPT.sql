CREATE TABLE sa.x_metrics_enroll_attempt (
  objid NUMBER,
  x_esn VARCHAR2(30 BYTE),
  x_session_id VARCHAR2(100 BYTE),
  x_attempt_date DATE,
  x_reason VARCHAR2(255 BYTE),
  enroll_atp2prog_param NUMBER,
  enroll_atp2web_user NUMBER,
  enroll_atp2purch_hdr NUMBER
);
ALTER TABLE sa.x_metrics_enroll_attempt ADD SUPPLEMENTAL LOG GROUP dmtsora881826219_0 (enroll_atp2prog_param, enroll_atp2purch_hdr, enroll_atp2web_user, objid, x_attempt_date, x_esn, x_reason, x_session_id) ALWAYS;