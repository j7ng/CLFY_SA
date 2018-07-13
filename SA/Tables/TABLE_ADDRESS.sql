CREATE TABLE sa.table_address (
  objid NUMBER,
  address VARCHAR2(200 BYTE),
  s_address VARCHAR2(200 BYTE),
  city VARCHAR2(30 BYTE),
  s_city VARCHAR2(30 BYTE),
  "STATE" VARCHAR2(60 BYTE),
  s_state VARCHAR2(60 BYTE),
  zipcode VARCHAR2(60 BYTE),
  address_2 VARCHAR2(200 BYTE),
  dev NUMBER,
  address2time_zone NUMBER(*,0),
  address2country NUMBER(*,0),
  address2state_prov NUMBER(*,0),
  update_stamp DATE,
  address2e911 NUMBER
);
ALTER TABLE sa.table_address ADD SUPPLEMENTAL LOG GROUP dmtsora1127874162_0 (address, address2country, address2state_prov, address2time_zone, address_2, city, dev, objid, "STATE", s_address, s_city, s_state, update_stamp, zipcode) ALWAYS;
COMMENT ON TABLE sa.table_address IS 'Address object, contains postal addresses';
COMMENT ON COLUMN sa.table_address.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_address.address IS 'Line 1 of address which includes street number, street name, office, building, or suite number, etc';
COMMENT ON COLUMN sa.table_address.city IS 'The city for the specified address';
COMMENT ON COLUMN sa.table_address."STATE" IS 'The state for the specified address';
COMMENT ON COLUMN sa.table_address.zipcode IS 'The zip or other postal code for the specified address';
COMMENT ON COLUMN sa.table_address.address_2 IS 'Line 2 of address which typically includes office, building, or suite number, etc';
COMMENT ON COLUMN sa.table_address.dev IS 'Row version number for mobile distribution purposes';
COMMENT ON COLUMN sa.table_address.address2time_zone IS 'Time zone where address is located';
COMMENT ON COLUMN sa.table_address.address2country IS 'Country for address';
COMMENT ON COLUMN sa.table_address.address2state_prov IS 'State or province for address';
COMMENT ON COLUMN sa.table_address.update_stamp IS 'Date/time of last update to the address';
COMMENT ON COLUMN sa.table_address.address2e911 IS 'Table addreess to E911 addreess table';