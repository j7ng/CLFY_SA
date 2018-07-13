CREATE TABLE sa.x_sm_web_accounts (
  web_user_objid NUMBER NOT NULL,
  web_contact_objid NUMBER,
  esn VARCHAR2(30 BYTE) NOT NULL,
  esn_contact_objid NUMBER,
  insert_timestamp DATE DEFAULT SYSDATE,
  update_timestamp DATE,
  processed_status VARCHAR2(100 BYTE) DEFAULT 'PENDING',
  CONSTRAINT pk_sm_web_accounts PRIMARY KEY (web_user_objid,esn)
);
COMMENT ON TABLE sa.x_sm_web_accounts IS 'Table to store Simple Mobile Web Accounts';
COMMENT ON COLUMN sa.x_sm_web_accounts.web_user_objid IS 'Web user objid';
COMMENT ON COLUMN sa.x_sm_web_accounts.web_contact_objid IS 'Web contact objid';
COMMENT ON COLUMN sa.x_sm_web_accounts.esn IS 'ESN';
COMMENT ON COLUMN sa.x_sm_web_accounts.esn_contact_objid IS 'ESN contact objid';
COMMENT ON COLUMN sa.x_sm_web_accounts.insert_timestamp IS 'Record inserted timestamp';
COMMENT ON COLUMN sa.x_sm_web_accounts.update_timestamp IS 'Record updated timestamp';
COMMENT ON COLUMN sa.x_sm_web_accounts.processed_status IS 'Status';