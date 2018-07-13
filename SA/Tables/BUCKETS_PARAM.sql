CREATE TABLE sa.buckets_param (
  bucket_id VARCHAR2(100 BYTE),
  bucket_type VARCHAR2(100 BYTE),
  active_flag VARCHAR2(1 BYTE)
);
COMMENT ON TABLE sa.buckets_param IS 'Bucket parameter table for table_x_zero_out_max';
COMMENT ON COLUMN sa.buckets_param.bucket_id IS 'Bucket Id';
COMMENT ON COLUMN sa.buckets_param.bucket_type IS 'bucket type';
COMMENT ON COLUMN sa.buckets_param.active_flag IS 'active flag';