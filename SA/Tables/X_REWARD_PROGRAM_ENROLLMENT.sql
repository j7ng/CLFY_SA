CREATE TABLE sa.x_reward_program_enrollment (
  objid NUMBER NOT NULL,
  brand VARCHAR2(100 BYTE),
  web_account_id VARCHAR2(100 BYTE),
  subscriber_id VARCHAR2(100 BYTE),
  "MIN" VARCHAR2(100 BYTE),
  esn VARCHAR2(100 BYTE),
  benefit_type_code VARCHAR2(100 BYTE),
  enrollment_flag VARCHAR2(1 BYTE),
  enroll_date DATE,
  deenroll_date DATE,
  program_name VARCHAR2(100 BYTE),
  enrollment_type VARCHAR2(100 BYTE),
  promotion_group VARCHAR2(100 BYTE),
  enroll_min VARCHAR2(255 BYTE),
  enroll_channel VARCHAR2(255 BYTE),
  CONSTRAINT prog_enrol_objid_pk PRIMARY KEY (objid)
);
COMMENT ON TABLE sa.x_reward_program_enrollment IS 'This new table stores customer enrollment information in Rewards Programs (only).';
COMMENT ON COLUMN sa.x_reward_program_enrollment.objid IS 'Unique record identifier';
COMMENT ON COLUMN sa.x_reward_program_enrollment.brand IS 'NET10 / SIMPLEMOBILE / STRAIGHTTALK / TRACFONE / TELCEL / TOTALWIRELESS';
COMMENT ON COLUMN sa.x_reward_program_enrollment.web_account_id IS 'ACCOUNT ID of the customer';
COMMENT ON COLUMN sa.x_reward_program_enrollment.subscriber_id IS 'SUBSCRIBER ID of the customer';
COMMENT ON COLUMN sa.x_reward_program_enrollment."MIN" IS 'MIN of the customer';
COMMENT ON COLUMN sa.x_reward_program_enrollment.esn IS 'ESN of the customer';
COMMENT ON COLUMN sa.x_reward_program_enrollment.benefit_type_code IS 'Type of Benefit : REWARD_BENEFITS / UPGRADE_POINTS / LOYALTY_POINTS';
COMMENT ON COLUMN sa.x_reward_program_enrollment.enrollment_flag IS 'ENROLLMENT_FLAG : Y, N, P(promo) - Y Means Enrolled , N means De-enrolled and P means in Promotion Group';
COMMENT ON COLUMN sa.x_reward_program_enrollment.enroll_date IS 'Date of last ENROLLMENT ';
COMMENT ON COLUMN sa.x_reward_program_enrollment.deenroll_date IS 'Date of DEENROLLMENT(null if enrolled) ';
COMMENT ON COLUMN sa.x_reward_program_enrollment.program_name IS 'Type of Program : UPGRADES_PROGRAM / LOYALTY_PROGRAM';
COMMENT ON COLUMN sa.x_reward_program_enrollment.enrollment_type IS ' Type of Enrollment : PROGRAM_ENROLLMENT, AUTO_REFILL ';
COMMENT ON COLUMN sa.x_reward_program_enrollment.promotion_group IS ' Name of the promotion group for ex., ST_LOYALTY_500K_PROMO';
COMMENT ON COLUMN sa.x_reward_program_enrollment.enroll_min IS 'Min from which the account is enrolled in LRP';
COMMENT ON COLUMN sa.x_reward_program_enrollment.enroll_channel IS 'Web/Tas';