CREATE GLOBAL TEMPORARY TABLE sa.gtt_sui_bi_buckets_check (
  transaction_id NUMBER NOT NULL,
  transaction_found_flag VARCHAR2(2 BYTE) NOT NULL,
  CONSTRAINT pk_gtt_sui_bi_buckets_check PRIMARY KEY (transaction_id)
)
ON COMMIT PRESERVE ROWS;
COMMENT ON TABLE sa.gtt_sui_bi_buckets_check IS 'Global Temporary table to check buckets from previous BI for SUI';
COMMENT ON COLUMN sa.gtt_sui_bi_buckets_check.transaction_id IS 'Transaction ID for previous BI';
COMMENT ON COLUMN sa.gtt_sui_bi_buckets_check.transaction_found_flag IS 'Flag to determine if buckets were found in previous BI';