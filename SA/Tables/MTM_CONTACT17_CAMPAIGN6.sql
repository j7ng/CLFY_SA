CREATE TABLE sa.mtm_contact17_campaign6 (
  contact2campaign NUMBER(*,0) NOT NULL,
  campaign2contact NUMBER(*,0) NOT NULL
);
ALTER TABLE sa.mtm_contact17_campaign6 ADD SUPPLEMENTAL LOG GROUP dmtsora1110099548_0 (campaign2contact, contact2campaign) ALWAYS;