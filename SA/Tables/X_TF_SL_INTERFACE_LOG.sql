CREATE TABLE sa.x_tf_sl_interface_log (
  id_number VARCHAR2(30 BYTE),
  serial_number VARCHAR2(30 BYTE),
  tracking__number VARCHAR2(30 BYTE),
  insert_date DATE,
  exception_desc VARCHAR2(200 BYTE)
);
COMMENT ON TABLE sa.x_tf_sl_interface_log IS 'Tracfone, Safelink Shipping Interface Log Table';
COMMENT ON COLUMN sa.x_tf_sl_interface_log.id_number IS 'Reference table_case, id_number';
COMMENT ON COLUMN sa.x_tf_sl_interface_log.serial_number IS 'Reference table_part_inst, part_serial_no';
COMMENT ON COLUMN sa.x_tf_sl_interface_log.tracking__number IS 'Tracking Number from Courier Service';
COMMENT ON COLUMN sa.x_tf_sl_interface_log.insert_date IS 'Insert Timestamp';
COMMENT ON COLUMN sa.x_tf_sl_interface_log.exception_desc IS 'Description of any exception occurred.';