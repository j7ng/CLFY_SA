CREATE TABLE sa.x_rp_ancillary_code (
  ancillary_code VARCHAR2(5 BYTE) NOT NULL,
  description VARCHAR2(2000 BYTE) NOT NULL,
  insert_timestamp DATE DEFAULT SYSDATE,
  update_timestamp DATE DEFAULT SYSDATE,
  CONSTRAINT pk_rp_ancillary_codes PRIMARY KEY (ancillary_code)
);
COMMENT ON TABLE sa.x_rp_ancillary_code IS 'Table to configure ancillary codes';
COMMENT ON COLUMN sa.x_rp_ancillary_code.ancillary_code IS 'Line status (active or inactive)';
COMMENT ON COLUMN sa.x_rp_ancillary_code.description IS 'Description of line status';