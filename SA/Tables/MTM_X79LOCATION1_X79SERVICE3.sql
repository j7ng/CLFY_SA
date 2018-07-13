CREATE TABLE sa.mtm_x79location1_x79service3 (
  loc2x79service NUMBER(*,0) NOT NULL,
  service2x79location NUMBER(*,0) NOT NULL
);
ALTER TABLE sa.mtm_x79location1_x79service3 ADD SUPPLEMENTAL LOG GROUP dmtsora1321503940_0 (loc2x79service, service2x79location) ALWAYS;