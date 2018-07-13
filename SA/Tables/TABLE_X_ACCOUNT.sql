CREATE TABLE sa.table_x_account (
  objid NUMBER,
  account2x_carrier NUMBER,
  x_acct_num VARCHAR2(32 BYTE),
  x_status VARCHAR2(20 BYTE)
);
ALTER TABLE sa.table_x_account ADD SUPPLEMENTAL LOG GROUP dmtsora1934476859_0 (account2x_carrier, objid, x_acct_num, x_status) ALWAYS;
COMMENT ON TABLE sa.table_x_account IS 'Stores information regarding accounts and its lines';
COMMENT ON COLUMN sa.table_x_account.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_x_account.x_acct_num IS 'Account number';
COMMENT ON COLUMN sa.table_x_account.x_status IS 'Added x_status 11/21/2000 by SL';