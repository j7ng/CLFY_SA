CREATE TABLE sa.x_tmobile_redemption_logs (
  objid NUMBER,
  creation_time DATE,
  triggering_event VARCHAR2(1000 BYTE),
  mdn VARCHAR2(100 BYTE),
  x_esn VARCHAR2(30 BYTE),
  x_iccid VARCHAR2(30 BYTE),
  api_status VARCHAR2(100 BYTE),
  message_status VARCHAR2(100 BYTE),
  update_date DATE,
  order_type VARCHAR2(30 BYTE)
);
COMMENT ON COLUMN sa.x_tmobile_redemption_logs.objid IS 'UNIQUE RECORD IDENTIFIER';
COMMENT ON COLUMN sa.x_tmobile_redemption_logs.creation_time IS 'TRANSACTION CREATION TIME';
COMMENT ON COLUMN sa.x_tmobile_redemption_logs.triggering_event IS 'PROGRAM ENROLLMENT ACTION TYPE';
COMMENT ON COLUMN sa.x_tmobile_redemption_logs.mdn IS 'MIN';
COMMENT ON COLUMN sa.x_tmobile_redemption_logs.x_esn IS 'ESN ASSOCIATED WITH MIN';
COMMENT ON COLUMN sa.x_tmobile_redemption_logs.x_iccid IS 'SIM';
COMMENT ON COLUMN sa.x_tmobile_redemption_logs.api_status IS 'STATUS OF API';
COMMENT ON COLUMN sa.x_tmobile_redemption_logs.message_status IS 'STATUS MESSAGE';
COMMENT ON COLUMN sa.x_tmobile_redemption_logs.update_date IS 'TRANSACTION COMPLETE DATE';
COMMENT ON COLUMN sa.x_tmobile_redemption_logs.order_type IS 'IG TRANSACTION ORDER TYPE';