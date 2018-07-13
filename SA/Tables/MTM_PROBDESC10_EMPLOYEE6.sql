CREATE TABLE sa.mtm_probdesc10_employee6 (
  probdesc_emp2employee NUMBER(*,0) NOT NULL,
  creator2probdesc NUMBER(*,0) NOT NULL
);
ALTER TABLE sa.mtm_probdesc10_employee6 ADD SUPPLEMENTAL LOG GROUP dmtsora1238197797_0 (creator2probdesc, probdesc_emp2employee) ALWAYS;