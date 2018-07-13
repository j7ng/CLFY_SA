CREATE TABLE sa.mtm_site_part4_contract2 (
  site_part2contract NUMBER(*,0) NOT NULL,
  contract2site_part NUMBER(*,0) NOT NULL
);
ALTER TABLE sa.mtm_site_part4_contract2 ADD SUPPLEMENTAL LOG GROUP dmtsora1286060914_0 (contract2site_part, site_part2contract) ALWAYS;