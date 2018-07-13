CREATE TABLE sa.ild_global_10_card_rates (
  objid NUMBER NOT NULL,
  x_country_english VARCHAR2(200 BYTE) NOT NULL,
  x_country_spanish VARCHAR2(200 BYTE),
  x_org_id VARCHAR2(50 BYTE) NOT NULL,
  x_web_rate NUMBER(10,4) NOT NULL,
  insert_date DATE DEFAULT SYSDATE,
  last_udpate DATE DEFAULT SYSDATE,
  x_user_id VARCHAR2(255 BYTE) NOT NULL,
  x_product_id VARCHAR2(20 BYTE) NOT NULL,
  CONSTRAINT ild_global_10_card_rates_pk PRIMARY KEY (objid)
);
COMMENT ON TABLE sa.ild_global_10_card_rates IS 'ILD GLOBAL $10 CARD RATES';
COMMENT ON COLUMN sa.ild_global_10_card_rates.objid IS 'Internal unique identifier for records in table ild_GLOBAL_10_CARD_RATES';
COMMENT ON COLUMN sa.ild_global_10_card_rates.x_country_english IS 'Used to enter the destination in English';
COMMENT ON COLUMN sa.ild_global_10_card_rates.x_country_spanish IS 'Used to enter the destination in Spanish';
COMMENT ON COLUMN sa.ild_global_10_card_rates.x_org_id IS 'Used to enter the supporting company brand';
COMMENT ON COLUMN sa.ild_global_10_card_rates.x_web_rate IS 'Used to enter the web site display rate';
COMMENT ON COLUMN sa.ild_global_10_card_rates.insert_date IS 'Date file has been updated on web';
COMMENT ON COLUMN sa.ild_global_10_card_rates.last_udpate IS 'Date previous update was completed';
COMMENT ON COLUMN sa.ild_global_10_card_rates.x_product_id IS 'VAS provisioning service ID';