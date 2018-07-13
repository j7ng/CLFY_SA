CREATE TABLE sa.x_ig_order_type (
  x_programme_name VARCHAR2(30 BYTE),
  x_actual_order_type VARCHAR2(30 BYTE),
  x_ig_order_type VARCHAR2(30 BYTE),
  x_sql_text VARCHAR2(4000 BYTE),
  x_priority NUMBER,
  create_so_gencode_flag VARCHAR2(1 BYTE),
  create_mform_ig_flag VARCHAR2(1 BYTE),
  create_mform_port_flag VARCHAR2(1 BYTE),
  skip_min_validation_flag VARCHAR2(1 BYTE),
  skip_esn_validation_flag VARCHAR2(1 BYTE),
  create_ig_apn_flag VARCHAR2(1 BYTE),
  insert_ild_trans_flag VARCHAR2(1 BYTE),
  x_bogo_config_flag CHAR DEFAULT 'N',
  sui_action_type VARCHAR2(10 BYTE),
  update_msid_flag VARCHAR2(1 BYTE),
  addon_cash_card_flag VARCHAR2(1 BYTE),
  contact_pin_update_flag VARCHAR2(1 BYTE),
  brm_notification_flag VARCHAR2(1 BYTE),
  newer_trans_flag VARCHAR2(1 BYTE),
  skip_min_update_flag VARCHAR2(1 BYTE),
  safelink_batch_flag VARCHAR2(1 BYTE),
  create_buckets_flag VARCHAR2(3 BYTE),
  process_igate_in3_flag VARCHAR2(1 BYTE),
  process_igate_in3_lite_flag VARCHAR2(1 BYTE)
);
COMMENT ON TABLE sa.x_ig_order_type IS 'This table calculates the order type in IG_TRANSACTION. Example - Internal Port In becomes IPI based on validations in X_SQL_TEXT column';
COMMENT ON COLUMN sa.x_ig_order_type.x_programme_name IS 'The caller (procedure) in IGATE from where this table (function) is being called';
COMMENT ON COLUMN sa.x_ig_order_type.x_actual_order_type IS 'Order type text being passed by java when calling create action item in IGATE';
COMMENT ON COLUMN sa.x_ig_order_type.x_ig_order_type IS 'Order type will be inserted into IG_TRANSACTION';
COMMENT ON COLUMN sa.x_ig_order_type.x_sql_text IS 'Validations to calculate the final order type';
COMMENT ON COLUMN sa.x_ig_order_type.x_priority IS 'The validations are prioritized based on this value';
COMMENT ON COLUMN sa.x_ig_order_type.skip_min_validation_flag IS 'Order type text being passed by for min_curs';
COMMENT ON COLUMN sa.x_ig_order_type.skip_esn_validation_flag IS 'Flag for skipping the ESN validation';
COMMENT ON COLUMN sa.x_ig_order_type.insert_ild_trans_flag IS 'to restict the order types inserting into ild transaction table';
COMMENT ON COLUMN sa.x_ig_order_type.sui_action_type IS 'Action type, can either be inquiry or update';
COMMENT ON COLUMN sa.x_ig_order_type.update_msid_flag IS 'If set to Y, IGATE will create CF extension records';
COMMENT ON COLUMN sa.x_ig_order_type.contact_pin_update_flag IS 'Flag to update MIN and contact PIN in ccduser table';
COMMENT ON COLUMN sa.x_ig_order_type.brm_notification_flag IS 'Column that indiactes for which IG order types BRM should be notified';
COMMENT ON COLUMN sa.x_ig_order_type.newer_trans_flag IS 'Flag to Newer trans is required for order type';
COMMENT ON COLUMN sa.x_ig_order_type.skip_min_update_flag IS 'Flag to skip MIN Update';
COMMENT ON COLUMN sa.x_ig_order_type.safelink_batch_flag IS 'Flag to process SafeLink Batch Redemption Transactions';
COMMENT ON COLUMN sa.x_ig_order_type.create_buckets_flag IS 'Flag to indicate buckets creation';
COMMENT ON COLUMN sa.x_ig_order_type.process_igate_in3_flag IS 'Flag to indicate if IGATE IN3 process should be exucted for the order type';
COMMENT ON COLUMN sa.x_ig_order_type.process_igate_in3_lite_flag IS 'Flag to indicate if IGATE IN3 process should be exucted for the order type';