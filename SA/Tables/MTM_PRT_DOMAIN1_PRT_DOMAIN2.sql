CREATE TABLE sa.mtm_prt_domain1_prt_domain2 (
  to_domain2domain NUMBER(*,0) NOT NULL,
  from_domain2domain NUMBER(*,0) NOT NULL
);
ALTER TABLE sa.mtm_prt_domain1_prt_domain2 ADD SUPPLEMENTAL LOG GROUP dmtsora1481463029_0 (from_domain2domain, to_domain2domain) ALWAYS;