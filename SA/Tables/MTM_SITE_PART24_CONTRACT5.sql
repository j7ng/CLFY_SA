CREATE TABLE sa.mtm_site_part24_contract5 (
  dir_sitepart2contract NUMBER(*,0) NOT NULL,
  contract2dir_sitepart NUMBER(*,0) NOT NULL
);
ALTER TABLE sa.mtm_site_part24_contract5 ADD SUPPLEMENTAL LOG GROUP dmtsora790374325_0 (contract2dir_sitepart, dir_sitepart2contract) ALWAYS;