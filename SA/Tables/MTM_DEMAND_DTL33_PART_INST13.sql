CREATE TABLE sa.mtm_demand_dtl33_part_inst13 (
  fulflld_dtl2part_inst NUMBER(*,0) NOT NULL,
  fulflld2demand_dtl NUMBER(*,0) NOT NULL
);
ALTER TABLE sa.mtm_demand_dtl33_part_inst13 ADD SUPPLEMENTAL LOG GROUP dmtsora1453482426_0 (fulflld2demand_dtl, fulflld_dtl2part_inst) ALWAYS;