CREATE TABLE sa.table_cl_result (
  objid NUMBER,
  dev NUMBER,
  create_date DATE,
  exec_log LONG,
  focus_type NUMBER,
  focus_lowid NUMBER,
  rule_rank NUMBER,
  action_rank NUMBER,
  action_auto_exec NUMBER,
  rule_confidence NUMBER,
  action_type NUMBER,
  cl_result2cl_action NUMBER,
  cl_result2template NUMBER
);
ALTER TABLE sa.table_cl_result ADD SUPPLEMENTAL LOG GROUP dmtsora606268779_0 (action_auto_exec, action_rank, action_type, cl_result2cl_action, cl_result2template, create_date, dev, focus_lowid, focus_type, objid, rule_confidence, rule_rank) ALWAYS;