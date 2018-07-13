CREATE TABLE sa.x_swb_tx_balance_bucket (
  objid NUMBER,
  balance_bucket2x_swb_tx NUMBER,
  recharge_date DATE,
  x_type VARCHAR2(30 BYTE),
  expiration_date DATE,
  x_value VARCHAR2(30 BYTE),
  bucket_desc VARCHAR2(100 BYTE),
  bucket_usage VARCHAR2(30 BYTE),
  bucket_id VARCHAR2(30 BYTE)
);
ALTER TABLE sa.x_swb_tx_balance_bucket ADD SUPPLEMENTAL LOG GROUP dmtsora1372603165_0 (balance_bucket2x_swb_tx, expiration_date, objid, recharge_date, x_type, x_value) ALWAYS;
COMMENT ON COLUMN sa.x_swb_tx_balance_bucket.objid IS 'Internal Record ID';
COMMENT ON COLUMN sa.x_swb_tx_balance_bucket.balance_bucket2x_swb_tx IS 'Reference to x_switchbased_transaction';
COMMENT ON COLUMN sa.x_swb_tx_balance_bucket.recharge_date IS 'not used.';
COMMENT ON COLUMN sa.x_swb_tx_balance_bucket.x_type IS 'Type of bucket: kb,min,msg';
COMMENT ON COLUMN sa.x_swb_tx_balance_bucket.expiration_date IS 'not used';
COMMENT ON COLUMN sa.x_swb_tx_balance_bucket.x_value IS 'Value for the bucket';
COMMENT ON COLUMN sa.x_swb_tx_balance_bucket.bucket_desc IS 'Bucket description';
COMMENT ON COLUMN sa.x_swb_tx_balance_bucket.bucket_usage IS 'Used value of the Bucket';
COMMENT ON COLUMN sa.x_swb_tx_balance_bucket.bucket_id IS 'Bucket ID from ig_transaction_buckets table';