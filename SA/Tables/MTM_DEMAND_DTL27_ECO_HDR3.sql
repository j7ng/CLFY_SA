CREATE TABLE sa.mtm_demand_dtl27_eco_hdr3 (
  demand_dtl2eco_hdr NUMBER(*,0) NOT NULL,
  eco2demand_dtl NUMBER(*,0) NOT NULL
);
ALTER TABLE sa.mtm_demand_dtl27_eco_hdr3 ADD SUPPLEMENTAL LOG GROUP dmtsora830765795_0 (demand_dtl2eco_hdr, eco2demand_dtl) ALWAYS;