CREATE TABLE sa.table_x_vouchers (
  objid NUMBER,
  voucher_id VARCHAR2(50 BYTE),
  x_created_date DATE DEFAULT SYSDATE,
  x_expiration_date DATE,
  x_voucher_status VARCHAR2(20 BYTE),
  x_token_id VARCHAR2(50 BYTE),
  x_vouchers2benefit NUMBER,
  x_vouchers2order_hdr NUMBER,
  x_update_date DATE
);
COMMENT ON TABLE sa.table_x_vouchers IS 'The vouchers that can be used to purchase something at vendor website';
COMMENT ON COLUMN sa.table_x_vouchers.objid IS 'Unique voucher id';
COMMENT ON COLUMN sa.table_x_vouchers.voucher_id IS 'Unique voucher id';
COMMENT ON COLUMN sa.table_x_vouchers.x_created_date IS 'date when the voucher is created';
COMMENT ON COLUMN sa.table_x_vouchers.x_expiration_date IS 'date when the voucher will expire and no longer be used therafter';
COMMENT ON COLUMN sa.table_x_vouchers.x_voucher_status IS 'status of the voucher (eg. VALID | INVALID | AUTHORIZED | SETTLED | CANCELLED etc)';
COMMENT ON COLUMN sa.table_x_vouchers.x_token_id IS 'Token ID that is used to communicate this voucher with vendor';
COMMENT ON COLUMN sa.table_x_vouchers.x_vouchers2benefit IS 'Benefits associated with the voucher; refers TABLE_X_BENEFITS.OBJID ';
COMMENT ON COLUMN sa.table_x_vouchers.x_vouchers2order_hdr IS 'Refers X_VOUCHER_ORDER_HDR.OBJID - the order which has been placed using this voucher';
COMMENT ON COLUMN sa.table_x_vouchers.x_update_date IS 'date when the record is last updated';