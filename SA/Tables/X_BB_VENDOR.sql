CREATE TABLE sa.x_bb_vendor (
  x_vendor_id VARCHAR2(30 BYTE),
  x_vendor_name VARCHAR2(30 BYTE)
);
COMMENT ON TABLE sa.x_bb_vendor IS 'TO SAVE INFORMATION FOR VENDORS';
COMMENT ON COLUMN sa.x_bb_vendor.x_vendor_id IS 'UNIQUE IDENTIFIER FOR VENDOR';
COMMENT ON COLUMN sa.x_bb_vendor.x_vendor_name IS 'VENDOR NAME';