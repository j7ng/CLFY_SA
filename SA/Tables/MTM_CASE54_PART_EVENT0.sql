CREATE TABLE sa.mtm_case54_part_event0 (
  case2part_event NUMBER(*,0) NOT NULL,
  part_event2case NUMBER(*,0) NOT NULL
);
ALTER TABLE sa.mtm_case54_part_event0 ADD SUPPLEMENTAL LOG GROUP dmtsora487382917_0 (case2part_event, part_event2case) ALWAYS;