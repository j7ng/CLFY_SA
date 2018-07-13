CREATE TABLE sa.x_program_trans (
  objid NUMBER NOT NULL,
  x_enrollment_status VARCHAR2(30 BYTE),
  x_enroll_status_reason VARCHAR2(255 BYTE),
  x_float_given NUMBER(3),
  x_cooling_given NUMBER(3),
  x_grace_period_given NUMBER(3),
  x_trans_date DATE,
  x_action_text VARCHAR2(30 BYTE),
  x_action_type VARCHAR2(30 BYTE),
  x_reason VARCHAR2(255 BYTE),
  x_sourcesystem VARCHAR2(20 BYTE),
  x_esn VARCHAR2(30 BYTE),
  x_exp_date DATE,
  x_cooling_exp_date DATE,
  x_update_status VARCHAR2(1 BYTE),
  x_update_user VARCHAR2(255 BYTE),
  pgm_tran2pgm_entrolled NUMBER,
  pgm_trans2web_user NUMBER,
  pgm_trans2site_part NUMBER
);
ALTER TABLE sa.x_program_trans ADD SUPPLEMENTAL LOG GROUP dmtsora1305451775_0 (objid, pgm_tran2pgm_entrolled, pgm_trans2site_part, pgm_trans2web_user, x_action_text, x_action_type, x_cooling_exp_date, x_cooling_given, x_enrollment_status, x_enroll_status_reason, x_esn, x_exp_date, x_float_given, x_grace_period_given, x_reason, x_sourcesystem, x_trans_date, x_update_status, x_update_user) ALWAYS;
COMMENT ON TABLE sa.x_program_trans IS 'Billing Transaction Table, All transactions that affect the enrollment status of a phone are stored here.';
COMMENT ON COLUMN sa.x_program_trans.objid IS 'Internal Record ID';
COMMENT ON COLUMN sa.x_program_trans.x_enrollment_status IS 'Enrollment Status';
COMMENT ON COLUMN sa.x_program_trans.x_enroll_status_reason IS 'Reason for the Enrollment Status';
COMMENT ON COLUMN sa.x_program_trans.x_float_given IS 'Float Days Given in the transaction';
COMMENT ON COLUMN sa.x_program_trans.x_cooling_given IS 'Cooling Days given in the transaction';
COMMENT ON COLUMN sa.x_program_trans.x_grace_period_given IS 'Grace Period Days Given';
COMMENT ON COLUMN sa.x_program_trans.x_trans_date IS 'Transaction Timestamp';
COMMENT ON COLUMN sa.x_program_trans.x_action_text IS 'Action Text, Short Description';
COMMENT ON COLUMN sa.x_program_trans.x_action_type IS 'Action Type: BENEFITS
CHANGE_PAYMENT_DATE
COOLING_PERIOD
DEACT
DEACTPROTECT
DEENROLLED
DE_ENROLL
ENROLLMENT
ENROLLMENTBLOCKED
GRACE_PERIOD_EXTENSION
PLAN_CHANGE
PRIMARY_UPDATE
Payment
READY_TO_REENROLL
RECURRING_PAYMENT
RE_ENROLL
ST_PLAN_TRANSFER
SUSPENDED
TRANSFER';
COMMENT ON COLUMN sa.x_program_trans.x_reason IS 'Reason, long description';
COMMENT ON COLUMN sa.x_program_trans.x_sourcesystem IS 'Application that originates transaction';
COMMENT ON COLUMN sa.x_program_trans.x_esn IS 'Phone Serial Number';
COMMENT ON COLUMN sa.x_program_trans.x_exp_date IS 'Expiration Date for Service';
COMMENT ON COLUMN sa.x_program_trans.x_cooling_exp_date IS 'Cooling Expiration Date';
COMMENT ON COLUMN sa.x_program_trans.x_update_status IS 'Update Status: I,D';
COMMENT ON COLUMN sa.x_program_trans.x_update_user IS 'Login name user';
COMMENT ON COLUMN sa.x_program_trans.pgm_tran2pgm_entrolled IS 'Reference to Program Enrolled';
COMMENT ON COLUMN sa.x_program_trans.pgm_trans2web_user IS 'Reference to table_web_user';
COMMENT ON COLUMN sa.x_program_trans.pgm_trans2site_part IS 'Reference to table_site_part';