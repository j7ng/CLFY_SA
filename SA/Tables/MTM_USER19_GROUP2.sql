CREATE TABLE sa.mtm_user19_group2 (
  user_access2group NUMBER(*,0) NOT NULL,
  assigned_group2user NUMBER(*,0) NOT NULL
);
ALTER TABLE sa.mtm_user19_group2 ADD SUPPLEMENTAL LOG GROUP dmtsora1966947436_0 (assigned_group2user, user_access2group) ALWAYS;