CREATE TABLE sa.mtm_group5_monitor4 (
  grpsupvr_accs2monitor NUMBER(*,0) NOT NULL,
  groupsuper2group NUMBER(*,0) NOT NULL
);
ALTER TABLE sa.mtm_group5_monitor4 ADD SUPPLEMENTAL LOG GROUP dmtsora1875598743_0 (groupsuper2group, grpsupvr_accs2monitor) ALWAYS;