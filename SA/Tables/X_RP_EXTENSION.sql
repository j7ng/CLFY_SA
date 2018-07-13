CREATE TABLE sa.x_rp_extension (
  objid NUMBER NOT NULL,
  line_status_code VARCHAR2(2 BYTE) NOT NULL,
  throttle_status_code VARCHAR2(2 BYTE) NOT NULL,
  ancillary_code VARCHAR2(5 BYTE) NOT NULL,
  insert_timestamp DATE DEFAULT SYSDATE NOT NULL,
  update_timestamp DATE DEFAULT SYSDATE NOT NULL,
  CONSTRAINT pk_rp_extension PRIMARY KEY (objid),
  CONSTRAINT fk1_rp_extension FOREIGN KEY (line_status_code) REFERENCES sa.x_rp_line_status (line_status_code),
  CONSTRAINT fk2_rp_extension FOREIGN KEY (throttle_status_code) REFERENCES sa.x_rp_throttle_status (throttle_status_code),
  CONSTRAINT fk3_rp_extension FOREIGN KEY (ancillary_code) REFERENCES sa.x_rp_ancillary_code (ancillary_code)
);
COMMENT ON COLUMN sa.x_rp_extension.line_status_code IS 'Line status, can be active inactive';
COMMENT ON COLUMN sa.x_rp_extension.throttle_status_code IS 'Throttle status, can be throttled, not throttled';
COMMENT ON COLUMN sa.x_rp_extension.ancillary_code IS 'Ancillary code from x_rp_ancillary_code';