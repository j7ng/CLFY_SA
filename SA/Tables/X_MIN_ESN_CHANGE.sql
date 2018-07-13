CREATE TABLE sa.x_min_esn_change (
  x_transaction_id NUMBER(38) NOT NULL,
  x_attached_date DATE,
  x_min VARCHAR2(30 BYTE) NOT NULL,
  x_old_esn VARCHAR2(30 BYTE) NOT NULL,
  x_detach_dt DATE NOT NULL,
  x_new_esn VARCHAR2(30 BYTE)
);
ALTER TABLE sa.x_min_esn_change ADD SUPPLEMENTAL LOG GROUP dmtsora1829572185_0 (x_attached_date, x_detach_dt, x_min, x_new_esn, x_old_esn, x_transaction_id) ALWAYS;
COMMENT ON TABLE sa.x_min_esn_change IS 'This table keeps track of the transfer of a line between ESNs';
COMMENT ON COLUMN sa.x_min_esn_change.x_transaction_id IS 'Primary Key, Internal Record Id';
COMMENT ON COLUMN sa.x_min_esn_change.x_attached_date IS 'Date MIN gets assigned to Phone/ESN';
COMMENT ON COLUMN sa.x_min_esn_change.x_min IS 'Min Number (10 Digit Phone Number) references to table_part_inst.part_serial_no ';
COMMENT ON COLUMN sa.x_min_esn_change.x_old_esn IS 'Old ESN using the Line, references to table_part_inst.part_serial_no ';
COMMENT ON COLUMN sa.x_min_esn_change.x_detach_dt IS 'Date the line is no longer attached to OLD ESN.';
COMMENT ON COLUMN sa.x_min_esn_change.x_new_esn IS 'Serial Numbe of New ESN using the MIN, references to table_part_inst.part_serial_no';