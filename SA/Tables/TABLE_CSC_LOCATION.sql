CREATE TABLE sa.table_csc_location (
  objid NUMBER,
  location_type NUMBER,
  location_id VARCHAR2(80 BYTE),
  server_id NUMBER,
  dev NUMBER,
  location2csc_address NUMBER(*,0)
);
ALTER TABLE sa.table_csc_location ADD SUPPLEMENTAL LOG GROUP dmtsora1727453538_0 (dev, location2csc_address, location_id, location_type, objid, server_id) ALWAYS;