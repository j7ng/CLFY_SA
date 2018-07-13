CREATE TABLE sa.mtm_wipbin4_employee7 (
  wipbin2employee NUMBER(*,0) NOT NULL,
  emp_access2wipbin NUMBER(*,0) NOT NULL
);
ALTER TABLE sa.mtm_wipbin4_employee7 ADD SUPPLEMENTAL LOG GROUP dmtsora840793571_0 (emp_access2wipbin, wipbin2employee) ALWAYS;