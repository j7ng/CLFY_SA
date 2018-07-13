CREATE TABLE sa.usc_new_npanxx (
  st VARCHAR2(2 BYTE),
  old_zone_name VARCHAR2(100 BYTE),
  carrier_id FLOAT,
  carrier_name VARCHAR2(255 BYTE),
  new_zone_name VARCHAR2(100 BYTE),
  npa VARCHAR2(5 BYTE),
  nxx VARCHAR2(5 BYTE)
);
ALTER TABLE sa.usc_new_npanxx ADD SUPPLEMENTAL LOG GROUP dmtsora108096984_0 (carrier_id, carrier_name, new_zone_name, npa, nxx, old_zone_name, st) ALWAYS;