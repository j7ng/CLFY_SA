CREATE TABLE sa.mtm_subcase21_monitor7 (
  subc_view2monitor NUMBER(*,0) NOT NULL,
  monitor2subcase NUMBER(*,0) NOT NULL
);
ALTER TABLE sa.mtm_subcase21_monitor7 ADD SUPPLEMENTAL LOG GROUP dmtsora878895928_0 (monitor2subcase, subc_view2monitor) ALWAYS;