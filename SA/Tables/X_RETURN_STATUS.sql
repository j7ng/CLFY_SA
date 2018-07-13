CREATE TABLE sa.x_return_status (
  return_status_code NUMBER NOT NULL,
  description VARCHAR2(20 BYTE),
  refund_flag VARCHAR2(1 BYTE),
  CONSTRAINT x_return_status_prime_idx PRIMARY KEY (return_status_code)
);
COMMENT ON COLUMN sa.x_return_status.return_status_code IS 'It donotes the Status codReturn_status_code';
COMMENT ON COLUMN sa.x_return_status.description IS 'It denotes the description of the status';
COMMENT ON COLUMN sa.x_return_status.refund_flag IS 'It determines if the status belongs to Refund';