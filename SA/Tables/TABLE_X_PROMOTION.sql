CREATE TABLE sa.table_x_promotion (
  objid NUMBER,
  x_promo_code VARCHAR2(10 BYTE),
  x_promo_type VARCHAR2(30 BYTE),
  x_dollar_retail_cost NUMBER(6,2),
  x_start_date DATE,
  x_end_date DATE,
  x_units NUMBER,
  x_access_days NUMBER,
  x_promotion_text LONG,
  x_is_default NUMBER,
  x_sql_statement VARCHAR2(2000 BYTE),
  x_revenue_type VARCHAR2(20 BYTE),
  x_default_type VARCHAR2(15 BYTE),
  x_redeemable NUMBER,
  x_promo_technology VARCHAR2(20 BYTE),
  x_spanish_promo_text VARCHAR2(2000 BYTE),
  x_usage NUMBER,
  x_discount_amount NUMBER(10,2),
  x_discount_percent NUMBER(4,2),
  x_source_system VARCHAR2(7 BYTE),
  x_transaction_type VARCHAR2(20 BYTE),
  x_zip_required NUMBER,
  x_promo_desc VARCHAR2(200 BYTE),
  x_amigo_allowed NUMBER,
  x_program_type NUMBER,
  x_ship_start_date DATE,
  x_ship_end_date DATE,
  x_refurbished_allowed NUMBER,
  x_spanish_short_text VARCHAR2(35 BYTE),
  x_english_short_text VARCHAR2(35 BYTE),
  x_allow_stacking NUMBER,
  x_units_filter VARCHAR2(1000 BYTE),
  x_access_days_filter VARCHAR2(1000 BYTE),
  x_promo_code_filter VARCHAR2(1000 BYTE),
  x_group_name_filter VARCHAR2(1000 BYTE),
  promotion2bus_org NUMBER,
  x_sms NUMBER(22),
  x_data_mb NUMBER(22),
  x_device_type VARCHAR2(60 BYTE),
  brm_equivalent_discount_code VARCHAR2(100 BYTE)
);
ALTER TABLE sa.table_x_promotion ADD SUPPLEMENTAL LOG GROUP dmtsora179414208_0 (objid, x_access_days, x_access_days_filter, x_allow_stacking, x_amigo_allowed, x_default_type, x_discount_amount, x_discount_percent, x_dollar_retail_cost, x_end_date, x_english_short_text, x_is_default, x_program_type, x_promo_code, x_promo_code_filter, x_promo_desc, x_promo_technology, x_promo_type, x_redeemable, x_refurbished_allowed, x_revenue_type, x_ship_end_date, x_ship_start_date, x_source_system, x_spanish_promo_text, x_spanish_short_text, x_sql_statement, x_start_date, x_transaction_type, x_units, x_units_filter, x_usage, x_zip_required) ALWAYS;
ALTER TABLE sa.table_x_promotion ADD SUPPLEMENTAL LOG GROUP dmtsora179414208_1 (x_group_name_filter) ALWAYS;
COMMENT ON TABLE sa.table_x_promotion IS 'Contains Promotion information';
COMMENT ON COLUMN sa.table_x_promotion.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_x_promotion.x_promo_code IS 'Promotion Code';
COMMENT ON COLUMN sa.table_x_promotion.x_promo_type IS 'Type of Promotion';
COMMENT ON COLUMN sa.table_x_promotion.x_dollar_retail_cost IS 'Retail Cost of the Card';
COMMENT ON COLUMN sa.table_x_promotion.x_start_date IS 'Start Date of promotion';
COMMENT ON COLUMN sa.table_x_promotion.x_end_date IS 'End Date of Promotion';
COMMENT ON COLUMN sa.table_x_promotion.x_units IS 'Units on the card associated with the promotion';
COMMENT ON COLUMN sa.table_x_promotion.x_access_days IS 'Access Days for which the card is vaild';
COMMENT ON COLUMN sa.table_x_promotion.x_promotion_text IS 'Text used for promotion';
COMMENT ON COLUMN sa.table_x_promotion.x_is_default IS 'Flag that designates default promotion for a given promo type, 0=no, 1=yes';
COMMENT ON COLUMN sa.table_x_promotion.x_sql_statement IS 'use this field to hold runtime criteria';
COMMENT ON COLUMN sa.table_x_promotion.x_revenue_type IS 'Revenue Promotion types';
COMMENT ON COLUMN sa.table_x_promotion.x_default_type IS 'ALR - 07/26/01 -- Added to contain the default type (ANALOG/DIGITAL) for the promotion';
COMMENT ON COLUMN sa.table_x_promotion.x_redeemable IS 'Display sequence for the WEB';
COMMENT ON COLUMN sa.table_x_promotion.x_promo_technology IS 'Technology of the promotion if any';
COMMENT ON COLUMN sa.table_x_promotion.x_spanish_promo_text IS 'spanish version of promotion description';
COMMENT ON COLUMN sa.table_x_promotion.x_usage IS 'Number of times a Promo code can be used by a given ESN';
COMMENT ON COLUMN sa.table_x_promotion.x_discount_amount IS 'Store amount of discount offered';
COMMENT ON COLUMN sa.table_x_promotion.x_discount_percent IS 'purchase discount percentage';
COMMENT ON COLUMN sa.table_x_promotion.x_source_system IS 'Source System that qualifies for the promotion';
COMMENT ON COLUMN sa.table_x_promotion.x_transaction_type IS 'transaction type: Activation, Reactivation, Redeemption, Purchase';
COMMENT ON COLUMN sa.table_x_promotion.x_zip_required IS 'Zip Code selection Required';
COMMENT ON COLUMN sa.table_x_promotion.x_promo_desc IS 'promo description';
COMMENT ON COLUMN sa.table_x_promotion.x_amigo_allowed IS 'Flag to determine if promotion is valid for Amigo phones';
COMMENT ON COLUMN sa.table_x_promotion.x_program_type IS 'Autopay Program Type 02 Autopay 03 Hybrid 04 Deactivate';
COMMENT ON COLUMN sa.table_x_promotion.x_ship_start_date IS 'ESN Shipping Start Date for promotion';
COMMENT ON COLUMN sa.table_x_promotion.x_ship_end_date IS 'ESN Shipping End Date for Promotion';
COMMENT ON COLUMN sa.table_x_promotion.x_refurbished_allowed IS 'Flag to determine if promotion is valid for Refurbished phones';
COMMENT ON COLUMN sa.table_x_promotion.x_spanish_short_text IS 'Spanish short promo description, mainly used for WEB and IVR';
COMMENT ON COLUMN sa.table_x_promotion.x_english_short_text IS 'English short promo description, mainly used for WEB and IVR';
COMMENT ON COLUMN sa.table_x_promotion.x_allow_stacking IS 'Flag to determine if promotion grants 455 stacking';
COMMENT ON COLUMN sa.table_x_promotion.x_units_filter IS 'TBD';
COMMENT ON COLUMN sa.table_x_promotion.x_access_days_filter IS 'TBD';
COMMENT ON COLUMN sa.table_x_promotion.x_promo_code_filter IS 'TBD';
COMMENT ON COLUMN sa.table_x_promotion.x_group_name_filter IS 'TBD';
COMMENT ON COLUMN sa.table_x_promotion.x_sms IS 'Bonus Sms';
COMMENT ON COLUMN sa.table_x_promotion.x_data_mb IS 'Bonus Data in mb';
COMMENT ON COLUMN sa.table_x_promotion.x_device_type IS 'Device type';
COMMENT ON COLUMN sa.table_x_promotion.brm_equivalent_discount_code IS 'BRM equivalent discount links to x_rp_ancillary_code_discount.brm_equivalent';