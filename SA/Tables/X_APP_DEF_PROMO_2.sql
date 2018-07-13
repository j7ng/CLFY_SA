CREATE TABLE sa.x_app_def_promo_2 (
  x_app_name VARCHAR2(200 BYTE),
  x_brand_name VARCHAR2(30 BYTE),
  x_source_system VARCHAR2(20 BYTE),
  x_def_promo VARCHAR2(20 BYTE),
  x_def_promo2 VARCHAR2(20 BYTE)
);
COMMENT ON TABLE sa.x_app_def_promo_2 IS 'Default Promotion Table,  this table defines the defaul activation promo to use depending of the brand, system and application being used.';
COMMENT ON COLUMN sa.x_app_def_promo_2.x_app_name IS 'Application Name';
COMMENT ON COLUMN sa.x_app_def_promo_2.x_brand_name IS 'Brand Name';
COMMENT ON COLUMN sa.x_app_def_promo_2.x_source_system IS 'Source System';
COMMENT ON COLUMN sa.x_app_def_promo_2.x_def_promo IS 'Promo Code 1';
COMMENT ON COLUMN sa.x_app_def_promo_2.x_def_promo2 IS 'Promo Code 2';