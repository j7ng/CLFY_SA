CREATE TABLE sa.mtm_price_factor0_price_inst3 (
  eligibility2price_inst NUMBER(*,0) NOT NULL,
  eligibility2price_factor NUMBER(*,0) NOT NULL
);
ALTER TABLE sa.mtm_price_factor0_price_inst3 ADD SUPPLEMENTAL LOG GROUP dmtsora1390884996_0 (eligibility2price_factor, eligibility2price_inst) ALWAYS;