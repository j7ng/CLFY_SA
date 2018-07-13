CREATE TABLE sa.usc_new_cz (
  zip VARCHAR2(5 BYTE),
  st VARCHAR2(2 BYTE),
  old_zone_name VARCHAR2(100 BYTE),
  new_zone_name VARCHAR2(100 BYTE),
  carrier_name VARCHAR2(255 BYTE),
  plantype VARCHAR2(40 BYTE)
);
ALTER TABLE sa.usc_new_cz ADD SUPPLEMENTAL LOG GROUP dmtsora2090297717_0 (carrier_name, new_zone_name, old_zone_name, plantype, st, zip) ALWAYS;