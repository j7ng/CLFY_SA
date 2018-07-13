CREATE TABLE sa.npanxx2carrierzones (
  npa VARCHAR2(5 BYTE),
  nxx VARCHAR2(5 BYTE),
  carrier_id FLOAT,
  carrier_name VARCHAR2(255 BYTE),
  lead_time FLOAT,
  target_level FLOAT,
  ratecenter VARCHAR2(15 BYTE),
  "STATE" VARCHAR2(4 BYTE),
  carrier_id_description VARCHAR2(255 BYTE),
  "ZONE" VARCHAR2(100 BYTE),
  county VARCHAR2(50 BYTE),
  marketid FLOAT,
  mrkt_area VARCHAR2(33 BYTE),
  "SID" VARCHAR2(10 BYTE),
  technology VARCHAR2(20 BYTE),
  frequency1 NUMBER,
  frequency2 NUMBER,
  bta_mkt_number VARCHAR2(4 BYTE),
  bta_mkt_name VARCHAR2(100 BYTE),
  gsm_tech VARCHAR2(20 BYTE),
  cdma_tech VARCHAR2(20 BYTE),
  tdma_tech VARCHAR2(20 BYTE),
  mnc VARCHAR2(5 BYTE),
  CONSTRAINT npanxx2carrierzones_uk1 UNIQUE (npa,nxx,"STATE","ZONE",carrier_id,"SID",ratecenter)
);
ALTER TABLE sa.npanxx2carrierzones ADD SUPPLEMENTAL LOG GROUP dmtsora1098386539_0 (bta_mkt_name, bta_mkt_number, carrier_id, carrier_id_description, carrier_name, cdma_tech, county, frequency1, frequency2, gsm_tech, lead_time, marketid, mnc, mrkt_area, npa, nxx, ratecenter, "SID", "STATE", target_level, tdma_tech, technology, "ZONE") ALWAYS;
COMMENT ON TABLE sa.npanxx2carrierzones IS 'Coverage Definition Table, maps NPA,NXX to carrier zone information and technology available.';
COMMENT ON COLUMN sa.npanxx2carrierzones.npa IS 'NPA';
COMMENT ON COLUMN sa.npanxx2carrierzones.nxx IS 'NXX';
COMMENT ON COLUMN sa.npanxx2carrierzones.carrier_id IS 'Carrier ID, References table_x_carrier';
COMMENT ON COLUMN sa.npanxx2carrierzones.carrier_name IS 'Carrier Name';
COMMENT ON COLUMN sa.npanxx2carrierzones.lead_time IS 'Lead Time';
COMMENT ON COLUMN sa.npanxx2carrierzones.target_level IS 'Inventory Target Level';
COMMENT ON COLUMN sa.npanxx2carrierzones.ratecenter IS 'Rate Center';
COMMENT ON COLUMN sa.npanxx2carrierzones."STATE" IS 'State Code';
COMMENT ON COLUMN sa.npanxx2carrierzones.carrier_id_description IS 'Carrier ID Description';
COMMENT ON COLUMN sa.npanxx2carrierzones."ZONE" IS 'Zone';
COMMENT ON COLUMN sa.npanxx2carrierzones.county IS 'County';
COMMENT ON COLUMN sa.npanxx2carrierzones.marketid IS 'Market ID';
COMMENT ON COLUMN sa.npanxx2carrierzones.mrkt_area IS 'Market Area';
COMMENT ON COLUMN sa.npanxx2carrierzones."SID" IS 'SID';
COMMENT ON COLUMN sa.npanxx2carrierzones.technology IS 'Technology: GSM, CDMA';
COMMENT ON COLUMN sa.npanxx2carrierzones.frequency1 IS 'Frequency 1';
COMMENT ON COLUMN sa.npanxx2carrierzones.frequency2 IS 'Frequency 2';
COMMENT ON COLUMN sa.npanxx2carrierzones.bta_mkt_number IS 'BTA Market Number';
COMMENT ON COLUMN sa.npanxx2carrierzones.bta_mkt_name IS 'BTA Market Name';
COMMENT ON COLUMN sa.npanxx2carrierzones.gsm_tech IS 'GSM Tech flag: GSM,null';
COMMENT ON COLUMN sa.npanxx2carrierzones.cdma_tech IS 'CDMA Tech Flag: CDMA, null';
COMMENT ON COLUMN sa.npanxx2carrierzones.tdma_tech IS 'TDMA Tech Flag: TDMA,null';
COMMENT ON COLUMN sa.npanxx2carrierzones.mnc IS 'MNC';