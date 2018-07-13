CREATE TABLE sa.adfcrm_pergencodes (
  code_id VARCHAR2(20 BYTE) NOT NULL,
  code_description VARCHAR2(400 BYTE) NOT NULL,
  code_active NUMBER NOT NULL,
  code_cmd NUMBER NOT NULL,
  code_int_type NUMBER NOT NULL,
  code_priority NUMBER NOT NULL,
  delivery VARCHAR2(30 BYTE) DEFAULT 'DUAL' NOT NULL,
  clears VARCHAR2(10 BYTE),
  CONSTRAINT adfcrm_pergencodes PRIMARY KEY (code_id)
);
COMMENT ON TABLE sa.adfcrm_pergencodes IS 'Store codes related with personality functionality';
COMMENT ON COLUMN sa.adfcrm_pergencodes.code_id IS 'Unique identifier for code';
COMMENT ON COLUMN sa.adfcrm_pergencodes.code_description IS 'Code description';
COMMENT ON COLUMN sa.adfcrm_pergencodes.code_active IS 'Indicate if the code is active then value is 1 otherwise 0';
COMMENT ON COLUMN sa.adfcrm_pergencodes.code_cmd IS 'Command related with the code';
COMMENT ON COLUMN sa.adfcrm_pergencodes.code_int_type IS 'Code group identification';
COMMENT ON COLUMN sa.adfcrm_pergencodes.code_priority IS 'Code priority to define the order';
COMMENT ON COLUMN sa.adfcrm_pergencodes.delivery IS 'Indicate if the code is OTA, MANUAL or DUAL';
COMMENT ON COLUMN sa.adfcrm_pergencodes.clears IS 'Indicate if click codes should be resetted';