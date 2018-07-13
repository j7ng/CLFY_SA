CREATE TABLE sa.table_x_bundle (
  objid NUMBER NOT NULL,
  bundle2part_inst NUMBER,
  x_bundle_code VARCHAR2(50 BYTE),
  status VARCHAR2(30 BYTE),
  pin2esn_flag VARCHAR2(1 BYTE) DEFAULT 'N',
  x_created_date DATE DEFAULT SYSDATE,
  x_updated_date DATE DEFAULT SYSDATE
);
COMMENT ON COLUMN sa.table_x_bundle.objid IS 'Unique identifier of the record.';
COMMENT ON COLUMN sa.table_x_bundle.bundle2part_inst IS 'Reference to table_part_inst';
COMMENT ON COLUMN sa.table_x_bundle.x_bundle_code IS 'x_bundle_code unique identifier for the spefic bundle';
COMMENT ON COLUMN sa.table_x_bundle.status IS 'Status';
COMMENT ON COLUMN sa.table_x_bundle.pin2esn_flag IS 'Assigned pin to ESN flag';
COMMENT ON COLUMN sa.table_x_bundle.x_created_date IS 'Date when the record was created';
COMMENT ON COLUMN sa.table_x_bundle.x_updated_date IS 'Date when the record was updated';