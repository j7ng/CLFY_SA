CREATE TABLE sa.mtm_program_safelink (
  program_param_objid NUMBER,
  part_num_objid NUMBER,
  reserve_card_limit NUMBER,
  web_display VARCHAR2(1 BYTE),
  csr_display VARCHAR2(1 BYTE),
  ivr_display VARCHAR2(1 BYTE),
  program_provision_flag NUMBER(2),
  start_date DATE,
  end_date DATE,
  is_default_part_num VARCHAR2(1 BYTE),
  is_sl_red_card_compatible VARCHAR2(20 BYTE),
  "PRIORITY" NUMBER,
  allow_non_sl_customer VARCHAR2(2 BYTE),
  coverage_script VARCHAR2(50 BYTE),
  script_type VARCHAR2(50 BYTE),
  rec_type VARCHAR2(200 BYTE),
  app_display VARCHAR2(1 BYTE)
);
COMMENT ON COLUMN sa.mtm_program_safelink.program_param_objid IS 'Objid of X_PROGRAM_PARAMETERS table';
COMMENT ON COLUMN sa.mtm_program_safelink.part_num_objid IS 'Objid of TABLE_PART_NUMBER table';
COMMENT ON COLUMN sa.mtm_program_safelink.reserve_card_limit IS 'This field is to check the reserved count limit for a Program';
COMMENT ON COLUMN sa.mtm_program_safelink.web_display IS 'This flag defines whether the this data card is available for WEB';
COMMENT ON COLUMN sa.mtm_program_safelink.csr_display IS 'This flag defines whether the this data card is available for CSR';
COMMENT ON COLUMN sa.mtm_program_safelink.ivr_display IS 'This flag defines whether the this data card is available for IVR';
COMMENT ON COLUMN sa.mtm_program_safelink.program_provision_flag IS 'This will indicate which validation flow to use for this program';
COMMENT ON COLUMN sa.mtm_program_safelink.start_date IS 'This is the effective start date of the PART NUMBER';
COMMENT ON COLUMN sa.mtm_program_safelink.end_date IS 'This is the effective end date of the PART NUMBER';
COMMENT ON COLUMN sa.mtm_program_safelink.is_default_part_num IS 'This field will identify if part number is default or not(add-on)';
COMMENT ON COLUMN sa.mtm_program_safelink.is_sl_red_card_compatible IS 'This column for validating the SL Red Card and skipping 420 error';
COMMENT ON COLUMN sa.mtm_program_safelink.app_display IS 'This flag defines whether the this data card is available for APP';