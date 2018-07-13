CREATE TABLE sa.tf_of_r7_inv_v (
  tf_serial_number VARCHAR2(50 BYTE),
  primary_item VARCHAR2(40 BYTE),
  part_num VARCHAR2(40 BYTE),
  x_bundle_code VARCHAR2(50 BYTE),
  record_type VARCHAR2(10 BYTE),
  ff_reference VARCHAR2(20 BYTE),
  license_plate VARCHAR2(50 BYTE),
  process_date DATE
);
COMMENT ON COLUMN sa.tf_of_r7_inv_v.tf_serial_number IS 'Serail number for ESN and PIN.';
COMMENT ON COLUMN sa.tf_of_r7_inv_v.primary_item IS 'Part number of the Serail number';
COMMENT ON COLUMN sa.tf_of_r7_inv_v.part_num IS 'Part number of the bundle';
COMMENT ON COLUMN sa.tf_of_r7_inv_v.x_bundle_code IS 'Bundle code to identify specific bundle info';
COMMENT ON COLUMN sa.tf_of_r7_inv_v.record_type IS 'record type';
COMMENT ON COLUMN sa.tf_of_r7_inv_v.ff_reference IS 'Reference type';
COMMENT ON COLUMN sa.tf_of_r7_inv_v.license_plate IS 'License plate';
COMMENT ON COLUMN sa.tf_of_r7_inv_v.process_date IS 'Process date';