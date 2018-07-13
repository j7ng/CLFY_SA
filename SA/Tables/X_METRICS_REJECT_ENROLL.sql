CREATE TABLE sa.x_metrics_reject_enroll (
  objid NUMBER,
  x_esn VARCHAR2(30 BYTE),
  x_reject_date DATE,
  x_reject_reason VARCHAR2(500 BYTE),
  x_rule_cat VARCHAR2(255 BYTE),
  reject_enrol2web_user NUMBER,
  reject_enrol2prog_param NUMBER
);
ALTER TABLE sa.x_metrics_reject_enroll ADD SUPPLEMENTAL LOG GROUP dmtsora808242402_0 (objid, reject_enrol2prog_param, reject_enrol2web_user, x_esn, x_reject_date, x_reject_reason, x_rule_cat) ALWAYS;