CREATE TABLE sa.x_sl_subs (
  objid NUMBER,
  lid NUMBER,
  full_name VARCHAR2(200 BYTE),
  address_1 VARCHAR2(200 BYTE),
  address_2 VARCHAR2(200 BYTE),
  city VARCHAR2(30 BYTE),
  "STATE" VARCHAR2(40 BYTE),
  zip VARCHAR2(20 BYTE),
  zip2 VARCHAR2(20 BYTE),
  country VARCHAR2(40 BYTE),
  e_mail VARCHAR2(80 BYTE),
  x_homenumber VARCHAR2(20 BYTE),
  x_allow_prerecorded CHAR,
  x_email_pref VARCHAR2(10 BYTE),
  sl_subs2table_contact NUMBER,
  sl_subs2web_user NUMBER,
  x_requested_plan VARCHAR2(40 BYTE),
  x_referrer VARCHAR2(40 BYTE),
  x_external_account VARCHAR2(200 BYTE),
  x_campaign VARCHAR2(100 BYTE),
  x_promotion VARCHAR2(50 BYTE),
  x_promocode VARCHAR2(50 BYTE),
  x_shp_address VARCHAR2(50 BYTE),
  x_shp_address2 VARCHAR2(50 BYTE),
  x_shp_city VARCHAR2(50 BYTE),
  x_shp_state VARCHAR2(50 BYTE),
  x_shp_zip VARCHAR2(30 BYTE),
  x_qualify_date DATE,
  x_last_av_date VARCHAR2(50 BYTE),
  x_av_due_date DATE,
  x_av_verified_channel VARCHAR2(10 BYTE),
  x_nlad_status VARCHAR2(10 BYTE),
  x_nlad_active_date DATE,
  x_nlad_deactive_date DATE,
  x_nlad_deactive_reason VARCHAR2(100 BYTE),
  x_device_type VARCHAR2(100 BYTE),
  x_data_source VARCHAR2(50 BYTE)
);
COMMENT ON COLUMN sa.x_sl_subs.objid IS 'Internal Record ID';
COMMENT ON COLUMN sa.x_sl_subs.lid IS '3rd Party Customer ID';
COMMENT ON COLUMN sa.x_sl_subs.full_name IS 'Customer Full Name';
COMMENT ON COLUMN sa.x_sl_subs.address_1 IS 'Address 1';
COMMENT ON COLUMN sa.x_sl_subs.address_2 IS 'Address 2';
COMMENT ON COLUMN sa.x_sl_subs.city IS 'City';
COMMENT ON COLUMN sa.x_sl_subs."STATE" IS 'State';
COMMENT ON COLUMN sa.x_sl_subs.zip IS 'Zip Code';
COMMENT ON COLUMN sa.x_sl_subs.zip2 IS 'Zip Code 2';
COMMENT ON COLUMN sa.x_sl_subs.country IS 'Country';
COMMENT ON COLUMN sa.x_sl_subs.e_mail IS 'email address';
COMMENT ON COLUMN sa.x_sl_subs.x_homenumber IS 'Home Phone Number';
COMMENT ON COLUMN sa.x_sl_subs.x_allow_prerecorded IS 'Allow Prerecorded Messages Flag: Y,N,Z';
COMMENT ON COLUMN sa.x_sl_subs.x_email_pref IS 'not used';
COMMENT ON COLUMN sa.x_sl_subs.sl_subs2table_contact IS 'Reference to table_contact';
COMMENT ON COLUMN sa.x_sl_subs.sl_subs2web_user IS 'Reference to table_web_user';
COMMENT ON COLUMN sa.x_sl_subs.x_referrer IS 'LID of friend that was referred';
COMMENT ON COLUMN sa.x_sl_subs.x_external_account IS 'SHORT NAME FOR HEALTH MAINTENANCE ORGANIZATION  (HMO)  CONCATENATED WITH HMO ACCOUNT NUMBER';
COMMENT ON COLUMN sa.x_sl_subs.x_qualify_date IS 'Indicates the Qualify Date ';
COMMENT ON COLUMN sa.x_sl_subs.x_last_av_date IS 'Indicates the last annual verify date ';
COMMENT ON COLUMN sa.x_sl_subs.x_av_due_date IS 'Indicates the annual verify due date ';
COMMENT ON COLUMN sa.x_sl_subs.x_av_verified_channel IS 'Indicates the channel for annual varify ';
COMMENT ON COLUMN sa.x_sl_subs.x_nlad_status IS 'Indicates the status of NLAD ';
COMMENT ON COLUMN sa.x_sl_subs.x_nlad_active_date IS 'Indicates the NLAD active date ';
COMMENT ON COLUMN sa.x_sl_subs.x_nlad_deactive_date IS 'Indicates the NLAD deactivation date ';
COMMENT ON COLUMN sa.x_sl_subs.x_nlad_deactive_reason IS 'Indicates the reason for deactivation of NLAD ';
COMMENT ON COLUMN sa.x_sl_subs.x_device_type IS 'Indicates device like HOME_PHONE, CELL, BYOP ... ';
COMMENT ON COLUMN sa.x_sl_subs.x_data_source IS 'Indicates data source as VMBC, SOLIX';