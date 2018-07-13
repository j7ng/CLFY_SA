CREATE TABLE sa.table_x_bank_account_migr (
  objid NUMBER,
  old_x_customer_acct VARCHAR2(30 BYTE),
  old_x_routing VARCHAR2(20 BYTE),
  old_bank_acct_and_rout_no VARCHAR2(51 BYTE),
  x_customer_acct_new VARCHAR2(400 BYTE),
  x_customer_acct_key_new VARCHAR2(400 BYTE),
  x_customer_acct_enc_new VARCHAR2(400 BYTE),
  bank2cert NUMBER,
  status VARCHAR2(10 BYTE) DEFAULT 'Q',
  creation_date DATE DEFAULT sysdate,
  last_updated_date DATE,
  x_uid_new VARCHAR2(255 BYTE),
  error_message VARCHAR2(1000 BYTE)
);