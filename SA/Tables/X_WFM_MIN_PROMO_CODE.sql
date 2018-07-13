CREATE TABLE sa.x_wfm_min_promo_code (
  promo_code VARCHAR2(15 BYTE) NOT NULL,
  promo_status VARCHAR2(15 BYTE) NOT NULL,
  promo_applied_date DATE,
  promo_min VARCHAR2(10 BYTE),
  promo_pin VARCHAR2(15 BYTE),
  old_account_id NUMBER(25),
  old_min VARCHAR2(10 BYTE),
  old_status_code VARCHAR2(15 BYTE),
  old_rate_plan_code VARCHAR2(15 BYTE),
  report_date DATE,
  prev_effect_start_date DATE,
  prev_effect_end_date DATE,
  first_qlfyng_use_date DATE,
  last_qlfyng_use_date DATE,
  deactivation_date DATE,
  deactivation_reason VARCHAR2(240 BYTE),
  first_name VARCHAR2(60 BYTE),
  last_name VARCHAR2(60 BYTE),
  address1 VARCHAR2(240 BYTE),
  address2 VARCHAR2(240 BYTE),
  city VARCHAR2(40 BYTE),
  "STATE" VARCHAR2(2 BYTE),
  zip_code VARCHAR2(15 BYTE),
  country_code VARCHAR2(2 BYTE),
  created_by NUMBER(25),
  created_date TIMESTAMP,
  updated_by NUMBER(25),
  updated_date TIMESTAMP,
  CONSTRAINT x_wfm_min_promo_code_pk PRIMARY KEY (promo_code) USING INDEX sa.pk1_wfm_min_promo_code
);
COMMENT ON TABLE sa.x_wfm_min_promo_code IS 'WFM win back promo code list';
COMMENT ON COLUMN sa.x_wfm_min_promo_code.promo_code IS 'WFM promo code NEW, USED and DISABLED';
COMMENT ON COLUMN sa.x_wfm_min_promo_code.promo_status IS 'WFM promo code status';
COMMENT ON COLUMN sa.x_wfm_min_promo_code.promo_applied_date IS 'Date the WFM promo code was applied to MIN';
COMMENT ON COLUMN sa.x_wfm_min_promo_code.promo_min IS 'MIN (phone number) the WFM promo code applied to';
COMMENT ON COLUMN sa.x_wfm_min_promo_code.promo_pin IS 'Redeemed card PIN number when WFM promo code was applied';
COMMENT ON COLUMN sa.x_wfm_min_promo_code.old_account_id IS 'Old TMobile BAN Account';
COMMENT ON COLUMN sa.x_wfm_min_promo_code.old_min IS 'Old TMobile MIN (phone number)';
COMMENT ON COLUMN sa.x_wfm_min_promo_code.old_status_code IS 'Previous account status (should all be C= cancelled for TMobile)';
COMMENT ON COLUMN sa.x_wfm_min_promo_code.old_rate_plan_code IS 'Previous service plan when active under TMobile';
COMMENT ON COLUMN sa.x_wfm_min_promo_code.report_date IS 'Date the list reported the old TMobile customer status';
COMMENT ON COLUMN sa.x_wfm_min_promo_code.prev_effect_start_date IS 'Previous activation date';
COMMENT ON COLUMN sa.x_wfm_min_promo_code.prev_effect_end_date IS 'Previous deactivation date';
COMMENT ON COLUMN sa.x_wfm_min_promo_code.first_qlfyng_use_date IS 'Date old phone was used for the first time';
COMMENT ON COLUMN sa.x_wfm_min_promo_code.last_qlfyng_use_date IS 'Date old phone was used for the last time';
COMMENT ON COLUMN sa.x_wfm_min_promo_code.deactivation_date IS 'Old phone deactivation date';
COMMENT ON COLUMN sa.x_wfm_min_promo_code.deactivation_reason IS 'Old phone deactivation reason';
COMMENT ON COLUMN sa.x_wfm_min_promo_code.first_name IS 'Customer first name';
COMMENT ON COLUMN sa.x_wfm_min_promo_code.last_name IS 'Customer last name';
COMMENT ON COLUMN sa.x_wfm_min_promo_code.address1 IS 'Customer address line 1';
COMMENT ON COLUMN sa.x_wfm_min_promo_code.address2 IS 'Customer address line 2';
COMMENT ON COLUMN sa.x_wfm_min_promo_code.city IS 'Customer city';
COMMENT ON COLUMN sa.x_wfm_min_promo_code."STATE" IS 'Customer state';
COMMENT ON COLUMN sa.x_wfm_min_promo_code.zip_code IS 'Customer zip code';
COMMENT ON COLUMN sa.x_wfm_min_promo_code.country_code IS 'Customer country code';
COMMENT ON COLUMN sa.x_wfm_min_promo_code.created_by IS 'User ID who created record';
COMMENT ON COLUMN sa.x_wfm_min_promo_code.created_date IS 'Date and time when record was created';
COMMENT ON COLUMN sa.x_wfm_min_promo_code.updated_by IS 'User ID who updated record';
COMMENT ON COLUMN sa.x_wfm_min_promo_code.updated_date IS 'Date and time when record was updated';