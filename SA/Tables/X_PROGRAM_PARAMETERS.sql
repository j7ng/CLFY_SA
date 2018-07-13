CREATE TABLE sa.x_program_parameters (
  objid NUMBER,
  x_program_name VARCHAR2(40 BYTE),
  x_program_desc VARCHAR2(1000 BYTE),
  x_type VARCHAR2(10 BYTE),
  x_csr_channel NUMBER,
  x_ivr_channel NUMBER,
  x_web_channel NUMBER,
  x_combine_self NUMBER,
  x_combine_other NUMBER,
  x_start_date DATE,
  x_end_date DATE,
  x_grp_esn_count NUMBER,
  x_is_recurring NUMBER,
  x_benefit_days NUMBER,
  x_handset_value VARCHAR2(15 BYTE),
  x_carrmkt_value VARCHAR2(15 BYTE),
  x_carrparent_value VARCHAR2(15 BYTE),
  x_ach_grace_period NUMBER,
  x_add_ph_window NUMBER,
  x_min_unit_rate_minutes NUMBER,
  x_min_unit_rate_cents NUMBER,
  x_grace_period_webcsr NUMBER,
  x_delay_enroll_ach_flag NUMBER,
  x_de_enroll_cutoff_code NUMBER,
  x_delivery_frq_code VARCHAR2(15 BYTE),
  x_first_delivery_date_code VARCHAR2(15 BYTE),
  x_incl_service_days NUMBER,
  x_stack_at_enroll VARCHAR2(10 BYTE),
  x_stack_dur_enroll VARCHAR2(10 BYTE),
  x_vol_deenro_ser_days_less NUMBER,
  x_deenroll_add_ser_days NUMBER,
  x_benefit_cutoff_code NUMBER,
  x_ser_days_float_ach NUMBER,
  x_ser_days_float_nonach NUMBER,
  x_paynow_grace_period_ach NUMBER,
  x_paynow_grace_period_non NUMBER,
  x_sales_tax_flag NUMBER,
  x_sales_tax_charge_cust NUMBER(1),
  x_additional_tax1 NUMBER,
  x_additional_tax2 NUMBER,
  x_charge_frq_code VARCHAR2(15 BYTE),
  x_bill_cyl_shift_days NUMBER,
  x_payment_method_code NUMBER,
  x_low_balance_units NUMBER,
  x_low_balance_dollars NUMBER,
  x_promo_incl_min_at NUMBER,
  x_promo_incl_min_op NUMBER,
  x_promo_incl_min_we NUMBER,
  x_incl_data_units NUMBER,
  x_incl_data_dollors NUMBER,
  x_promo_incr_min_at NUMBER,
  x_promo_incr_min_op NUMBER,
  x_promo_incr_min_we NUMBER,
  x_incr_data_units NUMBER,
  x_incr_data_dollors NUMBER,
  x_add_funds_min NUMBER,
  x_add_funds_max NUMBER,
  x_add_funds_incr NUMBER,
  x_promo_incl_grpmin_at NUMBER,
  x_promo_incl_grpmin_op NUMBER,
  x_promo_incl_grpmin_we NUMBER,
  x_incl_data_grpunits NUMBER,
  x_incl_data_grpdollors NUMBER,
  x_promo_incr_grpmin_at NUMBER,
  x_promo_incr_grpmin_op NUMBER,
  x_promo_incr_grpmin_we NUMBER,
  x_incr_data_grpunits NUMBER,
  x_incr_data_grpdollors NUMBER,
  x_add_grp_funds_min NUMBER,
  x_add_grp_funds_max NUMBER,
  x_add_grp_funds_incr NUMBER,
  x_incr_minutes_dlv_days NUMBER,
  x_incr_minutes_dlv_cyl NUMBER(2),
  x_incr_grp_minutes_dlv_days NUMBER,
  x_incr_grp_minutes_dlv_cyl NUMBER(2),
  prog_param2prtnum_enrlfee NUMBER,
  prog_param2prtnum_monfee NUMBER,
  prog_param2prtnum_grpenrlfee NUMBER,
  prog_param2prtnum_grpmonfee NUMBER,
  prog_param2bus_org NUMBER,
  x_prog_class VARCHAR2(10 BYTE),
  x_e911_tax_flag NUMBER DEFAULT 1,
  x_e911_tax_charge_cust NUMBER(1) DEFAULT 1,
  x_bill_engine_flag NUMBER DEFAULT 1,
  x_rules_engine_flag NUMBER DEFAULT 1,
  x_notify_engine_flag NUMBER DEFAULT 1,
  x_off_channel NUMBER DEFAULT 0,
  x_ics_applications VARCHAR2(50 BYTE),
  x_membership_value VARCHAR2(30 BYTE) DEFAULT 'NONE',
  x_promo_group_value VARCHAR2(30 BYTE) DEFAULT 'NONE',
  x_retailer_value VARCHAR2(30 BYTE) DEFAULT 'NONE',
  x_sms_rate NUMBER,
  x_ild NUMBER,
  x_sweep_and_add_flag NUMBER,
  x_free_dial2site NUMBER,
  x_prg_script_id VARCHAR2(30 BYTE),
  x_prg_desc_script_id VARCHAR2(30 BYTE),
  prog_param2app_prt_num NUMBER(22),
  brm_applicable_flag VARCHAR2(1 BYTE) DEFAULT 'N',
  exclude_lifeline_monthly_flag VARCHAR2(1 BYTE),
  exclude_lifeline_daily_flag VARCHAR2(1 BYTE)
);
ALTER TABLE sa.x_program_parameters ADD SUPPLEMENTAL LOG GROUP dmtsora551471331_0 (objid, x_ach_grace_period, x_add_ph_window, x_benefit_cutoff_code, x_benefit_days, x_carrmkt_value, x_carrparent_value, x_combine_other, x_combine_self, x_csr_channel, x_deenroll_add_ser_days, x_delay_enroll_ach_flag, x_delivery_frq_code, x_de_enroll_cutoff_code, x_end_date, x_first_delivery_date_code, x_grace_period_webcsr, x_grp_esn_count, x_handset_value, x_incl_service_days, x_is_recurring, x_ivr_channel, x_min_unit_rate_cents, x_min_unit_rate_minutes, x_program_desc, x_program_name, x_ser_days_float_ach, x_stack_at_enroll, x_stack_dur_enroll, x_start_date, x_type, x_vol_deenro_ser_days_less, x_web_channel) ALWAYS;
ALTER TABLE sa.x_program_parameters ADD SUPPLEMENTAL LOG GROUP dmtsora551471331_1 (x_additional_tax1, x_additional_tax2, x_add_funds_incr, x_add_funds_max, x_add_funds_min, x_bill_cyl_shift_days, x_charge_frq_code, x_incl_data_dollors, x_incl_data_grpdollors, x_incl_data_grpunits, x_incl_data_units, x_incr_data_dollors, x_incr_data_units, x_low_balance_dollars, x_low_balance_units, x_payment_method_code, x_paynow_grace_period_ach, x_paynow_grace_period_non, x_promo_incl_grpmin_at, x_promo_incl_grpmin_op, x_promo_incl_grpmin_we, x_promo_incl_min_at, x_promo_incl_min_op, x_promo_incl_min_we, x_promo_incr_grpmin_at, x_promo_incr_grpmin_op, x_promo_incr_grpmin_we, x_promo_incr_min_at, x_promo_incr_min_op, x_promo_incr_min_we, x_sales_tax_charge_cust, x_sales_tax_flag, x_ser_days_float_nonach) ALWAYS;
ALTER TABLE sa.x_program_parameters ADD SUPPLEMENTAL LOG GROUP dmtsora551471331_2 (prog_param2bus_org, prog_param2prtnum_enrlfee, prog_param2prtnum_grpenrlfee, prog_param2prtnum_grpmonfee, prog_param2prtnum_monfee, x_add_grp_funds_incr, x_add_grp_funds_max, x_add_grp_funds_min, x_bill_engine_flag, x_e911_tax_charge_cust, x_e911_tax_flag, x_ics_applications, x_incr_data_grpdollors, x_incr_data_grpunits, x_incr_grp_minutes_dlv_cyl, x_incr_grp_minutes_dlv_days, x_incr_minutes_dlv_cyl, x_incr_minutes_dlv_days, x_membership_value, x_notify_engine_flag, x_off_channel, x_prog_class, x_promo_group_value, x_retailer_value, x_rules_engine_flag) ALWAYS;
COMMENT ON TABLE sa.x_program_parameters IS 'Billing Plan Definition Table, this table contain most of the elements that define a billing program, name, description, benefits and cost.';
COMMENT ON COLUMN sa.x_program_parameters.x_program_name IS 'Name of the billing program';
COMMENT ON COLUMN sa.x_program_parameters.x_program_desc IS 'description of the billing program';
COMMENT ON COLUMN sa.x_program_parameters.x_type IS 'type of program: GROUP or INDIVIDUAL';
COMMENT ON COLUMN sa.x_program_parameters.x_csr_channel IS 'Billing program available in WEBCSR: 0=No, 1=Yes';
COMMENT ON COLUMN sa.x_program_parameters.x_ivr_channel IS 'Billing program available in IVR: 0=No, 1=Yes';
COMMENT ON COLUMN sa.x_program_parameters.x_web_channel IS 'Billing program available in WEB: 0=No, 1=Yes';
COMMENT ON COLUMN sa.x_program_parameters.x_combine_self IS 'The program can be combine with it self';
COMMENT ON COLUMN sa.x_program_parameters.x_combine_other IS 'The program can be combine with other programs';
COMMENT ON COLUMN sa.x_program_parameters.x_start_date IS 'Date program starts being available for customers';
COMMENT ON COLUMN sa.x_program_parameters.x_end_date IS 'Date program stops being available for customers';
COMMENT ON COLUMN sa.x_program_parameters.x_grp_esn_count IS 'How many ESNs can be in the plan, used for GROUP plans.';
COMMENT ON COLUMN sa.x_program_parameters.x_is_recurring IS 'Is the plan recurrent or not: 0=No, 1=Yes';
COMMENT ON COLUMN sa.x_program_parameters.x_benefit_days IS 'Numbers of days of service offered by the plan';
COMMENT ON COLUMN sa.x_program_parameters.x_handset_value IS 'Model Restriction Type: NONE,PERMITTED,RESTRICTED.  Use in conjuction with the table: x_mtm_program_handset. Implemented in procedure: ESN_STATUS_ENROLL_ELEGIBLE.';
COMMENT ON COLUMN sa.x_program_parameters.x_carrmkt_value IS 'Carrier Restriction Type: NONE,PERMITTED,RESTRICTED.  Use in conjuction with the table: X_MTM_PROGRAM_CARRMKT. Implemented in procedure: ESN_STATUS_ENROLL_ELEGIBLE.';
COMMENT ON COLUMN sa.x_program_parameters.x_carrparent_value IS 'Carrier Parent Restriction Type: NONE,PERMITTED,RESTRICTED.  Use in conjuction with the table: X_MTM_PROGRAM_CARRPARENT. Implemented in procedure: ESN_STATUS_ENROLL_ELEGIBLE.';
COMMENT ON COLUMN sa.x_program_parameters.x_ach_grace_period IS 'Grace Period allowed for ACH Payments';
COMMENT ON COLUMN sa.x_program_parameters.x_add_ph_window IS 'Time window in days that a new phone can be added to famili program.';
COMMENT ON COLUMN sa.x_program_parameters.x_min_unit_rate_minutes IS 'not in use, minutes rate';
COMMENT ON COLUMN sa.x_program_parameters.x_min_unit_rate_cents IS 'not in use, cents per minute';
COMMENT ON COLUMN sa.x_program_parameters.x_grace_period_webcsr IS 'Grace Period that can be given in WEBCSR';
COMMENT ON COLUMN sa.x_program_parameters.x_delay_enroll_ach_flag IS 'Flag to delay enrollment when payment is ACH: 0=No, 1=Yes';
COMMENT ON COLUMN sa.x_program_parameters.x_de_enroll_cutoff_code IS 'Code to be use when de-enrolling from program.';
COMMENT ON COLUMN sa.x_program_parameters.x_delivery_frq_code IS 'When should the benefits be delivered: AFTERCHARGE, MONTLY,MON,TUE,WED,THU,FRI,SAT,SUN.';
COMMENT ON COLUMN sa.x_program_parameters.x_first_delivery_date_code IS 'Date for the first delivery of benefits';
COMMENT ON COLUMN sa.x_program_parameters.x_incl_service_days IS 'Service Days Included with the Program Benefits';
COMMENT ON COLUMN sa.x_program_parameters.x_stack_at_enroll IS 'Stack benefits at enrollment';
COMMENT ON COLUMN sa.x_program_parameters.x_stack_dur_enroll IS 'Type of benefit stacking allowed by program: NO,FULL,GAP';
COMMENT ON COLUMN sa.x_program_parameters.x_vol_deenro_ser_days_less IS 'minimum days before expiration that an service extension can be requested.';
COMMENT ON COLUMN sa.x_program_parameters.x_deenroll_add_ser_days IS 'service extension days';
COMMENT ON COLUMN sa.x_program_parameters.x_benefit_cutoff_code IS 'not in use';
COMMENT ON COLUMN sa.x_program_parameters.x_ser_days_float_ach IS 'Additional service days required for ACH processing.';
COMMENT ON COLUMN sa.x_program_parameters.x_ser_days_float_nonach IS 'Additional service days required for non ACH processing.';
COMMENT ON COLUMN sa.x_program_parameters.x_paynow_grace_period_ach IS 'Grace Period when using PayNow with ACH';
COMMENT ON COLUMN sa.x_program_parameters.x_paynow_grace_period_non IS 'Grace Period when using PayNow with non ACH';
COMMENT ON COLUMN sa.x_program_parameters.x_sales_tax_flag IS 'Flag to calculate Taxes: 0=No, 1=Yes';
COMMENT ON COLUMN sa.x_program_parameters.x_sales_tax_charge_cust IS 'Flag to calculate Taxes: 0=No, 1=Yes';
COMMENT ON COLUMN sa.x_program_parameters.x_additional_tax1 IS 'Additional Tax Amount 1';
COMMENT ON COLUMN sa.x_program_parameters.x_additional_tax2 IS 'Additional Tax Amount 2';
COMMENT ON COLUMN sa.x_program_parameters.x_charge_frq_code IS 'Frequency Code for Recurrent Charge: 180
30
365
90
LOWBALANCE
MONTHLY
PASTDUE';
COMMENT ON COLUMN sa.x_program_parameters.x_bill_cyl_shift_days IS ' Max Shift in Billing Cycle';
COMMENT ON COLUMN sa.x_program_parameters.x_payment_method_code IS 'Not used';
COMMENT ON COLUMN sa.x_program_parameters.x_low_balance_units IS 'Not used';
COMMENT ON COLUMN sa.x_program_parameters.x_low_balance_dollars IS 'Not used';
COMMENT ON COLUMN sa.x_program_parameters.x_promo_incl_min_at IS 'Not used';
COMMENT ON COLUMN sa.x_program_parameters.x_promo_incl_min_op IS 'Not used';
COMMENT ON COLUMN sa.x_program_parameters.x_promo_incl_min_we IS 'Not used';
COMMENT ON COLUMN sa.x_program_parameters.x_incl_data_units IS 'Not used';
COMMENT ON COLUMN sa.x_program_parameters.x_incl_data_dollors IS 'Not used';
COMMENT ON COLUMN sa.x_program_parameters.x_promo_incr_min_at IS 'Not used';
COMMENT ON COLUMN sa.x_program_parameters.x_promo_incr_min_op IS 'Not used';
COMMENT ON COLUMN sa.x_program_parameters.x_promo_incr_min_we IS 'Not used';
COMMENT ON COLUMN sa.x_program_parameters.x_incr_data_units IS 'Not used';
COMMENT ON COLUMN sa.x_program_parameters.x_incr_data_dollors IS 'Not used';
COMMENT ON COLUMN sa.x_program_parameters.x_add_funds_min IS 'Not used';
COMMENT ON COLUMN sa.x_program_parameters.x_add_funds_max IS 'Not used';
COMMENT ON COLUMN sa.x_program_parameters.x_add_funds_incr IS 'Not used';
COMMENT ON COLUMN sa.x_program_parameters.x_promo_incl_grpmin_at IS 'Not used';
COMMENT ON COLUMN sa.x_program_parameters.x_promo_incl_grpmin_op IS 'Not used';
COMMENT ON COLUMN sa.x_program_parameters.x_promo_incl_grpmin_we IS 'Not used';
COMMENT ON COLUMN sa.x_program_parameters.x_incl_data_grpunits IS 'Not used';
COMMENT ON COLUMN sa.x_program_parameters.x_incl_data_grpdollors IS 'Not used';
COMMENT ON COLUMN sa.x_program_parameters.x_promo_incr_grpmin_at IS 'Not used';
COMMENT ON COLUMN sa.x_program_parameters.x_promo_incr_grpmin_op IS 'Not used';
COMMENT ON COLUMN sa.x_program_parameters.x_promo_incr_grpmin_we IS 'Not used';
COMMENT ON COLUMN sa.x_program_parameters.x_incr_data_grpunits IS 'Not used';
COMMENT ON COLUMN sa.x_program_parameters.x_incr_data_grpdollors IS 'Not used';
COMMENT ON COLUMN sa.x_program_parameters.x_add_grp_funds_min IS 'Not used';
COMMENT ON COLUMN sa.x_program_parameters.x_add_grp_funds_max IS 'Not used';
COMMENT ON COLUMN sa.x_program_parameters.x_add_grp_funds_incr IS 'Not used';
COMMENT ON COLUMN sa.x_program_parameters.x_incr_minutes_dlv_days IS 'Not used';
COMMENT ON COLUMN sa.x_program_parameters.x_incr_minutes_dlv_cyl IS 'Not used';
COMMENT ON COLUMN sa.x_program_parameters.x_incr_grp_minutes_dlv_days IS 'Not used';
COMMENT ON COLUMN sa.x_program_parameters.x_incr_grp_minutes_dlv_cyl IS 'Not used';
COMMENT ON COLUMN sa.x_program_parameters.prog_param2prtnum_enrlfee IS 'Reference to table_part_number. Enrollment Fee Part Number';
COMMENT ON COLUMN sa.x_program_parameters.prog_param2prtnum_monfee IS 'Reference to table_part_number. Monthly Fee Part Number';
COMMENT ON COLUMN sa.x_program_parameters.prog_param2prtnum_grpenrlfee IS 'Reference to table_part_number. Group Enrollment Fee Part Number';
COMMENT ON COLUMN sa.x_program_parameters.prog_param2prtnum_grpmonfee IS 'Reference to table_part_number. Montly Group Enrollment Fee Part Number';
COMMENT ON COLUMN sa.x_program_parameters.prog_param2bus_org IS 'Reference to table_bus_org, Business Line';
COMMENT ON COLUMN sa.x_program_parameters.x_prog_class IS 'Billing Program Category';
COMMENT ON COLUMN sa.x_program_parameters.x_e911_tax_flag IS 'Flag to Calculate e911 tax, 0=No, 1=Yes';
COMMENT ON COLUMN sa.x_program_parameters.x_e911_tax_charge_cust IS 'Flag to Charge  e911 tax, 0=No, 1=Yes';
COMMENT ON COLUMN sa.x_program_parameters.x_bill_engine_flag IS 'Billing Engine Flag: 0=No, 1=Yes';
COMMENT ON COLUMN sa.x_program_parameters.x_rules_engine_flag IS 'Rules Engine Flag: 0=No, 1=Yes';
COMMENT ON COLUMN sa.x_program_parameters.x_notify_engine_flag IS 'Notify Engine Flag: 0=No, 1=Yes';
COMMENT ON COLUMN sa.x_program_parameters.x_off_channel IS 'Offer program in WEB and CSR  Channels: 0=Offer, 1=NotOffer';
COMMENT ON COLUMN sa.x_program_parameters.x_ics_applications IS 'Not used';
COMMENT ON COLUMN sa.x_program_parameters.x_membership_value IS 'Not used';
COMMENT ON COLUMN sa.x_program_parameters.x_promo_group_value IS 'Not used';
COMMENT ON COLUMN sa.x_program_parameters.x_retailer_value IS 'Not used';
COMMENT ON COLUMN sa.x_program_parameters.x_sms_rate IS 'Reference to x_plan_id in table_x_click_plan, used for SafeLink Programs that offer a click change for SMS service.';
COMMENT ON COLUMN sa.x_program_parameters.x_ild IS 'ILD Flag: 0=No, 1=Yes, used for SafeLink Billing Programs.';
COMMENT ON COLUMN sa.x_program_parameters.x_sweep_and_add_flag IS 'Sweep and Add Flag: 0=No, 1=Yes';
COMMENT ON COLUMN sa.x_program_parameters.x_free_dial2site IS 'REFERENCE TO OBJID IN TABLE_SITE';