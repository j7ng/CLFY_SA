CREATE TABLE sa.x_subscriber_status (
  subscriber_status_code VARCHAR2(3 BYTE) NOT NULL,
  description VARCHAR2(50 BYTE) NOT NULL,
  insert_timestamp DATE DEFAULT SYSDATE NOT NULL,
  update_timestamp DATE DEFAULT SYSDATE NOT NULL,
  CONSTRAINT x_subscriber_status_pk PRIMARY KEY (subscriber_status_code)
);
COMMENT ON TABLE sa.x_subscriber_status IS 'Stores the PCRF status code and description';
COMMENT ON COLUMN sa.x_subscriber_status.subscriber_status_code IS 'Stores different subscriber status';
COMMENT ON COLUMN sa.x_subscriber_status.description IS 'Description of subscriber status code';
COMMENT ON COLUMN sa.x_subscriber_status.insert_timestamp IS 'Time and date when the row was entered.';
COMMENT ON COLUMN sa.x_subscriber_status.update_timestamp IS 'Last date when the record was last modified';