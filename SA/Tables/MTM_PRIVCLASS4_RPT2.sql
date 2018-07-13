CREATE TABLE sa.mtm_privclass4_rpt2 (
  privclass2rpt NUMBER(*,0) NOT NULL,
  rpt2privclass NUMBER(*,0) NOT NULL
);
ALTER TABLE sa.mtm_privclass4_rpt2 ADD SUPPLEMENTAL LOG GROUP dmtsora1731328257_0 (privclass2rpt, rpt2privclass) ALWAYS;