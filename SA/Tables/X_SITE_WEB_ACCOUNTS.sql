CREATE TABLE sa.x_site_web_accounts (
  objid NUMBER,
  site_web_acct2site NUMBER,
  site_web_acct2web_user NUMBER,
  site_web_acct2web_user_parent NUMBER,
  x_account_type VARCHAR2(25 BYTE),
  x_insert_date DATE,
  x_update_date DATE,
  batch_config_email VARCHAR2(1 BYTE),
  batch_config_payment VARCHAR2(1 BYTE),
  CONSTRAINT x_site_web_uniq UNIQUE (site_web_acct2web_user)
);
COMMENT ON TABLE sa.x_site_web_accounts IS 'Table having Organization web account information.';
COMMENT ON COLUMN sa.x_site_web_accounts.objid IS 'Internal record number.';
COMMENT ON COLUMN sa.x_site_web_accounts.site_web_acct2site IS 'table_site objid.';
COMMENT ON COLUMN sa.x_site_web_accounts.site_web_acct2web_user IS 'table_web_user objid.';
COMMENT ON COLUMN sa.x_site_web_accounts.site_web_acct2web_user_parent IS 'table_web_user parent objid, for future use.';
COMMENT ON COLUMN sa.x_site_web_accounts.x_account_type IS 'BUYER/BUYER Admin.';
COMMENT ON COLUMN sa.x_site_web_accounts.x_insert_date IS 'Sysdate, date when record is created.';
COMMENT ON COLUMN sa.x_site_web_accounts.x_update_date IS 'Sysdate, date when record is updated.';
COMMENT ON COLUMN sa.x_site_web_accounts.batch_config_email IS 'Override flag to send batch notification emails instead of real time';
COMMENT ON COLUMN sa.x_site_web_accounts.batch_config_payment IS 'Override flag to process batch payments instead of real time';