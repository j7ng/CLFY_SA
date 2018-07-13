CREATE TABLE sa.table_csc_address (
  objid NUMBER,
  address_type NUMBER,
  geoaddress1 VARCHAR2(200 BYTE),
  s_geoaddress1 VARCHAR2(200 BYTE),
  geoaddress2 VARCHAR2(200 BYTE),
  s_geoaddress2 VARCHAR2(200 BYTE),
  geoaddress3 VARCHAR2(200 BYTE),
  geoaddress4 VARCHAR2(200 BYTE),
  city VARCHAR2(30 BYTE),
  s_city VARCHAR2(30 BYTE),
  region VARCHAR2(40 BYTE),
  s_region VARCHAR2(40 BYTE),
  postal_code VARCHAR2(20 BYTE),
  country VARCHAR2(40 BYTE),
  s_country VARCHAR2(40 BYTE),
  "TIME_ZONE" VARCHAR2(20 BYTE),
  s_time_zone VARCHAR2(20 BYTE),
  server_id NUMBER,
  dev NUMBER,
  address2csc_state_prov NUMBER(*,0),
  address2csc_tzone NUMBER(*,0),
  address2csc_country NUMBER(*,0)
);
ALTER TABLE sa.table_csc_address ADD SUPPLEMENTAL LOG GROUP dmtsora1429651581_0 (address2csc_country, address2csc_state_prov, address2csc_tzone, address_type, city, country, dev, geoaddress1, geoaddress2, geoaddress3, geoaddress4, objid, postal_code, region, server_id, s_city, s_country, s_geoaddress1, s_geoaddress2, s_region, s_time_zone, "TIME_ZONE") ALWAYS;
COMMENT ON TABLE sa.table_csc_address IS 'This object contains a specific address for an individual, or an organization ';
COMMENT ON COLUMN sa.table_csc_address.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_csc_address.address_type IS 'Identifies the address type: i.e., 0=primay, 1=shipping, 2=billing, 3=service, 255=unknown. Default=0';
COMMENT ON COLUMN sa.table_csc_address.geoaddress1 IS ' First line of address';
COMMENT ON COLUMN sa.table_csc_address.geoaddress2 IS ' Second line of address';
COMMENT ON COLUMN sa.table_csc_address.geoaddress3 IS ' Third line of address';
COMMENT ON COLUMN sa.table_csc_address.geoaddress4 IS ' Fourth line of address';
COMMENT ON COLUMN sa.table_csc_address.city IS 'The city for the specified address';
COMMENT ON COLUMN sa.table_csc_address.region IS 'The region that the address belongs to';
COMMENT ON COLUMN sa.table_csc_address.postal_code IS 'The zip or other postal code for the specified address';
COMMENT ON COLUMN sa.table_csc_address.country IS 'Name of the specific country';
COMMENT ON COLUMN sa.table_csc_address."TIME_ZONE" IS 'Time zone name';
COMMENT ON COLUMN sa.table_csc_address.server_id IS 'Exchange prodocol server ID number';
COMMENT ON COLUMN sa.table_csc_address.dev IS 'Row version number for mobile distribution purposes';
COMMENT ON COLUMN sa.table_csc_address.address2csc_state_prov IS 'Related CSC organization';
COMMENT ON COLUMN sa.table_csc_address.address2csc_tzone IS 'Time zone where CSC address is located';
COMMENT ON COLUMN sa.table_csc_address.address2csc_country IS 'Related CSC country';