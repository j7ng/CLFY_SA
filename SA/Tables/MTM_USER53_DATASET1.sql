CREATE TABLE sa.mtm_user53_dataset1 (
  user2dataset NUMBER(*,0) NOT NULL,
  dataset2user NUMBER(*,0) NOT NULL
);
ALTER TABLE sa.mtm_user53_dataset1 ADD SUPPLEMENTAL LOG GROUP dmtsora1144460735_0 (dataset2user, user2dataset) ALWAYS;