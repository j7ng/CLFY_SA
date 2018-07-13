CREATE TABLE sa.table_ship_parts (
  objid NUMBER,
  ship_to_name VARCHAR2(40 BYTE),
  ship_address VARCHAR2(30 BYTE),
  ship_address2 VARCHAR2(30 BYTE),
  ship_date DATE,
  ship_city VARCHAR2(30 BYTE),
  ship_zip VARCHAR2(10 BYTE),
  ship_state VARCHAR2(30 BYTE),
  ship_country VARCHAR2(30 BYTE),
  ship_attn VARCHAR2(30 BYTE),
  s_ship_attn VARCHAR2(30 BYTE),
  waybill VARCHAR2(40 BYTE),
  packing_list VARCHAR2(30 BYTE),
  pieces NUMBER,
  total_weight NUMBER,
  shipper_user VARCHAR2(30 BYTE),
  s_shipper_user VARCHAR2(30 BYTE),
  ship_attn2 VARCHAR2(40 BYTE),
  s_ship_attn2 VARCHAR2(40 BYTE),
  dev NUMBER,
  shipment2demand_dtl NUMBER(*,0),
  carrier2vendor NUMBER(*,0),
  shipped_by2user NUMBER(*,0)
);
ALTER TABLE sa.table_ship_parts ADD SUPPLEMENTAL LOG GROUP dmtsora412608508_0 (carrier2vendor, dev, objid, packing_list, pieces, shipment2demand_dtl, shipped_by2user, shipper_user, ship_address, ship_address2, ship_attn, ship_attn2, ship_city, ship_country, ship_date, ship_state, ship_to_name, ship_zip, s_shipper_user, s_ship_attn, s_ship_attn2, total_weight, waybill) ALWAYS;
COMMENT ON TABLE sa.table_ship_parts IS 'Information about a parts shipment';
COMMENT ON COLUMN sa.table_ship_parts.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_ship_parts.ship_to_name IS 'Name of the location being shipped to';
COMMENT ON COLUMN sa.table_ship_parts.ship_address IS 'Local copy of the ship address; line 1';
COMMENT ON COLUMN sa.table_ship_parts.ship_address2 IS 'Local copy of the ship address; line 2';
COMMENT ON COLUMN sa.table_ship_parts.ship_date IS 'Date shipper was created';
COMMENT ON COLUMN sa.table_ship_parts.ship_city IS 'Local copy of the ship city';
COMMENT ON COLUMN sa.table_ship_parts.ship_zip IS 'Local copy of the ship zip code';
COMMENT ON COLUMN sa.table_ship_parts.ship_state IS 'Local copy of the ship state';
COMMENT ON COLUMN sa.table_ship_parts.ship_country IS 'Local copy of the ship country';
COMMENT ON COLUMN sa.table_ship_parts.ship_attn IS 'The first name of the person that is to receive the shipment. Defaulted from demand_hdr.ship_attn';
COMMENT ON COLUMN sa.table_ship_parts.waybill IS 'The shipment waybill number';
COMMENT ON COLUMN sa.table_ship_parts.packing_list IS 'The shipment packing list number ';
COMMENT ON COLUMN sa.table_ship_parts.pieces IS 'Quantity of pieces in the shipment';
COMMENT ON COLUMN sa.table_ship_parts.total_weight IS 'Total shipment weight';
COMMENT ON COLUMN sa.table_ship_parts.shipper_user IS 'Login name of user who created the ship parts';
COMMENT ON COLUMN sa.table_ship_parts.ship_attn2 IS 'Last name of the person that is to receive the shipment. Defaulted from demand_hdr.ship_attn2';
COMMENT ON COLUMN sa.table_ship_parts.dev IS 'Row version number for mobile distribution purposes';
COMMENT ON COLUMN sa.table_ship_parts.shipment2demand_dtl IS 'Reserved; not used. Use shipper2demand_dtl';
COMMENT ON COLUMN sa.table_ship_parts.carrier2vendor IS 'The carrier for the shipment';
COMMENT ON COLUMN sa.table_ship_parts.shipped_by2user IS 'User that created the shipment entry';