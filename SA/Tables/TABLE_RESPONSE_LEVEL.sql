CREATE TABLE sa.table_response_level (
  objid NUMBER,
  distance NUMBER,
  distance_unit VARCHAR2(30 BYTE),
  "TIME" NUMBER,
  time_unit VARCHAR2(20 BYTE),
  response_type VARCHAR2(40 BYTE),
  response_desc VARCHAR2(255 BYTE),
  dev NUMBER,
  response2entitlement NUMBER(*,0)
);
ALTER TABLE sa.table_response_level ADD SUPPLEMENTAL LOG GROUP dmtsora452574804_0 (dev, distance, distance_unit, objid, response2entitlement, response_desc, response_type, "TIME", time_unit) ALWAYS;