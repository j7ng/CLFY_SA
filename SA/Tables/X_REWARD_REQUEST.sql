CREATE TABLE sa.x_reward_request (
  objid NUMBER NOT NULL,
  insert_timestamp DATE DEFAULT sysdate NOT NULL,
  update_timestamp DATE DEFAULT sysdate NOT NULL,
  web_user_objid NUMBER NOT NULL,
  benefit_earning_objid NUMBER,
  notification_id VARCHAR2(35 CHAR),
  notification_type VARCHAR2(50 CHAR),
  notification_date DATE,
  source_name VARCHAR2(35 CHAR),
  event_name VARCHAR2(100 CHAR),
  event_type VARCHAR2(50 CHAR),
  event_date DATE,
  event_id VARCHAR2(60 CHAR),
  event_status VARCHAR2(35 CHAR),
  amount NUMBER,
  denomination VARCHAR2(35 CHAR),
  request_received_date DATE,
  request_process_status VARCHAR2(35 CHAR),
  description VARCHAR2(250 CHAR),
  process_status_reason VARCHAR2(250 CHAR),
  CONSTRAINT x_reward_request_pk PRIMARY KEY (objid)
);
COMMENT ON TABLE sa.x_reward_request IS 'Captures 3rd party events/transactions request';
COMMENT ON COLUMN sa.x_reward_request.objid IS 'Primary Key';
COMMENT ON COLUMN sa.x_reward_request.insert_timestamp IS 'Record insertion date';
COMMENT ON COLUMN sa.x_reward_request.update_timestamp IS 'Record modified date';
COMMENT ON COLUMN sa.x_reward_request.web_user_objid IS 'Reference to objid of TABLE_WEB_USER';
COMMENT ON COLUMN sa.x_reward_request.benefit_earning_objid IS 'Reference to objid of X_REWARD_BENEFIT_EARNING';
COMMENT ON COLUMN sa.x_reward_request.notification_id IS 'External identifier for notification';
COMMENT ON COLUMN sa.x_reward_request.notification_type IS 'Type of notification';
COMMENT ON COLUMN sa.x_reward_request.notification_date IS 'Date-Time when the notification was generated';
COMMENT ON COLUMN sa.x_reward_request.source_name IS 'Source for this notification';
COMMENT ON COLUMN sa.x_reward_request.event_name IS 'Name of the event';
COMMENT ON COLUMN sa.x_reward_request.event_type IS 'Type of the event';
COMMENT ON COLUMN sa.x_reward_request.event_date IS 'Time when the event was generated';
COMMENT ON COLUMN sa.x_reward_request.event_id IS 'External systems event or transaction id';
COMMENT ON COLUMN sa.x_reward_request.event_status IS 'Status of the event';
COMMENT ON COLUMN sa.x_reward_request.amount IS 'Any quantity associated with the event';
COMMENT ON COLUMN sa.x_reward_request.denomination IS 'Currency for the amount passed.';
COMMENT ON COLUMN sa.x_reward_request.request_received_date IS 'Date time when the request received';
COMMENT ON COLUMN sa.x_reward_request.request_process_status IS 'Process status of the request received';
COMMENT ON COLUMN sa.x_reward_request.description IS 'Any custom description for the offer/event';
COMMENT ON COLUMN sa.x_reward_request.process_status_reason IS 'Reason for process status';