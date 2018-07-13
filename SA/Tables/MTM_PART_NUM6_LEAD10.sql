CREATE TABLE sa.mtm_part_num6_lead10 (
  part_num2lead NUMBER(*,0) NOT NULL,
  lead2part_num NUMBER(*,0) NOT NULL
);
ALTER TABLE sa.mtm_part_num6_lead10 ADD SUPPLEMENTAL LOG GROUP dmtsora259244710_0 (lead2part_num, part_num2lead) ALWAYS;