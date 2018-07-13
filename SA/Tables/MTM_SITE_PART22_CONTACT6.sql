CREATE TABLE sa.mtm_site_part22_contact6 (
  site_part2contact NUMBER(*,0) NOT NULL,
  contact2site_part NUMBER(*,0) NOT NULL
);
ALTER TABLE sa.mtm_site_part22_contact6 ADD SUPPLEMENTAL LOG GROUP dmtsora1443503579_0 (contact2site_part, site_part2contact) ALWAYS;