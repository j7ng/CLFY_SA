CREATE TABLE sa.address_hot_list (
  objid NUMBER,
  x_address VARCHAR2(200 BYTE),
  x_city VARCHAR2(30 BYTE),
  x_state VARCHAR2(10 BYTE),
  x_zipcode VARCHAR2(10 BYTE),
  x_location_description VARCHAR2(50 BYTE),
  x_direction VARCHAR2(10 BYTE),
  x_street_type VARCHAR2(10 BYTE),
  x_unit_designator VARCHAR2(10 BYTE),
  x_unit VARCHAR2(10 BYTE)
);
COMMENT ON TABLE sa.address_hot_list IS 'ADDRESS HOT LIST, DO NOT SHIP TO THESE ADDRESSES';
COMMENT ON COLUMN sa.address_hot_list.objid IS 'PRIMARY KEY';
COMMENT ON COLUMN sa.address_hot_list.x_address IS 'STREET ADDRESS';
COMMENT ON COLUMN sa.address_hot_list.x_city IS 'CITY';
COMMENT ON COLUMN sa.address_hot_list.x_state IS 'STATE';
COMMENT ON COLUMN sa.address_hot_list.x_zipcode IS 'ZIP CODE';
COMMENT ON COLUMN sa.address_hot_list.x_location_description IS 'LOCATION DESCRIPTION';
COMMENT ON COLUMN sa.address_hot_list.x_direction IS 'DIRECTION';
COMMENT ON COLUMN sa.address_hot_list.x_street_type IS 'STREET TYPE';
COMMENT ON COLUMN sa.address_hot_list.x_unit_designator IS 'UNIT DESIGNATOR';
COMMENT ON COLUMN sa.address_hot_list.x_unit IS 'UNIT';