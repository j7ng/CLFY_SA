CREATE TABLE sa.table_x_tracking_account (
  objid NUMBER,
  x_account_id VARCHAR2(20 BYTE),
  x_account_desc VARCHAR2(50 BYTE),
  x_acct_commmission NUMBER,
  x_commission_duration NUMBER,
  x_account_url VARCHAR2(100 BYTE)
);
ALTER TABLE sa.table_x_tracking_account ADD SUPPLEMENTAL LOG GROUP dmtsora784151431_0 (objid, x_account_desc, x_account_id, x_account_url, x_acct_commmission, x_commission_duration) ALWAYS;
COMMENT ON TABLE sa.table_x_tracking_account IS 'Contains the Account records for online tracking';
COMMENT ON COLUMN sa.table_x_tracking_account.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_x_tracking_account.x_account_id IS 'Account ID';
COMMENT ON COLUMN sa.table_x_tracking_account.x_account_desc IS 'Account Description';
COMMENT ON COLUMN sa.table_x_tracking_account.x_acct_commmission IS 'Whether the account has commission associated';
COMMENT ON COLUMN sa.table_x_tracking_account.x_commission_duration IS 'Duration for the account commission';
COMMENT ON COLUMN sa.table_x_tracking_account.x_account_url IS 'Account Url';