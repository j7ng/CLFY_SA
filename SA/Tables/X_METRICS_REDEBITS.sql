CREATE TABLE sa.x_metrics_redebits (
  objid NUMBER,
  x_esn VARCHAR2(30 BYTE),
  x_reason VARCHAR2(255 BYTE),
  x_redebit_date DATE,
  x_rule_category VARCHAR2(255 BYTE),
  redebit2purch_hdr NUMBER,
  redebit2web_user NUMBER,
  redebit2prog_enrol NUMBER
);
ALTER TABLE sa.x_metrics_redebits ADD SUPPLEMENTAL LOG GROUP dmtsora970347821_0 (objid, redebit2prog_enrol, redebit2purch_hdr, redebit2web_user, x_esn, x_reason, x_redebit_date, x_rule_category) ALWAYS;