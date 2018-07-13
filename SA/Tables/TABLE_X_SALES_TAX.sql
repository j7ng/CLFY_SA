CREATE TABLE sa.table_x_sales_tax (
  objid NUMBER,
  x_zipcode VARCHAR2(10 BYTE),
  x_city VARCHAR2(28 BYTE),
  x_county VARCHAR2(25 BYTE),
  x_state VARCHAR2(2 BYTE),
  x_cntydef VARCHAR2(1 BYTE),
  x_default VARCHAR2(1 BYTE),
  x_cntyfips VARCHAR2(5 BYTE),
  x_statestax NUMBER,
  x_cntstax NUMBER,
  x_cntlclstax NUMBER,
  x_ctystax NUMBER,
  x_ctylclstax NUMBER,
  x_combstax NUMBER,
  x_eff_dt DATE,
  x_geocode VARCHAR2(10 BYTE),
  x_inout VARCHAR2(2 BYTE),
  x_e911foot VARCHAR2(255 BYTE),
  x_e911note VARCHAR2(255 BYTE),
  x_e911rate NUMBER(19,4),
  x_e911surcharge NUMBER(19,4),
  x_usf_taxrate NUMBER(19,4),
  x_rcrfrate NUMBER(19,4),
  x_non_sales NUMBER DEFAULT 0 NOT NULL,
  x_wty_tax NUMBER,
  x_cwg_tax NUMBER,
  x_dataonly_tax NUMBER(22),
  x_car_connect_non_sales NUMBER(22),
  x_data_non_sales NUMBER(22),
  x_home_alert_non_sales NUMBER(22),
  x_non_shipping NUMBER(22),
  x_ancillary_non_sales NUMBER(22),
  x_digital_non_sales NUMBER(22),
  x_2waytext_sales NUMBER DEFAULT 0,
  x_2waytext_911 NUMBER DEFAULT 0,
  x_non_activation_charge_flag NUMBER,
  tpp_combtax NUMBER
);
ALTER TABLE sa.table_x_sales_tax ADD SUPPLEMENTAL LOG GROUP dmtsora990655411_0 (objid, x_city, x_cntlclstax, x_cntstax, x_cntydef, x_cntyfips, x_combstax, x_county, x_ctylclstax, x_ctystax, x_default, x_e911foot, x_e911note, x_e911rate, x_e911surcharge, x_eff_dt, x_geocode, x_inout, x_state, x_statestax, x_usf_taxrate, x_zipcode) ALWAYS;
COMMENT ON TABLE sa.table_x_sales_tax IS 'CCH  sales tax rates table for Cybersource Interface purchases';
COMMENT ON COLUMN sa.table_x_sales_tax.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_x_sales_tax.x_zipcode IS 'zip code';
COMMENT ON COLUMN sa.table_x_sales_tax.x_city IS 'City Name';
COMMENT ON COLUMN sa.table_x_sales_tax.x_county IS 'zip code';
COMMENT ON COLUMN sa.table_x_sales_tax.x_state IS 'state abbreviation';
COMMENT ON COLUMN sa.table_x_sales_tax.x_cntydef IS 'county default';
COMMENT ON COLUMN sa.table_x_sales_tax.x_default IS 'general default';
COMMENT ON COLUMN sa.table_x_sales_tax.x_cntyfips IS 'county FIPS code';
COMMENT ON COLUMN sa.table_x_sales_tax.x_statestax IS 'state sales tax rate';
COMMENT ON COLUMN sa.table_x_sales_tax.x_cntstax IS 'county sales tax rate';
COMMENT ON COLUMN sa.table_x_sales_tax.x_cntlclstax IS 'county local sales tax';
COMMENT ON COLUMN sa.table_x_sales_tax.x_ctystax IS 'city sales tax rate';
COMMENT ON COLUMN sa.table_x_sales_tax.x_ctylclstax IS 'city local sales tax rate';
COMMENT ON COLUMN sa.table_x_sales_tax.x_combstax IS 'combined sales tax - THIS IS THE ONLY ONE TOSS USES TO CALCULATE';
COMMENT ON COLUMN sa.table_x_sales_tax.x_eff_dt IS 'TBD';
COMMENT ON COLUMN sa.table_x_sales_tax.x_geocode IS 'CCH geocode';
COMMENT ON COLUMN sa.table_x_sales_tax.x_inout IS 'CCH In/Out city Indicator';
COMMENT ON COLUMN sa.table_x_sales_tax.x_e911foot IS 'E911 Footer Message';
COMMENT ON COLUMN sa.table_x_sales_tax.x_e911note IS 'E911 Notes';
COMMENT ON COLUMN sa.table_x_sales_tax.x_e911rate IS 'E911 Rates';
COMMENT ON COLUMN sa.table_x_sales_tax.x_e911surcharge IS 'E911 Surcharge';
COMMENT ON COLUMN sa.table_x_sales_tax.x_usf_taxrate IS 'USF Tax Rate';
COMMENT ON COLUMN sa.table_x_sales_tax.x_rcrfrate IS 'RCRF Tax Rate';
COMMENT ON COLUMN sa.table_x_sales_tax.x_non_sales IS 'Non Sales';
COMMENT ON COLUMN sa.table_x_sales_tax.x_wty_tax IS 'Tax Rate applied on Sales Tax Rate for Handset Protection Program';
COMMENT ON COLUMN sa.table_x_sales_tax.x_cwg_tax IS 'TAX RATE APPLIED ON SALES TAX RATE FOR HANDSET PROTECTION PROGRAM CLAIMS CWG';
COMMENT ON COLUMN sa.table_x_sales_tax.x_dataonly_tax IS 'Tax Rate applied on Data Only cards';
COMMENT ON COLUMN sa.table_x_sales_tax.x_car_connect_non_sales IS 'Car Connect device tax ( 0=Tax / 1=No Tax )';
COMMENT ON COLUMN sa.table_x_sales_tax.x_data_non_sales IS 'Data Card tax ( 0=Tax / 1=No Tax )';
COMMENT ON COLUMN sa.table_x_sales_tax.x_home_alert_non_sales IS 'Home Alert device tax ( 0=Tax / 1=No Tax )';
COMMENT ON COLUMN sa.table_x_sales_tax.x_non_shipping IS 'Shipping Tax ( 0=Tax / 1=No Tax )';
COMMENT ON COLUMN sa.table_x_sales_tax.x_ancillary_non_sales IS 'Tax for Ancillary Telecom Services.';
COMMENT ON COLUMN sa.table_x_sales_tax.x_digital_non_sales IS 'Tax for Digital Goods.';
COMMENT ON COLUMN sa.table_x_sales_tax.x_2waytext_sales IS 'TAX FOR TAX APPLICATION';
COMMENT ON COLUMN sa.table_x_sales_tax.x_2waytext_911 IS 'TAX FOR 911 APPLICATION';
COMMENT ON COLUMN sa.table_x_sales_tax.tpp_combtax IS 'Tax rates for Tangible Personal Property';