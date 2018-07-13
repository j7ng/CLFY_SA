CREATE TABLE sa.x_program_enrolled (
  objid NUMBER NOT NULL,
  x_esn VARCHAR2(30 BYTE),
  x_amount NUMBER(10,2),
  x_type VARCHAR2(30 BYTE),
  x_zipcode NUMBER,
  x_sourcesystem VARCHAR2(30 BYTE),
  x_insert_date DATE,
  x_charge_date DATE,
  x_pec_customer NUMBER,
  x_charge_type VARCHAR2(30 BYTE),
  x_enrolled_date DATE,
  x_start_date DATE,
  x_reason VARCHAR2(255 BYTE),
  x_exp_date DATE,
  x_delivery_cycle_number NUMBER,
  x_enroll_amount NUMBER(10,2),
  x_language VARCHAR2(7 BYTE),
  x_payment_type VARCHAR2(20 BYTE),
  x_grace_period NUMBER(3),
  x_cooling_period NUMBER(3),
  x_service_days NUMBER(3),
  x_cooling_exp_date DATE,
  x_enrollment_status VARCHAR2(30 BYTE),
  x_is_grp_primary NUMBER(1),
  x_tot_grace_period_given NUMBER,
  x_next_charge_date DATE,
  x_next_delivery_date DATE,
  x_update_stamp DATE,
  x_update_user VARCHAR2(40 BYTE),
  pgm_enroll2pgm_parameter NUMBER,
  pgm_enroll2pgm_group NUMBER,
  pgm_enroll2site_part NUMBER,
  pgm_enroll2part_inst NUMBER,
  pgm_enroll2contact NUMBER,
  pgm_enroll2web_user NUMBER,
  pgm_enroll2x_pymt_src NUMBER,
  x_wait_exp_date DATE,
  pgm_enroll2x_promotion NUMBER,
  pgm_enroll2prog_hdr NUMBER,
  x_termscond_accepted NUMBER DEFAULT 1,
  x_service_delivery_date DATE,
  default_denomination NUMBER,
  auto_refill_max_limit NUMBER(22),
  auto_refill_counter NUMBER(22)
);
ALTER TABLE sa.x_program_enrolled ADD SUPPLEMENTAL LOG GROUP dmtsora284121992_0 (objid, pgm_enroll2part_inst, pgm_enroll2pgm_group, pgm_enroll2pgm_parameter, pgm_enroll2site_part, x_amount, x_charge_date, x_charge_type, x_cooling_exp_date, x_cooling_period, x_delivery_cycle_number, x_enrolled_date, x_enrollment_status, x_enroll_amount, x_esn, x_exp_date, x_grace_period, x_insert_date, x_is_grp_primary, x_language, x_next_charge_date, x_next_delivery_date, x_payment_type, x_pec_customer, x_reason, x_service_days, x_sourcesystem, x_start_date, x_tot_grace_period_given, x_type, x_update_stamp, x_update_user, x_zipcode) ALWAYS;
ALTER TABLE sa.x_program_enrolled ADD SUPPLEMENTAL LOG GROUP dmtsora284121992_1 (default_denomination, pgm_enroll2contact, pgm_enroll2prog_hdr, pgm_enroll2web_user, pgm_enroll2x_promotion, pgm_enroll2x_pymt_src, x_service_delivery_date, x_termscond_accepted, x_wait_exp_date) ALWAYS;
COMMENT ON TABLE sa.x_program_enrolled IS 'Membership table for bulling programs.  it links Service, Programs, Account.';
COMMENT ON COLUMN sa.x_program_enrolled.objid IS 'Internal Record ID';
COMMENT ON COLUMN sa.x_program_enrolled.x_esn IS 'Phone Serial Number, References part_serial_no in table_part_inst';
COMMENT ON COLUMN sa.x_program_enrolled.x_amount IS 'Membership Dollar Amount';
COMMENT ON COLUMN sa.x_program_enrolled.x_type IS 'Type of Billing Program';
COMMENT ON COLUMN sa.x_program_enrolled.x_zipcode IS 'Zip Code of the Service';
COMMENT ON COLUMN sa.x_program_enrolled.x_sourcesystem IS 'System that created the record';
COMMENT ON COLUMN sa.x_program_enrolled.x_insert_date IS 'Creation Date';
COMMENT ON COLUMN sa.x_program_enrolled.x_charge_date IS 'Date for lastest payment';
COMMENT ON COLUMN sa.x_program_enrolled.x_pec_customer IS 'Default 0, Not in use';
COMMENT ON COLUMN sa.x_program_enrolled.x_charge_type IS 'Obsolete';
COMMENT ON COLUMN sa.x_program_enrolled.x_enrolled_date IS 'Date os enrollment in plan';
COMMENT ON COLUMN sa.x_program_enrolled.x_start_date IS 'Date enrollment starts';
COMMENT ON COLUMN sa.x_program_enrolled.x_reason IS 'Short explanation for latest status';
COMMENT ON COLUMN sa.x_program_enrolled.x_exp_date IS 'Date the membership expires';
COMMENT ON COLUMN sa.x_program_enrolled.x_delivery_cycle_number IS 'Number of Cycles the enrollment has been active.';
COMMENT ON COLUMN sa.x_program_enrolled.x_enroll_amount IS 'Dollar amount charged for Enrollment.';
COMMENT ON COLUMN sa.x_program_enrolled.x_language IS 'Language used during enrollment';
COMMENT ON COLUMN sa.x_program_enrolled.x_payment_type IS 'Obsolete';
COMMENT ON COLUMN sa.x_program_enrolled.x_grace_period IS 'Deenrollment delay in days';
COMMENT ON COLUMN sa.x_program_enrolled.x_cooling_period IS 'Re-enrollment delay in days';
COMMENT ON COLUMN sa.x_program_enrolled.x_service_days IS 'Number of Service Days provided by program';
COMMENT ON COLUMN sa.x_program_enrolled.x_cooling_exp_date IS 'Expiration day for re-enrollment';
COMMENT ON COLUMN sa.x_program_enrolled.x_enrollment_status IS 'Status of the enrollment';
COMMENT ON COLUMN sa.x_program_enrolled.x_is_grp_primary IS 'The record belongs to the primary esn of the account: 0=No, 1=Yes';
COMMENT ON COLUMN sa.x_program_enrolled.x_tot_grace_period_given IS 'Total Number of Days given after due date.';
COMMENT ON COLUMN sa.x_program_enrolled.x_next_charge_date IS 'Date of the next CC charge.';
COMMENT ON COLUMN sa.x_program_enrolled.x_next_delivery_date IS 'Date of the benefits delivery';
COMMENT ON COLUMN sa.x_program_enrolled.x_update_stamp IS 'Latest update timestamp.';
COMMENT ON COLUMN sa.x_program_enrolled.x_update_user IS 'Latest userid that made an update to the record.';
COMMENT ON COLUMN sa.x_program_enrolled.pgm_enroll2pgm_parameter IS 'Reference to x_program_parameters';
COMMENT ON COLUMN sa.x_program_enrolled.pgm_enroll2pgm_group IS 'Reference to x_program_group (optional)';
COMMENT ON COLUMN sa.x_program_enrolled.pgm_enroll2site_part IS 'Reference to table_site_part (service)';
COMMENT ON COLUMN sa.x_program_enrolled.pgm_enroll2part_inst IS 'Reference to table_part_inst (ESN Record)';
COMMENT ON COLUMN sa.x_program_enrolled.pgm_enroll2contact IS 'Reference to table_contact associated to service';
COMMENT ON COLUMN sa.x_program_enrolled.pgm_enroll2web_user IS 'Reference to table_web_user, owner of the account';
COMMENT ON COLUMN sa.x_program_enrolled.pgm_enroll2x_pymt_src IS 'Reference to x_payment_source, form of payment definition';
COMMENT ON COLUMN sa.x_program_enrolled.x_wait_exp_date IS 'Extended Expiration Date';
COMMENT ON COLUMN sa.x_program_enrolled.pgm_enroll2x_promotion IS 'Reference to table_x_promotion';
COMMENT ON COLUMN sa.x_program_enrolled.pgm_enroll2prog_hdr IS 'Reference to x_program_purch_hdr';
COMMENT ON COLUMN sa.x_program_enrolled.x_termscond_accepted IS 'Flag to accept the terms anc conditions of the programs.';
COMMENT ON COLUMN sa.x_program_enrolled.x_service_delivery_date IS 'Same as x_next_delivery_date';
COMMENT ON COLUMN sa.x_program_enrolled.default_denomination IS 'Reference to table_part_num, objid ';
COMMENT ON COLUMN sa.x_program_enrolled.auto_refill_max_limit IS 'Number of times data can be auto refilled within a billing cycle';
COMMENT ON COLUMN sa.x_program_enrolled.auto_refill_counter IS 'Number of times data has been auto refilled in current billing cycle';