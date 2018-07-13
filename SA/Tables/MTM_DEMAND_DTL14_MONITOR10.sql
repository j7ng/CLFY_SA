CREATE TABLE sa.mtm_demand_dtl14_monitor10 (
  demand_dtl2monitor NUMBER(*,0) NOT NULL,
  monitor2demand_dtl NUMBER(*,0) NOT NULL
);
ALTER TABLE sa.mtm_demand_dtl14_monitor10 ADD SUPPLEMENTAL LOG GROUP dmtsora1610033936_0 (demand_dtl2monitor, monitor2demand_dtl) ALWAYS;