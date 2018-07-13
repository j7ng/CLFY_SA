CREATE TABLE sa.x_cf_ancillary_codes (
  ancillary_status_code VARCHAR2(5 BYTE) NOT NULL,
  description VARCHAR2(2000 BYTE) NOT NULL,
  brm_equivalent VARCHAR2(2000 BYTE),
  insert_timestamp DATE DEFAULT SYSDATE,
  update_timestamp DATE DEFAULT SYSDATE,
  CONSTRAINT pk_cf_ancillary_codes PRIMARY KEY (ancillary_status_code)
);
COMMENT ON TABLE sa.x_cf_ancillary_codes IS 'Table to configure ancillary codes';
COMMENT ON COLUMN sa.x_cf_ancillary_codes.ancillary_status_code IS 'Line status (active or inactive)';
COMMENT ON COLUMN sa.x_cf_ancillary_codes.description IS 'Description of line status';
COMMENT ON COLUMN sa.x_cf_ancillary_codes.brm_equivalent IS 'BRM equivalent codes';