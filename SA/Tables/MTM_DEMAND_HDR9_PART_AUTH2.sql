CREATE TABLE sa.mtm_demand_hdr9_part_auth2 (
  autorepl2part_auth NUMBER(*,0) NOT NULL,
  part_auth2demand_hdr NUMBER(*,0) NOT NULL
);
ALTER TABLE sa.mtm_demand_hdr9_part_auth2 ADD SUPPLEMENTAL LOG GROUP dmtsora1787077141_0 (autorepl2part_auth, part_auth2demand_hdr) ALWAYS;