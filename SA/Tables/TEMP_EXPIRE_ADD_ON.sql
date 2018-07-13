CREATE TABLE sa.temp_expire_add_on (
  account_group_id NUMBER NOT NULL,
  add_ons_count NUMBER,
  status VARCHAR2(30 BYTE),
  insert_timestamp DATE DEFAULT SYSDATE,
  processed_timestamp DATE,
  CONSTRAINT pk_temp_expire_add_on PRIMARY KEY (account_group_id)
);
COMMENT ON TABLE sa.temp_expire_add_on IS 'Temporary table to hold add ons to be expired';
COMMENT ON COLUMN sa.temp_expire_add_on.account_group_id IS 'Account group id of the subscriber';
COMMENT ON COLUMN sa.temp_expire_add_on.add_ons_count IS 'Total add-ons to be expired';
COMMENT ON COLUMN sa.temp_expire_add_on.status IS 'Status of the rows';
COMMENT ON COLUMN sa.temp_expire_add_on.insert_timestamp IS 'Timestamp when the record was created';
COMMENT ON COLUMN sa.temp_expire_add_on.processed_timestamp IS 'Processed timestamp of the record';