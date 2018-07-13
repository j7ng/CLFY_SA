CREATE TABLE sa.alt_zones (
  st VARCHAR2(2 BYTE),
  "ZONE" VARCHAR2(100 BYTE),
  npa VARCHAR2(5 BYTE),
  nxx VARCHAR2(5 BYTE),
  carrier_id FLOAT,
  objid NUMBER
);
ALTER TABLE sa.alt_zones ADD SUPPLEMENTAL LOG GROUP dmtsora1993858473_0 (carrier_id, npa, nxx, objid, st, "ZONE") ALWAYS;