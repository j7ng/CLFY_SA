CREATE TABLE sa.x_mvne_request (
  x_esn VARCHAR2(30 BYTE),
  x_min VARCHAR2(30 BYTE),
  x_sim VARCHAR2(30 BYTE),
  x_imsi VARCHAR2(50 BYTE),
  x_plan VARCHAR2(30 BYTE),
  x_zipcode VARCHAR2(30 BYTE),
  x_min_status VARCHAR2(30 BYTE),
  x_load_status VARCHAR2(30 BYTE),
  x_transaction_date DATE,
  x_transaction_id VARCHAR2(30 BYTE),
  x_batch_id VARCHAR2(30 BYTE),
  x_balance_voice VARCHAR2(30 BYTE),
  x_balance_data VARCHAR2(30 BYTE),
  x_balance_text VARCHAR2(30 BYTE),
  x_cycle_date DATE,
  x_insert_date DATE,
  x_update_date DATE
);
COMMENT ON TABLE sa.x_mvne_request IS 'mvne migration request table';
COMMENT ON COLUMN sa.x_mvne_request.x_esn IS 'ESN';
COMMENT ON COLUMN sa.x_mvne_request.x_min IS 'min';
COMMENT ON COLUMN sa.x_mvne_request.x_sim IS 'sim';
COMMENT ON COLUMN sa.x_mvne_request.x_imsi IS 'imsi';
COMMENT ON COLUMN sa.x_mvne_request.x_plan IS 'plan';
COMMENT ON COLUMN sa.x_mvne_request.x_zipcode IS 'zipcode';
COMMENT ON COLUMN sa.x_mvne_request.x_min_status IS 'min status';
COMMENT ON COLUMN sa.x_mvne_request.x_load_status IS 'load status';
COMMENT ON COLUMN sa.x_mvne_request.x_transaction_date IS 'transaction date';
COMMENT ON COLUMN sa.x_mvne_request.x_transaction_id IS 'transaction id';
COMMENT ON COLUMN sa.x_mvne_request.x_batch_id IS 'batch id';
COMMENT ON COLUMN sa.x_mvne_request.x_balance_voice IS 'balance voice';
COMMENT ON COLUMN sa.x_mvne_request.x_balance_data IS 'balance data';
COMMENT ON COLUMN sa.x_mvne_request.x_balance_text IS 'balance text';
COMMENT ON COLUMN sa.x_mvne_request.x_cycle_date IS 'cycle date';
COMMENT ON COLUMN sa.x_mvne_request.x_insert_date IS 'insert date';
COMMENT ON COLUMN sa.x_mvne_request.x_update_date IS 'update date';