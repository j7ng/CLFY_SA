CREATE TABLE sa.mtm_part_num22_x_ff_center2 (
  part_num2ff_center NUMBER NOT NULL,
  ff_center2part_num NUMBER NOT NULL
);
ALTER TABLE sa.mtm_part_num22_x_ff_center2 ADD SUPPLEMENTAL LOG GROUP dmtsora1050441735_0 (ff_center2part_num, part_num2ff_center) ALWAYS;
COMMENT ON TABLE sa.mtm_part_num22_x_ff_center2 IS 'Part number available for dispatch for a given FF center';
COMMENT ON COLUMN sa.mtm_part_num22_x_ff_center2.part_num2ff_center IS 'Reference to objid of table table_part_num';
COMMENT ON COLUMN sa.mtm_part_num22_x_ff_center2.ff_center2part_num IS 'Reference to objid of table table_x_ff_center';