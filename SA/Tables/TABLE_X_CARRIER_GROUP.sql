CREATE TABLE sa.table_x_carrier_group (
  objid NUMBER,
  x_carrier_group_id NUMBER,
  x_carrier_name VARCHAR2(30 BYTE),
  x_group2address NUMBER,
  x_status VARCHAR2(20 BYTE),
  x_carrier_group2x_parent NUMBER,
  x_no_auto_port NUMBER
);
ALTER TABLE sa.table_x_carrier_group ADD SUPPLEMENTAL LOG GROUP dmtsora406644428_0 (objid, x_carrier_group2x_parent, x_carrier_group_id, x_carrier_name, x_group2address, x_no_auto_port, x_status) ALWAYS;
COMMENT ON TABLE sa.table_x_carrier_group IS 'Stores all the carrier group information';
COMMENT ON COLUMN sa.table_x_carrier_group.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_x_carrier_group.x_carrier_group_id IS 'Carrier Identification Number';
COMMENT ON COLUMN sa.table_x_carrier_group.x_carrier_name IS 'Carrier Name';
COMMENT ON COLUMN sa.table_x_carrier_group.x_group2address IS 'Address  for the Carrier Group';
COMMENT ON COLUMN sa.table_x_carrier_group.x_status IS 'Carrier Status.  values = ACTIVE or INACTIVE';
COMMENT ON COLUMN sa.table_x_carrier_group.x_carrier_group2x_parent IS 'Relation to carrier group';
COMMENT ON COLUMN sa.table_x_carrier_group.x_no_auto_port IS 'Exception field created for AT&T 0=BAU, 1=Auto Port In Not Valid';