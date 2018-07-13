CREATE TABLE sa.x_deact_reason_config (
  objid NUMBER(38) NOT NULL,
  deact_reason VARCHAR2(100 BYTE) NOT NULL,
  min_status_code VARCHAR2(100 BYTE),
  esn_status_code VARCHAR2(2 BYTE),
  sim_status_code VARCHAR2(100 BYTE),
  expire_member_flag VARCHAR2(1 BYTE) DEFAULT 'N',
  expire_subscriber_flag VARCHAR2(1 BYTE) DEFAULT 'N',
  insert_timestamp DATE DEFAULT SYSDATE NOT NULL,
  update_timestamp DATE DEFAULT SYSDATE NOT NULL,
  brm_notification_flag VARCHAR2(1 BYTE),
  brm_order_type VARCHAR2(1 BYTE),
  sim_status_tmo VARCHAR2(100 BYTE),
  sim_status_att VARCHAR2(100 BYTE),
  sim_status_vrz VARCHAR2(100 BYTE),
  CONSTRAINT pk_deact_reason_config PRIMARY KEY (objid)
);
COMMENT ON TABLE sa.x_deact_reason_config IS 'table to configure deactivation reasons';
COMMENT ON COLUMN sa.x_deact_reason_config.objid IS 'Unique record identifier';
COMMENT ON COLUMN sa.x_deact_reason_config.deact_reason IS 'Deactivation reason';
COMMENT ON COLUMN sa.x_deact_reason_config.brm_notification_flag IS 'Column that indiactes for which deactivation reasons BRM should be notified';
COMMENT ON COLUMN sa.x_deact_reason_config.brm_order_type IS 'BRM order type';