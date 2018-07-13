CREATE TABLE sa.mtm_probdesc12_bug28 (
  probdesc2bug NUMBER(*,0) NOT NULL,
  bug2probdesc NUMBER(*,0) NOT NULL
);
ALTER TABLE sa.mtm_probdesc12_bug28 ADD SUPPLEMENTAL LOG GROUP dmtsora264731131_0 (bug2probdesc, probdesc2bug) ALWAYS;