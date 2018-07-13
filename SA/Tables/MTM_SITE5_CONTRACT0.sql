CREATE TABLE sa.mtm_site5_contract0 (
  cust_loc2contract NUMBER(*,0) NOT NULL,
  contract2site NUMBER(*,0) NOT NULL
);
ALTER TABLE sa.mtm_site5_contract0 ADD SUPPLEMENTAL LOG GROUP dmtsora958864044_0 (contract2site, cust_loc2contract) ALWAYS;