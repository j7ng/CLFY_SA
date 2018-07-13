CREATE TABLE sa.mtm_x79country1_x79tzone0 (
  country2x79tzone NUMBER(*,0) NOT NULL,
  time2x79country NUMBER(*,0) NOT NULL
);
ALTER TABLE sa.mtm_x79country1_x79tzone0 ADD SUPPLEMENTAL LOG GROUP dmtsora400196537_0 (country2x79tzone, time2x79country) ALWAYS;