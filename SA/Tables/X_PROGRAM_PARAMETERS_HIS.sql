CREATE TABLE sa.x_program_parameters_his (
  "SID" NUMBER,
  "ACTION" VARCHAR2(10 BYTE),
  username VARCHAR2(30 BYTE),
  osuser VARCHAR2(100 BYTE),
  "PROCESS" VARCHAR2(100 BYTE),
  machine VARCHAR2(100 BYTE),
  terminal VARCHAR2(100 BYTE),
  "PROGRAM" VARCHAR2(100 BYTE),
  logon_time DATE,
  dt DATE,
  old_objid NUMBER,
  old_x_program_name VARCHAR2(40 BYTE),
  old_x_program_desc VARCHAR2(1000 BYTE),
  old_x_type VARCHAR2(10 BYTE),
  old_x_csr_channel NUMBER,
  old_x_ivr_channel NUMBER,
  old_x_web_channel NUMBER,
  old_x_combine_self NUMBER,
  old_x_combine_other NUMBER,
  old_x_start_date DATE,
  old_x_end_date DATE,
  old_x_grp_esn_count NUMBER,
  old_x_is_recurring NUMBER,
  old_x_benefit_days NUMBER,
  old_x_handset_value VARCHAR2(15 BYTE),
  old_x_carrmkt_value VARCHAR2(15 BYTE),
  old_x_carrparent_value VARCHAR2(15 BYTE),
  old_x_ach_grace_period NUMBER,
  old_x_add_ph_window NUMBER,
  old_x_min_unit_rate_minutes NUMBER,
  old_x_min_unit_rate_cents NUMBER,
  old_x_grace_period_webcsr NUMBER,
  old_x_delay_enroll_ach_flag NUMBER,
  old_x_de_enroll_cutoff_code NUMBER,
  old_x_delivery_frq_code VARCHAR2(15 BYTE),
  old_x_first_del_date_code VARCHAR2(15 BYTE),
  old_x_incl_service_days NUMBER,
  old_x_stack_at_enroll VARCHAR2(10 BYTE),
  old_x_stack_dur_enroll VARCHAR2(10 BYTE),
  old_x_vol_deenro_ser_days_le NUMBER,
  old_x_deenroll_add_ser_days NUMBER,
  old_x_benefit_cutoff_code NUMBER,
  old_x_ser_days_float_ach NUMBER,
  old_x_ser_days_float_nonach NUMBER,
  old_x_paynow_grace_period_ach NUMBER,
  old_x_paynow_grace_period_non NUMBER,
  old_x_sales_tax_flag NUMBER,
  old_x_sales_tax_charge_cust NUMBER(1),
  old_x_additional_tax1 NUMBER,
  old_x_additional_tax2 NUMBER,
  old_x_charge_frq_code VARCHAR2(15 BYTE),
  old_x_bill_cyl_shift_days NUMBER,
  old_x_payment_method_code NUMBER,
  old_x_low_balance_units NUMBER,
  old_x_low_balance_dollars NUMBER,
  old_x_promo_incl_min_at NUMBER,
  old_x_promo_incl_min_op NUMBER,
  old_x_promo_incl_min_we NUMBER,
  old_x_incl_data_units NUMBER,
  old_x_incl_data_dollors NUMBER,
  old_x_promo_incr_min_at NUMBER,
  old_x_promo_incr_min_op NUMBER,
  old_x_promo_incr_min_we NUMBER,
  old_x_incr_data_units NUMBER,
  old_x_incr_data_dollors NUMBER,
  old_x_add_funds_min NUMBER,
  old_x_add_funds_max NUMBER,
  old_x_add_funds_incr NUMBER,
  old_x_promo_incl_grpmin_at NUMBER,
  old_x_promo_incl_grpmin_op NUMBER,
  old_x_promo_incl_grpmin_we NUMBER,
  old_x_incl_data_grpunits NUMBER,
  old_x_incl_data_grpdollors NUMBER,
  old_x_promo_incr_grpmin_at NUMBER,
  old_x_promo_incr_grpmin_op NUMBER,
  old_x_promo_incr_grpmin_we NUMBER,
  old_x_incr_data_grpunits NUMBER,
  old_x_incr_data_grpdollors NUMBER,
  old_x_add_grp_funds_min NUMBER,
  old_x_add_grp_funds_max NUMBER,
  old_x_add_grp_funds_incr NUMBER,
  old_x_incr_minutes_dlv_days NUMBER,
  old_x_incr_minutes_dlv_cyl NUMBER(2),
  old_x_incr_grp_min_dlv_days NUMBER,
  old_x_incr_grp_min_dlv_cyl NUMBER(2),
  old_prog_p2pn_enrlfee NUMBER,
  old_prog_p2pn_monfee NUMBER,
  old_prog_p2pn_grpenrlfee NUMBER,
  old_prog_p2pn_grpmonfee NUMBER,
  old_prog_param2bus_org NUMBER,
  old_x_prog_class VARCHAR2(10 BYTE),
  old_x_e911_tax_flag NUMBER,
  old_x_e911_tax_charge_cust NUMBER(1),
  old_x_bill_engine_flag NUMBER,
  old_x_rules_engine_flag NUMBER,
  old_x_notify_engine_flag NUMBER,
  old_x_off_channel NUMBER,
  old_x_ics_applications VARCHAR2(50 BYTE),
  old_x_membership_value VARCHAR2(30 BYTE),
  old_x_promo_group_value VARCHAR2(30 BYTE),
  old_x_retailer_value VARCHAR2(30 BYTE),
  old_x_sms_rate NUMBER,
  old_x_ild NUMBER,
  old_x_sweep_and_add_flag NUMBER,
  old_x_free_dial2site NUMBER,
  new_objid NUMBER,
  new_x_program_name VARCHAR2(40 BYTE),
  new_x_program_desc VARCHAR2(1000 BYTE),
  new_x_type VARCHAR2(10 BYTE),
  new_x_csr_channel NUMBER,
  new_x_ivr_channel NUMBER,
  new_x_web_channel NUMBER,
  new_x_combine_self NUMBER,
  new_x_combine_other NUMBER,
  new_x_start_date DATE,
  new_x_end_date DATE,
  new_x_grp_esn_count NUMBER,
  new_x_is_recurring NUMBER,
  new_x_benefit_days NUMBER,
  new_x_handset_value VARCHAR2(15 BYTE),
  new_x_carrmkt_value VARCHAR2(15 BYTE),
  new_x_carrparent_value VARCHAR2(15 BYTE),
  new_x_ach_grace_period NUMBER,
  new_x_add_ph_window NUMBER,
  new_x_min_unit_rate_minutes NUMBER,
  new_x_min_unit_rate_cents NUMBER,
  new_x_grace_period_webcsr NUMBER,
  new_x_delay_enroll_ach_flag NUMBER,
  new_x_de_enroll_cutoff_code NUMBER,
  new_x_delivery_frq_code VARCHAR2(15 BYTE),
  new_x_first_del_date_code VARCHAR2(15 BYTE),
  new_x_incl_service_days NUMBER,
  new_x_stack_at_enroll VARCHAR2(10 BYTE),
  new_x_stack_dur_enroll VARCHAR2(10 BYTE),
  new_x_vol_deenro_ser_days_le NUMBER,
  new_x_deenroll_add_ser_days NUMBER,
  new_x_benefit_cutoff_code NUMBER,
  new_x_ser_days_float_ach NUMBER,
  new_x_ser_days_float_nonach NUMBER,
  new_x_paynow_grace_period_ach NUMBER,
  new_x_paynow_grace_period_non NUMBER,
  new_x_sales_tax_flag NUMBER,
  new_x_sales_tax_charge_cust NUMBER(1),
  new_x_additional_tax1 NUMBER,
  new_x_additional_tax2 NUMBER,
  new_x_charge_frq_code VARCHAR2(15 BYTE),
  new_x_bill_cyl_shift_days NUMBER,
  new_x_payment_method_code NUMBER,
  new_x_low_balance_units NUMBER,
  new_x_low_balance_dollars NUMBER,
  new_x_promo_incl_min_at NUMBER,
  new_x_promo_incl_min_op NUMBER,
  new_x_promo_incl_min_we NUMBER,
  new_x_incl_data_units NUMBER,
  new_x_incl_data_dollors NUMBER,
  new_x_promo_incr_min_at NUMBER,
  new_x_promo_incr_min_op NUMBER,
  new_x_promo_incr_min_we NUMBER,
  new_x_incr_data_units NUMBER,
  new_x_incr_data_dollors NUMBER,
  new_x_add_funds_min NUMBER,
  new_x_add_funds_max NUMBER,
  new_x_add_funds_incr NUMBER,
  new_x_promo_incl_grpmin_at NUMBER,
  new_x_promo_incl_grpmin_op NUMBER,
  new_x_promo_incl_grpmin_we NUMBER,
  new_x_incl_data_grpunits NUMBER,
  new_x_incl_data_grpdollors NUMBER,
  new_x_promo_incr_grpmin_at NUMBER,
  new_x_promo_incr_grpmin_op NUMBER,
  new_x_promo_incr_grpmin_we NUMBER,
  new_x_incr_data_grpunits NUMBER,
  new_x_incr_data_grpdollors NUMBER,
  new_x_add_grp_funds_min NUMBER,
  new_x_add_grp_funds_max NUMBER,
  new_x_add_grp_funds_incr NUMBER,
  new_x_incr_minutes_dlv_days NUMBER,
  new_x_incr_minutes_dlv_cyl NUMBER(2),
  new_x_incr_grp_min_dlv_days NUMBER,
  new_x_incr_grp_min_dlv_cyl NUMBER(2),
  new_prog_p2pn_enrlfee NUMBER,
  new_prog_p2pn_monfee NUMBER,
  new_prog_p2pn_grpenrlfee NUMBER,
  new_prog_p2pn_grpmonfee NUMBER,
  new_prog_param2bus_org NUMBER,
  new_x_prog_class VARCHAR2(10 BYTE),
  new_x_e911_tax_flag NUMBER,
  new_x_e911_tax_charge_cust NUMBER(1),
  new_x_bill_engine_flag NUMBER,
  new_x_rules_engine_flag NUMBER,
  new_x_notify_engine_flag NUMBER,
  new_x_off_channel NUMBER,
  new_x_ics_applications VARCHAR2(50 BYTE),
  new_x_membership_value VARCHAR2(30 BYTE),
  new_x_promo_group_value VARCHAR2(30 BYTE),
  new_x_retailer_value VARCHAR2(30 BYTE),
  new_x_sms_rate NUMBER,
  new_x_ild NUMBER,
  new_x_sweep_and_add_flag NUMBER,
  new_x_free_dial2site NUMBER
);