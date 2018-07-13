CREATE TABLE sa.alt_7days (
  x_service_id VARCHAR2(30 BYTE),
  x_min VARCHAR2(30 BYTE),
  x_carrier_id NUMBER,
  objid NUMBER,
  npa VARCHAR2(3 BYTE),
  nxx VARCHAR2(3 BYTE)
);
ALTER TABLE sa.alt_7days ADD SUPPLEMENTAL LOG GROUP dmtsora1627855186_0 (npa, nxx, objid, x_carrier_id, x_min, x_service_id) ALWAYS;