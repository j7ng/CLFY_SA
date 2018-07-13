CREATE TABLE sa.x_payment_source (
  objid NUMBER NOT NULL,
  x_pymt_type VARCHAR2(20 BYTE),
  x_pymt_src_name VARCHAR2(30 BYTE),
  x_status VARCHAR2(10 BYTE),
  x_is_default NUMBER,
  x_insert_date DATE,
  x_update_date DATE,
  x_sourcesystem VARCHAR2(30 BYTE),
  x_changedby VARCHAR2(20 BYTE),
  pymt_src2web_user NUMBER,
  pymt_src2x_credit_card NUMBER,
  pymt_src2x_bank_account NUMBER,
  x_billing_email VARCHAR2(80 BYTE),
  pymt_src2x_altpymtsource NUMBER,
  pymt_src2contact NUMBER(22)
);
ALTER TABLE sa.x_payment_source ADD SUPPLEMENTAL LOG GROUP dmtsora770339428_0 (objid, pymt_src2web_user, pymt_src2x_bank_account, pymt_src2x_credit_card, x_billing_email, x_changedby, x_insert_date, x_is_default, x_pymt_src_name, x_pymt_type, x_sourcesystem, x_status, x_update_date) ALWAYS;
COMMENT ON TABLE sa.x_payment_source IS 'This structure stores the forms of payment associated to an account, checking accounts, credit cards.';
COMMENT ON COLUMN sa.x_payment_source.objid IS 'Internal Record Id';
COMMENT ON COLUMN sa.x_payment_source.x_pymt_type IS 'Type of Payment: CREDITCARD,ACH';
COMMENT ON COLUMN sa.x_payment_source.x_pymt_src_name IS 'User selected name for the form of payment.';
COMMENT ON COLUMN sa.x_payment_source.x_status IS 'Status of the record: ACTIVE, DELETED';
COMMENT ON COLUMN sa.x_payment_source.x_is_default IS 'Is the record the default form of payment for the account.  Only one default per account: 0=No, 1=Yes';
COMMENT ON COLUMN sa.x_payment_source.x_insert_date IS 'Date Time of Creation';
COMMENT ON COLUMN sa.x_payment_source.x_update_date IS 'Date Time of last update';
COMMENT ON COLUMN sa.x_payment_source.x_sourcesystem IS 'Application used to create the record.';
COMMENT ON COLUMN sa.x_payment_source.x_changedby IS 'Not used.';
COMMENT ON COLUMN sa.x_payment_source.pymt_src2web_user IS 'reference objid table_web_user';
COMMENT ON COLUMN sa.x_payment_source.pymt_src2x_credit_card IS 'reference objid table_x_credit_card';
COMMENT ON COLUMN sa.x_payment_source.pymt_src2x_bank_account IS 'reference objid table: table_x_bank_account';
COMMENT ON COLUMN sa.x_payment_source.x_billing_email IS 'Account email';
COMMENT ON COLUMN sa.x_payment_source.pymt_src2x_altpymtsource IS 'Foriegn key being referred from altpymtsource table';
COMMENT ON COLUMN sa.x_payment_source.pymt_src2contact IS 'Contact objid from table_contact which is associated to the payment source';