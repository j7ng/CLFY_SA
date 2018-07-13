CREATE TABLE sa.simout_log (
  client_trans_id VARCHAR2(100 BYTE),
  client_id VARCHAR2(30 BYTE),
  esn VARCHAR2(30 BYTE),
  sim VARCHAR2(30 BYTE),
  brand VARCHAR2(30 BYTE),
  source_system VARCHAR2(30 BYTE),
  dealer_id VARCHAR2(80 BYTE),
  store_id VARCHAR2(80 BYTE),
  terminal_id VARCHAR2(80 BYTE),
  phone_make VARCHAR2(100 BYTE),
  phone_model VARCHAR2(100 BYTE),
  retry_flag VARCHAR2(1 BYTE),
  vd_trans_id VARCHAR2(20 BYTE),
  insert_date DATE,
  register_status VARCHAR2(100 BYTE)
);
COMMENT ON TABLE sa.simout_log IS 'SIM OUT Event Log Table';
COMMENT ON COLUMN sa.simout_log.client_trans_id IS 'Client Transaction ID';
COMMENT ON COLUMN sa.simout_log.client_id IS 'Clinet ID';
COMMENT ON COLUMN sa.simout_log.esn IS 'Phone ESN';
COMMENT ON COLUMN sa.simout_log.sim IS 'SIM Number';
COMMENT ON COLUMN sa.simout_log.brand IS 'Brand';
COMMENT ON COLUMN sa.simout_log.source_system IS 'Sourcesystem of the transaction drives dealer selection';
COMMENT ON COLUMN sa.simout_log.dealer_id IS 'Dealer ID linked to the Sourcesystem';
COMMENT ON COLUMN sa.simout_log.store_id IS 'Store ID';
COMMENT ON COLUMN sa.simout_log.terminal_id IS 'Terminal ID within the Store';
COMMENT ON COLUMN sa.simout_log.phone_make IS 'Phone Make';
COMMENT ON COLUMN sa.simout_log.phone_model IS 'Vendor Model Equivalent';
COMMENT ON COLUMN sa.simout_log.retry_flag IS 'Retry Flag Y /N';
COMMENT ON COLUMN sa.simout_log.vd_trans_id IS 'Verify Device Transaction ID from IG';
COMMENT ON COLUMN sa.simout_log.register_status IS 'Phone Register Status for SIM OUT S/F';