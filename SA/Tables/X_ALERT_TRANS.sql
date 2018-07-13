CREATE TABLE sa.x_alert_trans (
  objid NUMBER,
  x_sys_name VARCHAR2(100 BYTE),
  x_issue VARCHAR2(255 BYTE),
  x_excep_msg VARCHAR2(4000 BYTE),
  x_issue_date DATE,
  x_severity NUMBER
);
ALTER TABLE sa.x_alert_trans ADD SUPPLEMENTAL LOG GROUP dmtsora6863193_0 (objid, x_excep_msg, x_issue, x_issue_date, x_severity, x_sys_name) ALWAYS;
COMMENT ON TABLE sa.x_alert_trans IS 'Billing System Monitoring Alerts Log, stores details of major problems occured in the billing systems.';
COMMENT ON COLUMN sa.x_alert_trans.objid IS 'Internal Record ID';
COMMENT ON COLUMN sa.x_alert_trans.x_sys_name IS 'System or Subsystem Name';
COMMENT ON COLUMN sa.x_alert_trans.x_issue IS 'Issue';
COMMENT ON COLUMN sa.x_alert_trans.x_excep_msg IS 'Exception Message';
COMMENT ON COLUMN sa.x_alert_trans.x_issue_date IS 'Issue Timestamp';
COMMENT ON COLUMN sa.x_alert_trans.x_severity IS 'Severity Level';