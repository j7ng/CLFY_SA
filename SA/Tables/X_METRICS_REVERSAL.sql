CREATE TABLE sa.x_metrics_reversal (
  objid NUMBER,
  x_esn VARCHAR2(30 BYTE),
  x_reason VARCHAR2(255 BYTE),
  x_reversal_date DATE,
  x_rule_category VARCHAR2(255 BYTE),
  x_sourcesystem VARCHAR2(30 BYTE),
  reversal2purch_hdr NUMBER,
  reversal2web_user NUMBER,
  reversal2prog_enrol NUMBER
);
ALTER TABLE sa.x_metrics_reversal ADD SUPPLEMENTAL LOG GROUP dmtsora263059691_0 (objid, reversal2prog_enrol, reversal2purch_hdr, reversal2web_user, x_esn, x_reason, x_reversal_date, x_rule_category, x_sourcesystem) ALWAYS;