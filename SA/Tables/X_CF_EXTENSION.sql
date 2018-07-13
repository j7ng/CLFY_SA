CREATE TABLE sa.x_cf_extension (
  objid NUMBER(38) NOT NULL,
  line_status_code VARCHAR2(2 BYTE) NOT NULL,
  throttle_status_code VARCHAR2(2 BYTE) NOT NULL,
  insert_timestamp DATE DEFAULT SYSDATE NOT NULL,
  update_timestamp DATE DEFAULT SYSDATE NOT NULL,
  ancillary_status_code VARCHAR2(5 BYTE) NOT NULL,
  CONSTRAINT pk_carrier_features_extension PRIMARY KEY (objid),
  CONSTRAINT uk1_x_cf_extension UNIQUE (line_status_code,throttle_status_code,ancillary_status_code),
  CONSTRAINT fk1_carrier_features_extension FOREIGN KEY (line_status_code) REFERENCES sa.x_cf_line_status (line_status_code),
  CONSTRAINT fk2_carrier_features_extension FOREIGN KEY (throttle_status_code) REFERENCES sa.x_cf_throttle_status (throttle_status_code),
  CONSTRAINT fk3_carrier_features_extension FOREIGN KEY (ancillary_status_code) REFERENCES sa.x_cf_ancillary_codes (ancillary_status_code)
);
COMMENT ON COLUMN sa.x_cf_extension.line_status_code IS 'Line status, can be active inactive';
COMMENT ON COLUMN sa.x_cf_extension.throttle_status_code IS 'Throttle status, can be throttled, not throttled';
COMMENT ON COLUMN sa.x_cf_extension.ancillary_status_code IS 'Ancillary status code from X_CF_ANCILLARY_CODES table';