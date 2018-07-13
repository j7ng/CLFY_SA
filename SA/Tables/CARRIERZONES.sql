CREATE TABLE sa.carrierzones (
  zip VARCHAR2(5 BYTE),
  st VARCHAR2(2 BYTE),
  county VARCHAR2(50 BYTE),
  "ZONE" VARCHAR2(100 BYTE),
  rate_cente VARCHAR2(30 BYTE),
  marketid FLOAT,
  mrkt_area VARCHAR2(33 BYTE),
  city VARCHAR2(100 BYTE),
  bta_mkt_number VARCHAR2(4 BYTE),
  bta_mkt_name VARCHAR2(100 BYTE),
  carrier_id FLOAT,
  carrier_name VARCHAR2(255 BYTE),
  zip_status VARCHAR2(15 BYTE),
  sim_profile VARCHAR2(30 BYTE),
  sim_profile_2 VARCHAR2(30 BYTE),
  plantype VARCHAR2(40 BYTE),
  CONSTRAINT carrierzones_uk1 UNIQUE (zip,st,county,"ZONE",carrier_name)
);
COMMENT ON TABLE sa.carrierzones IS 'Coverage Definition Table, maps zip codes to carrier information';
COMMENT ON COLUMN sa.carrierzones.zip IS 'Zip Code';
COMMENT ON COLUMN sa.carrierzones.st IS 'State Code';
COMMENT ON COLUMN sa.carrierzones.county IS 'County Name';
COMMENT ON COLUMN sa.carrierzones."ZONE" IS 'Zone Name';
COMMENT ON COLUMN sa.carrierzones.rate_cente IS 'Rate Center';
COMMENT ON COLUMN sa.carrierzones.marketid IS 'market ID';
COMMENT ON COLUMN sa.carrierzones.mrkt_area IS 'Market Area';
COMMENT ON COLUMN sa.carrierzones.city IS 'City';
COMMENT ON COLUMN sa.carrierzones.bta_mkt_number IS 'BTA Market Number';
COMMENT ON COLUMN sa.carrierzones.bta_mkt_name IS 'BTA Market Name';
COMMENT ON COLUMN sa.carrierzones.carrier_id IS 'Carrier ID';
COMMENT ON COLUMN sa.carrierzones.carrier_name IS 'Carrier Name';
COMMENT ON COLUMN sa.carrierzones.zip_status IS 'Zip Status: ACTIVE, INACTIVE';
COMMENT ON COLUMN sa.carrierzones.sim_profile IS 'not used, replaced by carriersimpref table';
COMMENT ON COLUMN sa.carrierzones.sim_profile_2 IS 'not used, replaced by carriersimpref table';
COMMENT ON COLUMN sa.carrierzones.plantype IS 'not used';