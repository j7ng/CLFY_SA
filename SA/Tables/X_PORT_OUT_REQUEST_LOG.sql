CREATE TABLE sa.x_port_out_request_log (
  "MIN" VARCHAR2(100 BYTE) NOT NULL,
  esn VARCHAR2(100 BYTE),
  request_no VARCHAR2(100 BYTE) NOT NULL,
  request_date DATE NOT NULL,
  request_type VARCHAR2(1 BYTE) NOT NULL,
  short_parent_name VARCHAR2(100 BYTE),
  brand_shared_group_flag VARCHAR2(1 BYTE),
  case_id_number VARCHAR2(100 BYTE),
  desired_due_date DATE,
  nnsp VARCHAR2(100 BYTE),
  directional_indicator VARCHAR2(100 BYTE),
  osp_account_no VARCHAR2(100 BYTE),
  error_code VARCHAR2(100 BYTE),
  error_message VARCHAR2(2400 BYTE),
  status VARCHAR2(300 BYTE) NOT NULL,
  site_part_objid NUMBER(22),
  service_end_date DATE,
  expiration_date DATE,
  deactivation_reason VARCHAR2(100 BYTE),
  notify_carrier NUMBER(22),
  site_part_status VARCHAR2(100 BYTE),
  service_plan_objid NUMBER(22),
  ild_transaction_status VARCHAR2(100 BYTE),
  esn_part_inst_objid NUMBER(22),
  esn_part_inst_status VARCHAR2(100 BYTE),
  esn_part_inst_code NUMBER(22),
  reactivation_flag NUMBER(22),
  contact_objid NUMBER(22),
  esn_new_personality_objid NUMBER(22),
  pgm_enroll_objid NUMBER(22),
  pgm_enrollment_status VARCHAR2(30 BYTE),
  pgm_enroll_exp_date DATE,
  pgm_enroll_cooling_exp_date DATE,
  pgm_enroll_next_delivery_date DATE,
  pgm_enroll_next_charge_date DATE,
  pgm_enroll_grace_period NUMBER(3),
  pgm_enroll_cooling_period NUMBER(3),
  pgm_enroll_service_days NUMBER(3),
  pgm_enroll_wait_exp_date DATE,
  pgm_enroll_charge_type VARCHAR2(30 BYTE),
  pgm_enrol_tot_grace_period_gn NUMBER(3),
  account_group_objid NUMBER(22),
  member_objid NUMBER(22),
  member_status VARCHAR2(100 BYTE),
  member_start_date DATE,
  member_end_date DATE,
  member_master_flag VARCHAR2(100 BYTE),
  service_order_stage_objid NUMBER(22),
  service_order_stage_status VARCHAR2(100 BYTE),
  min_part_inst_objid NUMBER(22),
  min_part_inst_status VARCHAR2(100 BYTE),
  min_part_inst_code NUMBER(22),
  min_cool_end_date DATE,
  min_warr_end_date DATE,
  repair_date DATE,
  min_personality_objid NUMBER(22),
  min_new_personality_objid NUMBER(22),
  min_to_esn_part_inst_objid NUMBER(22),
  last_cycle_date DATE,
  port_in NUMBER(22),
  psms_outbox_objid NUMBER(22),
  psms_outbox_status VARCHAR2(50 BYTE),
  ota_feat_objid NUMBER(22),
  ota_feat_ild_account VARCHAR2(50 BYTE),
  ota_feat_ild_carr_status VARCHAR2(50 BYTE),
  ota_feat_ild_prog_status VARCHAR2(50 BYTE),
  click_plan_hist_objid NUMBER(22),
  click_plan_hist_end_date DATE,
  fvm_status NUMBER(3),
  fvm_number VARCHAR2(50 BYTE),
  ota_transaction_objid NUMBER(22),
  ota_transaction_status VARCHAR2(50 BYTE),
  ota_transaction_reason VARCHAR2(150 BYTE),
  request_xml XMLTYPE,
  x_carrier VARCHAR2(30 BYTE),
  account_no VARCHAR2(50 BYTE),
  carrier VARCHAR2(50 BYTE),
  password_pin VARCHAR2(50 BYTE),
  v_key VARCHAR2(50 BYTE),
  full_name VARCHAR2(50 BYTE),
  billing_address VARCHAR2(50 BYTE),
  last_4_ssn VARCHAR2(50 BYTE),
  account_alpha VARCHAR2(50 BYTE),
  pin_alpha VARCHAR2(50 BYTE),
  zip_code VARCHAR2(50 BYTE)
);
COMMENT ON TABLE sa.x_port_out_request_log IS 'This table will used for logging activity for port out request  ';
COMMENT ON COLUMN sa.x_port_out_request_log."MIN" IS 'Mobile Indentification Number';
COMMENT ON COLUMN sa.x_port_out_request_log.request_no IS 'Port out request Number';
COMMENT ON COLUMN sa.x_port_out_request_log.request_date IS 'Request Date set to sysdate';
COMMENT ON COLUMN sa.x_port_out_request_log.request_type IS 'Request type R- Request ,C-cancel';
COMMENT ON COLUMN sa.x_port_out_request_log.short_parent_name IS 'Short Parent Name ';
COMMENT ON COLUMN sa.x_port_out_request_log.case_id_number IS 'Request case id number ';
COMMENT ON COLUMN sa.x_port_out_request_log.desired_due_date IS 'desired due date ';
COMMENT ON COLUMN sa.x_port_out_request_log.nnsp IS 'nnsp ';
COMMENT ON COLUMN sa.x_port_out_request_log.directional_indicator IS 'directional indicator';
COMMENT ON COLUMN sa.x_port_out_request_log.osp_account_no IS 'osp account no';
COMMENT ON COLUMN sa.x_port_out_request_log.error_code IS 'Error code';
COMMENT ON COLUMN sa.x_port_out_request_log.error_message IS 'Error message';
COMMENT ON COLUMN sa.x_port_out_request_log.status IS 'Request Status';
COMMENT ON COLUMN sa.x_port_out_request_log.site_part_objid IS 'Table site part objid ';
COMMENT ON COLUMN sa.x_port_out_request_log.service_end_date IS 'Table site part Service end date';
COMMENT ON COLUMN sa.x_port_out_request_log.expiration_date IS 'Table site part ';
COMMENT ON COLUMN sa.x_port_out_request_log.deactivation_reason IS 'Table site part ';
COMMENT ON COLUMN sa.x_port_out_request_log.notify_carrier IS 'Table site part ';
COMMENT ON COLUMN sa.x_port_out_request_log.site_part_status IS 'Table site part ';
COMMENT ON COLUMN sa.x_port_out_request_log.service_plan_objid IS 'Table site part ';
COMMENT ON COLUMN sa.x_port_out_request_log.ild_transaction_status IS 'Table_x_ild_transaction ';
COMMENT ON COLUMN sa.x_port_out_request_log.esn_part_inst_objid IS 'Table_part_inst esn record column objid';
COMMENT ON COLUMN sa.x_port_out_request_log.esn_part_inst_status IS 'Table_part_inst esn record column x_part_inst_status';
COMMENT ON COLUMN sa.x_port_out_request_log.esn_part_inst_code IS 'Table_part_inst esn record Column status2x_code_table';
COMMENT ON COLUMN sa.x_port_out_request_log.reactivation_flag IS 'Table_part_inst esn record column x_reactivation_flag';
COMMENT ON COLUMN sa.x_port_out_request_log.contact_objid IS 'Table_part_inst esn record column x_part_inst2contact';
COMMENT ON COLUMN sa.x_port_out_request_log.esn_new_personality_objid IS 'Table_part_inst esn record column part_inst2x_new_pers';
COMMENT ON COLUMN sa.x_port_out_request_log.pgm_enroll_objid IS 'x_program_enrolled column objid';
COMMENT ON COLUMN sa.x_port_out_request_log.pgm_enrollment_status IS 'x_program_enrolled column enrollment status';
COMMENT ON COLUMN sa.x_port_out_request_log.pgm_enroll_exp_date IS 'x_program_enrolled column exp_date          ';
COMMENT ON COLUMN sa.x_port_out_request_log.pgm_enroll_cooling_exp_date IS 'x_program_enrolled column cooling_exp_date  ';
COMMENT ON COLUMN sa.x_port_out_request_log.pgm_enroll_next_delivery_date IS 'x_program_enrolled column next_delivery_date';
COMMENT ON COLUMN sa.x_port_out_request_log.pgm_enroll_next_charge_date IS 'x_program_enrolled column next_charge_date  ';
COMMENT ON COLUMN sa.x_port_out_request_log.pgm_enroll_grace_period IS 'x_program_enrolled column grace_period      ';
COMMENT ON COLUMN sa.x_port_out_request_log.pgm_enroll_cooling_period IS 'x_program_enrolled column cooling_period    ';
COMMENT ON COLUMN sa.x_port_out_request_log.pgm_enroll_service_days IS 'x_program_enrolled column service_days      ';
COMMENT ON COLUMN sa.x_port_out_request_log.pgm_enroll_wait_exp_date IS 'x_program_enrolled column wait_exp_date     ';
COMMENT ON COLUMN sa.x_port_out_request_log.pgm_enroll_charge_type IS 'x_program_enrolled column charge_type       ';
COMMENT ON COLUMN sa.x_port_out_request_log.pgm_enrol_tot_grace_period_gn IS 'x_program_enrolled column tot_grace_period_given  ';
COMMENT ON COLUMN sa.x_port_out_request_log.account_group_objid IS 'Table_x_account_group_meber column';
COMMENT ON COLUMN sa.x_port_out_request_log.member_objid IS 'Table_x_account_group_meber column';
COMMENT ON COLUMN sa.x_port_out_request_log.member_status IS 'Table_x_account_group_meber column';
COMMENT ON COLUMN sa.x_port_out_request_log.member_start_date IS 'Table_x_account_group_meber column';
COMMENT ON COLUMN sa.x_port_out_request_log.member_end_date IS 'Table_x_account_group_meber column';
COMMENT ON COLUMN sa.x_port_out_request_log.member_master_flag IS 'Table_x_account_group_meber column';
COMMENT ON COLUMN sa.x_port_out_request_log.service_order_stage_objid IS 'Table x_service_order_stage column';
COMMENT ON COLUMN sa.x_port_out_request_log.service_order_stage_status IS 'Table x_service_order_stage column';
COMMENT ON COLUMN sa.x_port_out_request_log.min_part_inst_objid IS 'Table_part_inst min record column';
COMMENT ON COLUMN sa.x_port_out_request_log.min_part_inst_status IS 'Table_part_inst min record column';
COMMENT ON COLUMN sa.x_port_out_request_log.min_part_inst_code IS 'Table_part_inst min record column';
COMMENT ON COLUMN sa.x_port_out_request_log.min_cool_end_date IS 'Table_part_inst min record column';
COMMENT ON COLUMN sa.x_port_out_request_log.min_warr_end_date IS 'Table_part_inst min record column';
COMMENT ON COLUMN sa.x_port_out_request_log.repair_date IS 'Table_part_inst min record column';
COMMENT ON COLUMN sa.x_port_out_request_log.min_personality_objid IS 'Table_part_inst min record column';
COMMENT ON COLUMN sa.x_port_out_request_log.min_new_personality_objid IS 'Table_part_inst min record column';
COMMENT ON COLUMN sa.x_port_out_request_log.min_to_esn_part_inst_objid IS 'Table_part_inst min record column';
COMMENT ON COLUMN sa.x_port_out_request_log.last_cycle_date IS 'Table_part_inst min record column';
COMMENT ON COLUMN sa.x_port_out_request_log.port_in IS 'Table_part_inst min record column';
COMMENT ON COLUMN sa.x_port_out_request_log.psms_outbox_objid IS 'table_x_psms_outbox column objid';
COMMENT ON COLUMN sa.x_port_out_request_log.psms_outbox_status IS 'table_x_psms_outbox column status';
COMMENT ON COLUMN sa.x_port_out_request_log.ota_feat_objid IS 'table_x_ota_features column objid';
COMMENT ON COLUMN sa.x_port_out_request_log.ota_feat_ild_account IS 'table_x_ota_features column ild_account';
COMMENT ON COLUMN sa.x_port_out_request_log.ota_feat_ild_carr_status IS 'table_x_ota_features column ild_carr_status';
COMMENT ON COLUMN sa.x_port_out_request_log.ota_feat_ild_prog_status IS 'table_x_ota_features column ild_prog_status';
COMMENT ON COLUMN sa.x_port_out_request_log.click_plan_hist_objid IS 'table_x_click_plan_hist column objid';
COMMENT ON COLUMN sa.x_port_out_request_log.click_plan_hist_end_date IS 'table_x_click_plan_hist column x_end_date';
COMMENT ON COLUMN sa.x_port_out_request_log.fvm_status IS 'x_free_voice_mail column x_fvm_status';
COMMENT ON COLUMN sa.x_port_out_request_log.fvm_number IS 'x_free_voice_mail column x_fvm_number';
COMMENT ON COLUMN sa.x_port_out_request_log.ota_transaction_objid IS 'table_x_ota_transaction column objid';
COMMENT ON COLUMN sa.x_port_out_request_log.ota_transaction_status IS 'table_x_ota_transaction column x_status';
COMMENT ON COLUMN sa.x_port_out_request_log.ota_transaction_reason IS 'table_x_ota_transaction column x_reason';
COMMENT ON COLUMN sa.x_port_out_request_log.request_xml IS 'Request in XML';