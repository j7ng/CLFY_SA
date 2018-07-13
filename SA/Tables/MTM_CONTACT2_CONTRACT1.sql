CREATE TABLE sa.mtm_contact2_contract1 (
  caller2contract NUMBER(*,0) NOT NULL,
  contract2contact NUMBER(*,0) NOT NULL
);
ALTER TABLE sa.mtm_contact2_contract1 ADD SUPPLEMENTAL LOG GROUP dmtsora1432990731_0 (caller2contract, contract2contact) ALWAYS;