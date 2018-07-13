CREATE TABLE sa.x_reward_bonus_points_load (
  objid NUMBER NOT NULL,
  web_account_id VARCHAR2(30 BYTE),
  subscriber_id VARCHAR2(30 BYTE),
  "MIN" VARCHAR2(30 BYTE),
  esn VARCHAR2(30 BYTE),
  points VARCHAR2(9 BYTE),
  "ACTION" VARCHAR2(10 BYTE),
  reason VARCHAR2(2000 BYTE),
  benefit_type VARCHAR2(100 BYTE),
  load_dt DATE,
  status VARCHAR2(40 BYTE),
  error_msg VARCHAR2(4000 BYTE),
  CONSTRAINT bns_pnt_objid_pk PRIMARY KEY (objid)
);
COMMENT ON TABLE sa.x_reward_bonus_points_load IS 'Table will contain list of Account/min/esn loaded from Add Points Job for LRP';
COMMENT ON COLUMN sa.x_reward_bonus_points_load.objid IS 'Unique row identifier';
COMMENT ON COLUMN sa.x_reward_bonus_points_load.web_account_id IS 'ACCOUNT ID of the customer';
COMMENT ON COLUMN sa.x_reward_bonus_points_load.subscriber_id IS 'SUBSCRIBER ID of the customer';
COMMENT ON COLUMN sa.x_reward_bonus_points_load."MIN" IS 'MIN of the customer';
COMMENT ON COLUMN sa.x_reward_bonus_points_load.esn IS 'ESN of the customer';
COMMENT ON COLUMN sa.x_reward_bonus_points_load.points IS 'number of points to be added to customer';
COMMENT ON COLUMN sa.x_reward_bonus_points_load."ACTION" IS 'Reason for providing bonus points ';
COMMENT ON COLUMN sa.x_reward_bonus_points_load.load_dt IS 'Load Date ';
COMMENT ON COLUMN sa.x_reward_bonus_points_load.status IS 'Status of the record. FAIL/SUCCESS/NULL ';