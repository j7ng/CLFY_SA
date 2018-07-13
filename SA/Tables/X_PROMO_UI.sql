CREATE TABLE sa.x_promo_ui (
  x_promo_name VARCHAR2(200 BYTE),
  x_promo_code VARCHAR2(30 BYTE),
  x_promo_desc VARCHAR2(200 BYTE),
  x_start_date DATE,
  x_end_date DATE,
  x_bonus_units NUMBER,
  x_bonus_days NUMBER,
  x_discount_value NUMBER,
  x_bus_org NUMBER,
  x_pd_chk_flag VARCHAR2(20 BYTE),
  x_promo_usage NUMBER,
  x_promo_reqd_flag VARCHAR2(20 BYTE),
  x_promo_channel VARCHAR2(50 BYTE),
  x_promo_benefit VARCHAR2(50 BYTE),
  x_promo_bene_type VARCHAR2(50 BYTE),
  x_trans_type VARCHAR2(50 BYTE),
  x_trans_type_lvl1 VARCHAR2(50 BYTE),
  x_trans_type_lvl2 VARCHAR2(200 BYTE),
  x_trans_type_lvl3 VARCHAR2(200 BYTE),
  x_trans_rule VARCHAR2(20 BYTE),
  x_frequency NUMBER,
  x_trans_rule_value VARCHAR2(20 BYTE),
  x_esn_qual VARCHAR2(20 BYTE),
  x_group_name VARCHAR2(100 BYTE),
  x_esn_tech VARCHAR2(200 BYTE),
  x_esn_model VARCHAR2(200 BYTE),
  x_esn_part VARCHAR2(200 BYTE),
  x_mrkt_state VARCHAR2(200 BYTE),
  x_mrkt_zip VARCHAR2(200 BYTE),
  x_bp_enrolled VARCHAR2(200 BYTE),
  x_member_in VARCHAR2(200 BYTE),
  x_valid_plans VARCHAR2(200 BYTE),
  x_valid_contact VARCHAR2(200 BYTE),
  x_act_channel VARCHAR2(200 BYTE),
  x_last_redmp_channel VARCHAR2(200 BYTE),
  x_myacct_info VARCHAR2(200 BYTE),
  x_esn_dealer VARCHAR2(200 BYTE),
  x_campgn_prtcpt_times NUMBER,
  x_campgn_prtcpt_method VARCHAR2(200 BYTE),
  x_campgn_rcpt_times NUMBER,
  x_campgn_rcpt_method VARCHAR2(200 BYTE),
  x_cost_center NUMBER,
  x_approve_flag VARCHAR2(20 BYTE),
  x_cr_no NUMBER,
  x_promote_env VARCHAR2(200 BYTE),
  x_created_by2user NUMBER,
  x_created_date DATE,
  x_updated_by2user NUMBER,
  x_updated_date DATE,
  x_bonus_sms NUMBER(22),
  x_bonus_data_mb NUMBER(22),
  x_device_type VARCHAR2(60 BYTE),
  x_trans_type_lvl4 VARCHAR2(200 BYTE),
  x_trans_type_lvl5 VARCHAR2(200 BYTE),
  CONSTRAINT x_promo_name_uq UNIQUE (x_promo_name)
);
ALTER TABLE sa.x_promo_ui ADD SUPPLEMENTAL LOG GROUP dmtsora2098163466_1 (x_act_channel, x_approve_flag, x_campgn_prtcpt_method, x_campgn_prtcpt_times, x_campgn_rcpt_method, x_campgn_rcpt_times, x_cost_center, x_created_by2user, x_created_date, x_cr_no, x_esn_dealer, x_last_redmp_channel, x_myacct_info, x_promote_env, x_updated_by2user, x_updated_date) ALWAYS;
ALTER TABLE sa.x_promo_ui ADD SUPPLEMENTAL LOG GROUP dmtsora2098163466_0 (x_bonus_days, x_bonus_units, x_bp_enrolled, x_bus_org, x_discount_value, x_end_date, x_esn_model, x_esn_part, x_esn_qual, x_esn_tech, x_frequency, x_group_name, x_member_in, x_mrkt_state, x_mrkt_zip, x_pd_chk_flag, x_promo_benefit, x_promo_bene_type, x_promo_channel, x_promo_code, x_promo_desc, x_promo_name, x_promo_reqd_flag, x_promo_usage, x_start_date, x_trans_rule, x_trans_rule_value, x_trans_type, x_trans_type_lvl1, x_trans_type_lvl2, x_trans_type_lvl3, x_valid_contact, x_valid_plans) ALWAYS;
COMMENT ON TABLE sa.x_promo_ui IS 'This is the support table for the promotion configuration application';
COMMENT ON COLUMN sa.x_promo_ui.x_promo_name IS 'Promotion Name';
COMMENT ON COLUMN sa.x_promo_ui.x_promo_code IS 'Promotion Code';
COMMENT ON COLUMN sa.x_promo_ui.x_promo_desc IS 'Promotion Description';
COMMENT ON COLUMN sa.x_promo_ui.x_start_date IS 'Start Date for Promotion';
COMMENT ON COLUMN sa.x_promo_ui.x_end_date IS 'End Date for Promotion';
COMMENT ON COLUMN sa.x_promo_ui.x_bonus_units IS 'Bonus Units';
COMMENT ON COLUMN sa.x_promo_ui.x_bonus_days IS 'Bonus Days';
COMMENT ON COLUMN sa.x_promo_ui.x_discount_value IS 'Discount Value if applicable for Purchases';
COMMENT ON COLUMN sa.x_promo_ui.x_bus_org IS 'Reference to table_bus_org';
COMMENT ON COLUMN sa.x_promo_ui.x_pd_chk_flag IS 'Pastdue Check Flag: Y,N';
COMMENT ON COLUMN sa.x_promo_ui.x_promo_usage IS 'Number of times the promotion can be use';
COMMENT ON COLUMN sa.x_promo_ui.x_promo_reqd_flag IS 'Promo Code Entry Required by Customer: Y,N';
COMMENT ON COLUMN sa.x_promo_ui.x_promo_channel IS 'Channel: WEBCSR,WEB,IVR,ALL';
COMMENT ON COLUMN sa.x_promo_ui.x_promo_benefit IS 'Promotion benefit: DISC_AMT,UNITS';
COMMENT ON COLUMN sa.x_promo_ui.x_promo_bene_type IS 'benefit Type:COMPENSATION,FREE';
COMMENT ON COLUMN sa.x_promo_ui.x_trans_type IS 'Type of transaction: BP_ENROLL,PURCHASE,REACTIVATION,REDEMPTION';
COMMENT ON COLUMN sa.x_promo_ui.x_trans_type_lvl1 IS 'Denomination Specific: ANY,SPEC';
COMMENT ON COLUMN sa.x_promo_ui.x_trans_type_lvl2 IS 'Denominations Filter when SPEC in LVL1';
COMMENT ON COLUMN sa.x_promo_ui.x_trans_type_lvl3 IS 'Days Filter when SPEC in LVL1';
COMMENT ON COLUMN sa.x_promo_ui.x_trans_rule IS 'not used';
COMMENT ON COLUMN sa.x_promo_ui.x_frequency IS 'not used';
COMMENT ON COLUMN sa.x_promo_ui.x_trans_rule_value IS 'not used';
COMMENT ON COLUMN sa.x_promo_ui.x_esn_qual IS 'ESN Qualification: DEFINE,GROUP,OPEN';
COMMENT ON COLUMN sa.x_promo_ui.x_group_name IS 'Required if GROUP in ESN_QUAL';
COMMENT ON COLUMN sa.x_promo_ui.x_esn_tech IS 'Phone Technology';
COMMENT ON COLUMN sa.x_promo_ui.x_esn_model IS 'Phone Part Class';
COMMENT ON COLUMN sa.x_promo_ui.x_esn_part IS 'Phone Part Number';
COMMENT ON COLUMN sa.x_promo_ui.x_mrkt_state IS 'State Code';
COMMENT ON COLUMN sa.x_promo_ui.x_mrkt_zip IS 'Zip Code';
COMMENT ON COLUMN sa.x_promo_ui.x_bp_enrolled IS 'Enrolled in Billing Program';
COMMENT ON COLUMN sa.x_promo_ui.x_member_in IS 'not used';
COMMENT ON COLUMN sa.x_promo_ui.x_valid_plans IS 'not used';
COMMENT ON COLUMN sa.x_promo_ui.x_valid_contact IS 'not used';
COMMENT ON COLUMN sa.x_promo_ui.x_act_channel IS 'Activation Channel';
COMMENT ON COLUMN sa.x_promo_ui.x_last_redmp_channel IS 'Last Redemption Channel';
COMMENT ON COLUMN sa.x_promo_ui.x_myacct_info IS 'not used';
COMMENT ON COLUMN sa.x_promo_ui.x_esn_dealer IS 'not used';
COMMENT ON COLUMN sa.x_promo_ui.x_campgn_prtcpt_times IS 'not used';
COMMENT ON COLUMN sa.x_promo_ui.x_campgn_prtcpt_method IS 'not used';
COMMENT ON COLUMN sa.x_promo_ui.x_campgn_rcpt_times IS 'not used';
COMMENT ON COLUMN sa.x_promo_ui.x_campgn_rcpt_method IS 'not used';
COMMENT ON COLUMN sa.x_promo_ui.x_cost_center IS 'Cost Center that in Paying for the promotion';
COMMENT ON COLUMN sa.x_promo_ui.x_approve_flag IS 'Approval Flag: Y,N';
COMMENT ON COLUMN sa.x_promo_ui.x_cr_no IS 'Change Request Number';
COMMENT ON COLUMN sa.x_promo_ui.x_promote_env IS 'Environment Promoted to';
COMMENT ON COLUMN sa.x_promo_ui.x_created_by2user IS 'Reference to table_user';
COMMENT ON COLUMN sa.x_promo_ui.x_created_date IS 'Timestamp';
COMMENT ON COLUMN sa.x_promo_ui.x_updated_by2user IS 'reference to table_user';
COMMENT ON COLUMN sa.x_promo_ui.x_updated_date IS 'Last update timestamp';
COMMENT ON COLUMN sa.x_promo_ui.x_bonus_sms IS 'Bonus Sms';
COMMENT ON COLUMN sa.x_promo_ui.x_bonus_data_mb IS 'Bonus Data in mb';
COMMENT ON COLUMN sa.x_promo_ui.x_device_type IS 'Device type';
COMMENT ON COLUMN sa.x_promo_ui.x_trans_type_lvl4 IS 'SMS Filter when SPEC in LVL1';
COMMENT ON COLUMN sa.x_promo_ui.x_trans_type_lvl5 IS 'DATA(MB) Filter when SPEC in LVL1';