CREATE TABLE sa.mtm_probdesc11_monitor8 (
  probdesc_view2monitor NUMBER(*,0) NOT NULL,
  monitor2probdesc NUMBER(*,0) NOT NULL
);
ALTER TABLE sa.mtm_probdesc11_monitor8 ADD SUPPLEMENTAL LOG GROUP dmtsora524809518_0 (monitor2probdesc, probdesc_view2monitor) ALWAYS;