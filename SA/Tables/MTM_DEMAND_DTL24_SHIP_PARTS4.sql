CREATE TABLE sa.mtm_demand_dtl24_ship_parts4 (
  demand_dtl2shipper NUMBER(*,0) NOT NULL,
  shipper2demand_dtl NUMBER(*,0) NOT NULL
);
ALTER TABLE sa.mtm_demand_dtl24_ship_parts4 ADD SUPPLEMENTAL LOG GROUP dmtsora474379295_0 (demand_dtl2shipper, shipper2demand_dtl) ALWAYS;