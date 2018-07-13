CREATE TABLE sa.x_ota_refill_training_log (
  x_esn VARCHAR2(30 BYTE),
  x_date_time DATE,
  x_sourcesystem VARCHAR2(20 BYTE),
  option_type NUMBER
);
ALTER TABLE sa.x_ota_refill_training_log ADD SUPPLEMENTAL LOG GROUP dmtsora493770156_0 (option_type, x_date_time, x_esn, x_sourcesystem) ALWAYS;
COMMENT ON TABLE sa.x_ota_refill_training_log IS 'This table logs the times a customer receives rapid refil instructions.   Once a certain number is reached the customer is given other options.';
COMMENT ON COLUMN sa.x_ota_refill_training_log.x_esn IS 'Phone Serial Number';
COMMENT ON COLUMN sa.x_ota_refill_training_log.x_date_time IS 'Timestamp';
COMMENT ON COLUMN sa.x_ota_refill_training_log.x_sourcesystem IS 'System Used';
COMMENT ON COLUMN sa.x_ota_refill_training_log.option_type IS 'not used.';