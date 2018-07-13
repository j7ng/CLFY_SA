CREATE TABLE sa.table_x_voucher_transactions (
  transaction_id NUMBER,
  transaction_type VARCHAR2(20 BYTE),
  transaction_date DATE,
  vendor_id VARCHAR2(50 BYTE),
  voucher_trans2voucher NUMBER,
  voucher_status VARCHAR2(20 BYTE),
  voucher_trans2order NUMBER,
  x_notes VARCHAR2(1000 BYTE),
  ref_transaction_id NUMBER
);
COMMENT ON TABLE sa.table_x_voucher_transactions IS 'Voucher transactions table stores all activity of vouchers';
COMMENT ON COLUMN sa.table_x_voucher_transactions.transaction_id IS 'Transaction id.';
COMMENT ON COLUMN sa.table_x_voucher_transactions.transaction_type IS 'transaction type';
COMMENT ON COLUMN sa.table_x_voucher_transactions.transaction_date IS 'date when the transaction happened';
COMMENT ON COLUMN sa.table_x_voucher_transactions.vendor_id IS 'vendor ID where the transaction happened';
COMMENT ON COLUMN sa.table_x_voucher_transactions.voucher_trans2voucher IS 'Voucher reference to this transaction';
COMMENT ON COLUMN sa.table_x_voucher_transactions.voucher_status IS 'status of the voucher that is being referenced';
COMMENT ON COLUMN sa.table_x_voucher_transactions.voucher_trans2order IS 'reference to order id that placed using the voucher';
COMMENT ON COLUMN sa.table_x_voucher_transactions.x_notes IS 'descriptive info about the transaction';
COMMENT ON COLUMN sa.table_x_voucher_transactions.ref_transaction_id IS 'any reference transaction id related to current transaction';