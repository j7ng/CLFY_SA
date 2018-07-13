CREATE TABLE sa.x_byop_part_num (
  x_org_id VARCHAR2(30 BYTE),
  x_byop_type VARCHAR2(500 BYTE) NOT NULL,
  x_part_number VARCHAR2(30 BYTE)
);
COMMENT ON TABLE sa.x_byop_part_num IS 'lookup table to convert bus_org and byop_type in to part_number';
COMMENT ON COLUMN sa.x_byop_part_num.x_org_id IS 'brand of phone';
COMMENT ON COLUMN sa.x_byop_part_num.x_byop_type IS 'determines the which carrier to use';
COMMENT ON COLUMN sa.x_byop_part_num.x_part_number IS 'look up return part_number';