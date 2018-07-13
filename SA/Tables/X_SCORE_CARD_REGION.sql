CREATE TABLE sa.x_score_card_region (
  zip VARCHAR2(5 BYTE),
  city VARCHAR2(28 BYTE),
  st VARCHAR2(2 BYTE),
  retailer VARCHAR2(100 BYTE),
  region VARCHAR2(40 BYTE)
);
ALTER TABLE sa.x_score_card_region ADD SUPPLEMENTAL LOG GROUP dmtsora839501812_0 (city, region, retailer, st, zip) ALWAYS;