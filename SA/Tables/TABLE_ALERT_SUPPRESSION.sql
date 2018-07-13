CREATE TABLE sa.table_alert_suppression (
  x_esn VARCHAR2(30 BYTE),
  alert_objid NUMBER,
  agent_id VARCHAR2(4000 BYTE),
  creation_date DATE
);
COMMENT ON COLUMN sa.table_alert_suppression.x_esn IS 'The ESN to be suppressed ';
COMMENT ON COLUMN sa.table_alert_suppression.alert_objid IS 'The date the alert was suppressed ';
COMMENT ON COLUMN sa.table_alert_suppression.agent_id IS 'The agent id that suppressed the alert ';