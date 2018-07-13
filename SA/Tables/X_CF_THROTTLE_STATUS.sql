CREATE TABLE sa.x_cf_throttle_status (
  throttle_status_code VARCHAR2(2 BYTE) NOT NULL,
  description VARCHAR2(20 BYTE) NOT NULL,
  insert_timestamp DATE DEFAULT SYSDATE NOT NULL,
  update_timestamp DATE DEFAULT SYSDATE NOT NULL,
  CONSTRAINT pk_cf_throttle_status PRIMARY KEY (throttle_status_code)
);
COMMENT ON COLUMN sa.x_cf_throttle_status.throttle_status_code IS 'Throttle status (Throttle, not throttled)';