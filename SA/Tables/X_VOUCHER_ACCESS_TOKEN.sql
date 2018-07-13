CREATE TABLE sa.x_voucher_access_token (
  x_token_id VARCHAR2(50 BYTE),
  x_token_status VARCHAR2(20 BYTE),
  x_created_date DATE,
  x_expiration_date DATE,
  vendor_id VARCHAR2(50 BYTE)
);
COMMENT ON TABLE sa.x_voucher_access_token IS 'store the voucher access token ID (TOKEN ID). This token ID can be associated with vouchers';
COMMENT ON COLUMN sa.x_voucher_access_token.x_token_status IS 'Status of the token (eg. NEW | USED | EXPIRED etc)';
COMMENT ON COLUMN sa.x_voucher_access_token.x_created_date IS 'date when the token was created';
COMMENT ON COLUMN sa.x_voucher_access_token.x_expiration_date IS 'date when the token will expire';
COMMENT ON COLUMN sa.x_voucher_access_token.vendor_id IS 'Vendor ID who can use this token';