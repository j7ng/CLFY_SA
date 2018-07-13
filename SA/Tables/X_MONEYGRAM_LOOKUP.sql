CREATE TABLE sa.x_moneygram_lookup (
  objid NUMBER NOT NULL,
  x_paycode VARCHAR2(30 BYTE) NOT NULL,
  x_receive_code VARCHAR2(10 BYTE) NOT NULL,
  x_part_number VARCHAR2(30 BYTE),
  x_description VARCHAR2(100 BYTE),
  x_state VARCHAR2(30 BYTE),
  x_provision_flag NUMBER,
  x_moneygram_error_codes_start NUMBER,
  CONSTRAINT moneygram_lookup_pk PRIMARY KEY (objid),
  CONSTRAINT moneygram_lookup_uk UNIQUE (x_paycode,x_receive_code)
);
COMMENT ON COLUMN sa.x_moneygram_lookup.objid IS 'PRIMARY KEY';
COMMENT ON COLUMN sa.x_moneygram_lookup.x_paycode IS 'Pay code';
COMMENT ON COLUMN sa.x_moneygram_lookup.x_receive_code IS 'Receive code';
COMMENT ON COLUMN sa.x_moneygram_lookup.x_part_number IS 'Part number';
COMMENT ON COLUMN sa.x_moneygram_lookup.x_description IS 'Program name description like BROADBAND,E911, SL CA DATACARD';
COMMENT ON COLUMN sa.x_moneygram_lookup.x_state IS 'State Name';
COMMENT ON COLUMN sa.x_moneygram_lookup.x_provision_flag IS 'Flag set like if 1 then e911, 2 then data card plans, 3 then ILD, 4 then broadband';
COMMENT ON COLUMN sa.x_moneygram_lookup.x_moneygram_error_codes_start IS 'This is to reference the error code for X_MONEYGRAM_ERROR_CODES.TF_ERROR_CODE';