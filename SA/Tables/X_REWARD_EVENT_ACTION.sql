CREATE TABLE sa.x_reward_event_action (
  objid NUMBER NOT NULL,
  event_type VARCHAR2(80 BYTE) NOT NULL,
  transaction_type VARCHAR2(40 BYTE) NOT NULL,
  "ACTION" VARCHAR2(50 BYTE) DEFAULT 'N/A',
  action_type VARCHAR2(50 BYTE) DEFAULT 'N/A',
  transaction_desc VARCHAR2(200 BYTE) DEFAULT 'N/A',
  CONSTRAINT evt_act_objid_pk PRIMARY KEY (objid)
);
COMMENT ON TABLE sa.x_reward_event_action IS 'Table will contain action details for all LRP events';
COMMENT ON COLUMN sa.x_reward_event_action.objid IS 'Unique row identifier';
COMMENT ON COLUMN sa.x_reward_event_action.event_type IS 'Type of Event ';
COMMENT ON COLUMN sa.x_reward_event_action.transaction_type IS 'Transaction type ';
COMMENT ON COLUMN sa.x_reward_event_action."ACTION" IS 'Action';
COMMENT ON COLUMN sa.x_reward_event_action.action_type IS 'Action type';
COMMENT ON COLUMN sa.x_reward_event_action.transaction_desc IS 'Transaction description';