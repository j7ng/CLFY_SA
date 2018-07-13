CREATE TABLE sa.table_x_case_conf_hdr (
  objid NUMBER,
  dev NUMBER,
  x_case_type VARCHAR2(30 BYTE),
  s_x_case_type VARCHAR2(30 BYTE),
  x_title VARCHAR2(80 BYTE),
  s_x_title VARCHAR2(80 BYTE),
  x_display_title VARCHAR2(80 BYTE),
  x_service NUMBER,
  x_warehouse NUMBER,
  x_exch_type VARCHAR2(20 BYTE),
  x_required_return NUMBER,
  x_weight VARCHAR2(10 BYTE),
  x_block_reopen NUMBER,
  x_reopen_days_check NUMBER,
  x_units NUMBER,
  x_avail_lhs_menu NUMBER,
  x_instruct_type NUMBER,
  x_instruct_code VARCHAR2(5 BYTE),
  x_airbill NUMBER,
  x_case_err_gbst_lst NUMBER,
  x_repl_logic VARCHAR2(30 BYTE),
  pn_domain_type VARCHAR2(40 BYTE),
  rtc_comm NUMBER,
  skip_subsidy_check NUMBER(22),
  is_balance_inq_required NUMBER(22),
  auto_close NUMBER(22),
  CONSTRAINT x_case_conf_hdr_objid UNIQUE (objid) USING INDEX sa.x_case_conf_hdr_objindex
);
ALTER TABLE sa.table_x_case_conf_hdr ADD SUPPLEMENTAL LOG GROUP dmtsora174186624_0 (dev, objid, s_x_case_type, s_x_title, x_avail_lhs_menu, x_block_reopen, x_case_type, x_display_title, x_exch_type, x_instruct_code, x_instruct_type, x_reopen_days_check, x_required_return, x_service, x_title, x_units, x_warehouse, x_weight) ALWAYS;
COMMENT ON TABLE sa.table_x_case_conf_hdr IS 'Main Case Type Title Configuration Table';
COMMENT ON COLUMN sa.table_x_case_conf_hdr.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_x_case_conf_hdr.dev IS 'Row version number for mobile distribution purposes';
COMMENT ON COLUMN sa.table_x_case_conf_hdr.x_case_type IS 'Case Type';
COMMENT ON COLUMN sa.table_x_case_conf_hdr.x_title IS 'Case Title';
COMMENT ON COLUMN sa.table_x_case_conf_hdr.x_display_title IS 'User Friendly Display Title';
COMMENT ON COLUMN sa.table_x_case_conf_hdr.x_service IS 'Case Requires ESN 0=No 1=Yes';
COMMENT ON COLUMN sa.table_x_case_conf_hdr.x_warehouse IS 'Requires Warehouse Integration 0=No 1=Yes';
COMMENT ON COLUMN sa.table_x_case_conf_hdr.x_exch_type IS 'TECHNOLOGY, WAREHOUSE, NA';
COMMENT ON COLUMN sa.table_x_case_conf_hdr.x_required_return IS 'Case Requires Return 0=No 1=Yes';
COMMENT ON COLUMN sa.table_x_case_conf_hdr.x_weight IS 'Weight in pounds of the shipping for the case LETTER, 1LB, 2LB';
COMMENT ON COLUMN sa.table_x_case_conf_hdr.x_block_reopen IS 'Do not re-open cases of this type and title combination';
COMMENT ON COLUMN sa.table_x_case_conf_hdr.x_reopen_days_check IS 'Number of days to check in the past for previous cases';
COMMENT ON COLUMN sa.table_x_case_conf_hdr.x_units IS '0=No, 1=Yes, Units Case';
COMMENT ON COLUMN sa.table_x_case_conf_hdr.x_avail_lhs_menu IS 'Available on the Left Hand Side Menu 0=No, 1=Yes';
COMMENT ON COLUMN sa.table_x_case_conf_hdr.x_instruct_type IS '0=None, 1= Always, 2=Conditional (Only available for x_warehouse = 1) default to 0';
COMMENT ON COLUMN sa.table_x_case_conf_hdr.x_instruct_code IS 'Instruction Code';
COMMENT ON COLUMN sa.table_x_case_conf_hdr.x_airbill IS 'AIRBILL REQUIRED FLAG (O=NO,  1=YES)';
COMMENT ON COLUMN sa.table_x_case_conf_hdr.x_case_err_gbst_lst IS 'REF LIST OF TYPE ERRORS IN TABLE_GBST_LST (OBJID)';
COMMENT ON COLUMN sa.table_x_case_conf_hdr.x_repl_logic IS 'REPLACEMENT LOGIC APPLIED WHICH IT IS BASED ON PART NUMBER';
COMMENT ON COLUMN sa.table_x_case_conf_hdr.rtc_comm IS 'Flag to enable or disable the RTC communication';
COMMENT ON COLUMN sa.table_x_case_conf_hdr.is_balance_inq_required IS 'TAS only col - 1=YES, 0=NO - Pri use for x_warehouse=1 cases who''s PN_DOMAIN_TYPE are PHONES or SIM CARDS';
COMMENT ON COLUMN sa.table_x_case_conf_hdr.auto_close IS 'Indicate if ticket created with this type/title will be automatically closed right after creating it. 1=YES, 0=NO';