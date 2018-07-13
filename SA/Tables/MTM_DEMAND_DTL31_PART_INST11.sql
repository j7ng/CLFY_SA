CREATE TABLE sa.mtm_demand_dtl31_part_inst11 (
  recd_dtl2part_inst NUMBER(*,0) NOT NULL,
  recd2demand_dtl NUMBER(*,0) NOT NULL
);
ALTER TABLE sa.mtm_demand_dtl31_part_inst11 ADD SUPPLEMENTAL LOG GROUP dmtsora1698555538_0 (recd2demand_dtl, recd_dtl2part_inst) ALWAYS;