CREATE TABLE sa.x_byop_mkt_carriers (
  x_mkt_carrier VARCHAR2(50 BYTE) NOT NULL,
  x_brand VARCHAR2(30 BYTE) NOT NULL,
  x_byop_option VARCHAR2(50 BYTE) NOT NULL CONSTRAINT byop_option_ck CHECK (X_BYOP_OPTION in ('ATT_BYOP','SPRINT_BYOP','TMOBILE_BYOP','VERIZON_BYOP','NOT_ELIGIBLE','MULTIPLE_CARRIERS')),
  CONSTRAINT mkt_carr_brand_pk PRIMARY KEY (x_mkt_carrier,x_brand)
);
COMMENT ON TABLE sa.x_byop_mkt_carriers IS 'BYOP Flow carrier selection configuration';
COMMENT ON COLUMN sa.x_byop_mkt_carriers.x_mkt_carrier IS 'Market Carrier Name';
COMMENT ON COLUMN sa.x_byop_mkt_carriers.x_brand IS 'Brand Name TRACFONE | STRAIGHT_TALK';
COMMENT ON COLUMN sa.x_byop_mkt_carriers.x_byop_option IS 'BYOP Scenario';