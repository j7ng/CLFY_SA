CREATE TABLE sa.x_pageplus_subscriber_action (
  action_code VARCHAR2(20 BYTE) NOT NULL,
  description VARCHAR2(400 BYTE),
  insert_flag VARCHAR2(1 BYTE) CONSTRAINT subscriber_action_c1 CHECK (INSERT_FLAG IN ('Y', 'N')),
  update_flag VARCHAR2(1 BYTE) CONSTRAINT subscriber_action_c2 CHECK (UPDATE_FLAG IN ('Y', 'N')),
  delete_flag VARCHAR2(1 BYTE) CONSTRAINT subscriber_action_c3 CHECK (DELETE_FLAG IN ('Y', 'N')),
  redemption_flag VARCHAR2(1 BYTE) CONSTRAINT subscriber_action_c4 CHECK (REDEMPTION_FLAG IN ('Y', 'N')),
  insert_timestamp DATE DEFAULT SYSDATE NOT NULL,
  update_timestamp DATE DEFAULT SYSDATE NOT NULL,
  ttoff_flag VARCHAR2(1 BYTE) DEFAULT 'N',
  ttoff_chk_red_dt_flag VARCHAR2(1 BYTE) DEFAULT 'N',
  CONSTRAINT subscriber_action_pk PRIMARY KEY (action_code)
);
COMMENT ON TABLE sa.x_pageplus_subscriber_action IS 'Look up table to define Insert/Update/Delete from subscriber table';
COMMENT ON COLUMN sa.x_pageplus_subscriber_action.action_code IS 'This will be compared with value passed by WS';
COMMENT ON COLUMN sa.x_pageplus_subscriber_action.description IS 'Short description of the action code';
COMMENT ON COLUMN sa.x_pageplus_subscriber_action.insert_flag IS '"Y" signifies subsriber record needs saved';
COMMENT ON COLUMN sa.x_pageplus_subscriber_action.update_flag IS '"Y" signifies subsriber record needs updated';
COMMENT ON COLUMN sa.x_pageplus_subscriber_action.delete_flag IS '"Y" signifies redemption flow';
COMMENT ON COLUMN sa.x_pageplus_subscriber_action.insert_timestamp IS 'Date when the record was created';
COMMENT ON COLUMN sa.x_pageplus_subscriber_action.update_timestamp IS 'Last date when the record was last modified';