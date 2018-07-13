CREATE TABLE sa.table_x_bank_account (
  objid NUMBER,
  x_bank_num VARCHAR2(30 BYTE),
  x_customer_acct VARCHAR2(400 BYTE) NOT NULL,
  x_routing VARCHAR2(400 BYTE),
  x_aba_transit VARCHAR2(30 BYTE),
  x_bank_name VARCHAR2(20 BYTE),
  x_status VARCHAR2(10 BYTE),
  x_customer_firstname VARCHAR2(20 BYTE),
  x_customer_lastname VARCHAR2(20 BYTE),
  x_customer_phone VARCHAR2(20 BYTE),
  x_customer_email VARCHAR2(50 BYTE),
  x_max_purch_amt NUMBER,
  x_max_trans_per_month NUMBER,
  x_max_purch_amt_per_month NUMBER,
  x_changedate DATE,
  x_original_insert_date DATE,
  x_changedby VARCHAR2(20 BYTE),
  x_cc_comments LONG,
  x_moms_maiden VARCHAR2(20 BYTE),
  x_bank_acct2contact NUMBER,
  x_bank_acct2address NUMBER,
  x_bank_account2bus_org NUMBER,
  bank2cert NUMBER,
  x_customer_acct_key VARCHAR2(400 BYTE),
  x_customer_acct_enc VARCHAR2(400 BYTE)
);
ALTER TABLE sa.table_x_bank_account ADD SUPPLEMENTAL LOG GROUP dmtsora1079244898_0 (objid, x_aba_transit, x_bank_account2bus_org, x_bank_acct2address, x_bank_acct2contact, x_bank_name, x_bank_num, x_changedate, x_changedby, x_customer_acct, x_customer_email, x_customer_firstname, x_customer_lastname, x_customer_phone, x_max_purch_amt, x_max_purch_amt_per_month, x_max_trans_per_month, x_moms_maiden, x_original_insert_date, x_routing, x_status) ALWAYS;
COMMENT ON TABLE sa.table_x_bank_account IS 'Stores all the customer s bank account information';
COMMENT ON COLUMN sa.table_x_bank_account.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_x_bank_account.x_bank_num IS 'Bank Number of the Customer. First part of MICR number';
COMMENT ON COLUMN sa.table_x_bank_account.x_customer_acct IS 'Customer account number.  2nd part of MICR number. encrypted by app except for last 4 characters';
COMMENT ON COLUMN sa.table_x_bank_account.x_routing IS 'Bank Routing Number';
COMMENT ON COLUMN sa.table_x_bank_account.x_aba_transit IS 'Bank ABA / Transit number on the check  eg:  64-5/610';
COMMENT ON COLUMN sa.table_x_bank_account.x_bank_name IS 'Name of the Bank eg:  Joes Bank';
COMMENT ON COLUMN sa.table_x_bank_account.x_status IS 'Status of the account A active, I inactive, or B black_flagged';
COMMENT ON COLUMN sa.table_x_bank_account.x_customer_firstname IS 'bank account owner first name  eg =Ginger';
COMMENT ON COLUMN sa.table_x_bank_account.x_customer_lastname IS 'bank account owner last name  eg =Vitis';
COMMENT ON COLUMN sa.table_x_bank_account.x_customer_phone IS 'Phone number bank has on file as account address; usually not a TracFone';
COMMENT ON COLUMN sa.table_x_bank_account.x_customer_email IS 'customer email address, needed for purchase validation eg =test@cybersource.com';
COMMENT ON COLUMN sa.table_x_bank_account.x_max_purch_amt IS 'preliminary fraud checking, overrides default in table_cc_parms';
COMMENT ON COLUMN sa.table_x_bank_account.x_max_trans_per_month IS 'preliminary fraud checking, overrides default in table_cc_parms';
COMMENT ON COLUMN sa.table_x_bank_account.x_max_purch_amt_per_month IS 'preliminary fraud checking, overrides default in table_cc_parms';
COMMENT ON COLUMN sa.table_x_bank_account.x_changedate IS 'date this row was last updated';
COMMENT ON COLUMN sa.table_x_bank_account.x_original_insert_date IS 'date this row was originally inserted';
COMMENT ON COLUMN sa.table_x_bank_account.x_changedby IS 'user loginname of person who last modified the row';
COMMENT ON COLUMN sa.table_x_bank_account.x_cc_comments IS 'multi-line text for user comments on bank account.  eg: 3 NSFs in July';
COMMENT ON COLUMN sa.table_x_bank_account.x_moms_maiden IS 'mothers maiden name for preliminary validation';
COMMENT ON COLUMN sa.table_x_bank_account.x_bank_acct2contact IS 'Customer Relation to Bank Account';
COMMENT ON COLUMN sa.table_x_bank_account.x_bank_acct2address IS 'Adddress for the Bank Account';
COMMENT ON COLUMN sa.table_x_bank_account.x_bank_account2bus_org IS 'contact add info for the bus org';