CREATE TABLE sa.mtm_time_bomb3_variable0 (
  parameters2variable NUMBER(*,0) NOT NULL,
  parent2time_bomb NUMBER(*,0) NOT NULL
);
ALTER TABLE sa.mtm_time_bomb3_variable0 ADD SUPPLEMENTAL LOG GROUP dmtsora1626504175_0 (parameters2variable, parent2time_bomb) ALWAYS;