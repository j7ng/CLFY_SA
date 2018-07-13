CREATE TABLE sa.table_x_byop_offers (
  objid VARCHAR2(30 BYTE),
  bus_org_id VARCHAR2(100 BYTE),
  carrier VARCHAR2(100 BYTE),
  offer_key VARCHAR2(100 BYTE),
  pin_part_number VARCHAR2(100 BYTE),
  active_flag VARCHAR2(5 BYTE),
  created_on DATE,
  created_by VARCHAR2(30 BYTE),
  modified_on DATE,
  modified_by VARCHAR2(30 BYTE)
);
COMMENT ON TABLE sa.table_x_byop_offers IS 'Table to hold configuration for BYOP offers';
COMMENT ON COLUMN sa.table_x_byop_offers.objid IS 'Unique objid';
COMMENT ON COLUMN sa.table_x_byop_offers.bus_org_id IS 's_bus_org_id from table_bus_org';
COMMENT ON COLUMN sa.table_x_byop_offers.carrier IS 'Carriers';
COMMENT ON COLUMN sa.table_x_byop_offers.offer_key IS 'NAC or Service plan..';
COMMENT ON COLUMN sa.table_x_byop_offers.pin_part_number IS 'Pin part number';
COMMENT ON COLUMN sa.table_x_byop_offers.active_flag IS 'Y or N flag..';
COMMENT ON COLUMN sa.table_x_byop_offers.created_on IS 'Created date';
COMMENT ON COLUMN sa.table_x_byop_offers.created_by IS 'Created by user';
COMMENT ON COLUMN sa.table_x_byop_offers.modified_on IS 'Modified date';
COMMENT ON COLUMN sa.table_x_byop_offers.modified_by IS 'Modified by user';