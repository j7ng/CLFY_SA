CREATE TABLE sa.mtm_demand_dtl32_part_inst12 (
  pickd_dtl2part_inst NUMBER(*,0) NOT NULL,
  pickd2demand_dtl NUMBER(*,0) NOT NULL
);
ALTER TABLE sa.mtm_demand_dtl32_part_inst12 ADD SUPPLEMENTAL LOG GROUP dmtsora814822556_0 (pickd2demand_dtl, pickd_dtl2part_inst) ALWAYS;