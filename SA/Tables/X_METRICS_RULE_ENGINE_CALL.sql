CREATE TABLE sa.x_metrics_rule_engine_call (
  objid NUMBER,
  x_call_date DATE,
  x_rule_category VARCHAR2(255 BYTE),
  call2rule_create NUMBER,
  x_rule_set_name VARCHAR2(255 BYTE),
  x_rule_set_desc VARCHAR2(255 BYTE),
  x_paynow_exec_flag NUMBER(1)
);
ALTER TABLE sa.x_metrics_rule_engine_call ADD SUPPLEMENTAL LOG GROUP dmtsora1058869424_0 (call2rule_create, objid, x_call_date, x_paynow_exec_flag, x_rule_category, x_rule_set_desc, x_rule_set_name) ALWAYS;