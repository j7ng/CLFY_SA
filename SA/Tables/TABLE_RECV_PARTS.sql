CREATE TABLE sa.table_recv_parts (
  objid NUMBER,
  recv_notes VARCHAR2(255 BYTE),
  route_testing NUMBER,
  route_problem NUMBER,
  receipt_type NUMBER,
  recv_carrier VARCHAR2(40 BYTE),
  waybill VARCHAR2(40 BYTE),
  ship_damage NUMBER,
  proper_package NUMBER,
  dev NUMBER,
  recv_parts2part_info NUMBER(*,0)
);
ALTER TABLE sa.table_recv_parts ADD SUPPLEMENTAL LOG GROUP dmtsora627893137_0 (dev, objid, proper_package, receipt_type, recv_carrier, recv_notes, recv_parts2part_info, route_problem, route_testing, ship_damage, waybill) ALWAYS;
COMMENT ON TABLE sa.table_recv_parts IS 'Records the receipt of a shipment';
COMMENT ON COLUMN sa.table_recv_parts.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_recv_parts.recv_notes IS 'Notes recorded at receipt time';
COMMENT ON COLUMN sa.table_recv_parts.route_testing IS 'Indicates part routed to testing facility; i.e., 0=yes, 1=no';
COMMENT ON COLUMN sa.table_recv_parts.route_problem IS 'Reserved; future';
COMMENT ON COLUMN sa.table_recv_parts.receipt_type IS 'Reserved; future';
COMMENT ON COLUMN sa.table_recv_parts.recv_carrier IS 'Site name of the carrier who transported the part';
COMMENT ON COLUMN sa.table_recv_parts.waybill IS 'Waybill number of the shipment with which part was received';
COMMENT ON COLUMN sa.table_recv_parts.ship_damage IS 'Indicates possible damage to the shipped part; i.e., 0=yes, 1=no';
COMMENT ON COLUMN sa.table_recv_parts.proper_package IS 'Indicates possible packaging problem with the received part; i.e., 0=yes, 1=no';
COMMENT ON COLUMN sa.table_recv_parts.dev IS 'Row version number for mobile distribution purposes';
COMMENT ON COLUMN sa.table_recv_parts.recv_parts2part_info IS 'Reserved; not used';