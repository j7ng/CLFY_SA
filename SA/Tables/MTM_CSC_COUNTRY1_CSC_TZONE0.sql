CREATE TABLE sa.mtm_csc_country1_csc_tzone0 (
  country2csc_tzone NUMBER(*,0) NOT NULL,
  time2csc_country NUMBER(*,0) NOT NULL
);
ALTER TABLE sa.mtm_csc_country1_csc_tzone0 ADD SUPPLEMENTAL LOG GROUP dmtsora133936034_0 (country2csc_tzone, time2csc_country) ALWAYS;