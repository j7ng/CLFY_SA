CREATE TABLE sa.x_carrier_broadcast_sids (
  x_load_date DATE,
  x_cell_mkt_num NUMBER,
  x_cell_mkt_name VARCHAR2(33 BYTE),
  x_parent_id VARCHAR2(30 BYTE),
  x_parent_name VARCHAR2(50 BYTE),
  x_sid VARCHAR2(10 BYTE)
);
ALTER TABLE sa.x_carrier_broadcast_sids ADD SUPPLEMENTAL LOG GROUP dmtsora993313009_0 (x_cell_mkt_name, x_cell_mkt_num, x_load_date, x_parent_id, x_parent_name, x_sid) ALWAYS;
COMMENT ON TABLE sa.x_carrier_broadcast_sids IS 'Broadcast SIDs per Carrier Parent';
COMMENT ON COLUMN sa.x_carrier_broadcast_sids.x_load_date IS 'Record Loading Date';
COMMENT ON COLUMN sa.x_carrier_broadcast_sids.x_cell_mkt_num IS 'Cellular Market Number';
COMMENT ON COLUMN sa.x_carrier_broadcast_sids.x_cell_mkt_name IS 'Cellular Market Name';
COMMENT ON COLUMN sa.x_carrier_broadcast_sids.x_parent_id IS 'Reference x_parent_id in table_x_parent';
COMMENT ON COLUMN sa.x_carrier_broadcast_sids.x_parent_name IS 'Carrier Parent Name';
COMMENT ON COLUMN sa.x_carrier_broadcast_sids.x_sid IS 'Carrier SID';