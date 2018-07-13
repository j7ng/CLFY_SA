CREATE TABLE sa.cz_bk (
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
  sim_profile VARCHAR2(10 BYTE),
  sim_profile_2 VARCHAR2(10 BYTE),
  plantype VARCHAR2(40 BYTE)
);
ALTER TABLE sa.cz_bk ADD SUPPLEMENTAL LOG GROUP dmtsora74188656_0 (bta_mkt_name, bta_mkt_number, carrier_id, carrier_name, city, county, marketid, mrkt_area, plantype, rate_cente, sim_profile, sim_profile_2, st, zip, zip_status, "ZONE") ALWAYS;