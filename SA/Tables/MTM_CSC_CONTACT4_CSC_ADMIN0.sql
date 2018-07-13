CREATE TABLE sa.mtm_csc_contact4_csc_admin0 (
  owner2csc_admin NUMBER(*,0) NOT NULL,
  owner2csc_contact NUMBER(*,0) NOT NULL
);
ALTER TABLE sa.mtm_csc_contact4_csc_admin0 ADD SUPPLEMENTAL LOG GROUP dmtsora1521512333_0 (owner2csc_admin, owner2csc_contact) ALWAYS;