CREATE TABLE sa.x_mtm_restricted_pymtmode (
  program_param_objid NUMBER,
  x_payment_type VARCHAR2(10 BYTE)
);
ALTER TABLE sa.x_mtm_restricted_pymtmode ADD SUPPLEMENTAL LOG GROUP dmtsora327108816_0 (program_param_objid, x_payment_type) ALWAYS;
COMMENT ON TABLE sa.x_mtm_restricted_pymtmode IS 'Billing programs for payment methods';
COMMENT ON COLUMN sa.x_mtm_restricted_pymtmode.program_param_objid IS 'Reference to objid of table  x_program_parameters';
COMMENT ON COLUMN sa.x_mtm_restricted_pymtmode.x_payment_type IS 'Payment type: ACH,CREDITCARD,DEBITCARD,PAYPAL';