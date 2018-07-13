CREATE TABLE sa.tpsr013002 (
  mapstate VARCHAR2(11 BYTE),
  marketid NUMBER,
  "ZONE" VARCHAR2(56 BYTE),
  county VARCHAR2(41 BYTE),
  splitid VARCHAR2(6 BYTE),
  parenta VARCHAR2(35 BYTE),
  techa VARCHAR2(9 BYTE),
  carrierida VARCHAR2(23 BYTE),
  techdeploy VARCHAR2(15 BYTE),
  parentb VARCHAR2(35 BYTE),
  techb VARCHAR2(16 BYTE),
  carrieridb VARCHAR2(12 BYTE),
  techdeploy_1 VARCHAR2(15 BYTE),
  tracpref VARCHAR2(8 BYTE)
);
ALTER TABLE sa.tpsr013002 ADD SUPPLEMENTAL LOG GROUP dmtsora2078537427_0 (carrierida, carrieridb, county, mapstate, marketid, parenta, parentb, splitid, techa, techb, techdeploy, techdeploy_1, tracpref, "ZONE") ALWAYS;