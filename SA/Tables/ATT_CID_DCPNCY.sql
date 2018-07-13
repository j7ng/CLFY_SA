CREATE TABLE sa.att_cid_dcpncy (
  zip VARCHAR2(5 BYTE),
  marketid FLOAT,
  county VARCHAR2(50 BYTE),
  "STATE" VARCHAR2(4 BYTE),
  "ZONE" VARCHAR2(100 BYTE),
  carrier_id FLOAT,
  x_default_queue VARCHAR2(30 BYTE),
  nan_template VARCHAR2(20 BYTE)
);
ALTER TABLE sa.att_cid_dcpncy ADD SUPPLEMENTAL LOG GROUP dmtsora527261347_0 (carrier_id, county, marketid, nan_template, "STATE", x_default_queue, zip, "ZONE") ALWAYS;