CREATE TABLE sa.x_program_deact_pend (
  objid NUMBER,
  x_esn VARCHAR2(30 BYTE),
  x_deact_date DATE,
  x_deact_reason VARCHAR2(500 BYTE),
  x_deact_status VARCHAR2(20 BYTE),
  x_rule_cat VARCHAR2(255 BYTE) NOT NULL,
  deact_pend2prog_enroll NUMBER NOT NULL,
  deact_pend2web_user NUMBER NOT NULL,
  deact_pend2prog_parm NUMBER NOT NULL
);
ALTER TABLE sa.x_program_deact_pend ADD SUPPLEMENTAL LOG GROUP dmtsora1141972821_0 (deact_pend2prog_enroll, deact_pend2prog_parm, deact_pend2web_user, objid, x_deact_date, x_deact_reason, x_deact_status, x_esn, x_rule_cat) ALWAYS;