CREATE TABLE sa.x_queue_event_log_status (
  queue_event_log_status VARCHAR2(1 BYTE) NOT NULL,
  description VARCHAR2(100 BYTE) NOT NULL,
  insert_timestamp DATE DEFAULT SYSDATE NOT NULL,
  update_timestamp DATE DEFAULT SYSDATE NOT NULL,
  CONSTRAINT pk_queue_event_log_status PRIMARY KEY (queue_event_log_status)
);
COMMENT ON TABLE sa.x_queue_event_log_status IS 'Configuraion table for the AQ event log statuses';
COMMENT ON COLUMN sa.x_queue_event_log_status.queue_event_log_status IS 'AQ event log status';
COMMENT ON COLUMN sa.x_queue_event_log_status.description IS 'AQ event log status description';