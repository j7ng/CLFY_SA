CREATE TABLE sa.mtm_contact46_x_credit_card3 (
  mtm_contact2x_credit_card NUMBER(*,0) NOT NULL,
  mtm_credit_card2contact NUMBER(*,0) NOT NULL
);
ALTER TABLE sa.mtm_contact46_x_credit_card3 ADD SUPPLEMENTAL LOG GROUP dmtsora1940976421_0 (mtm_contact2x_credit_card, mtm_credit_card2contact) ALWAYS;
COMMENT ON TABLE sa.mtm_contact46_x_credit_card3 IS 'Many to many relation between contacts and credit cards';
COMMENT ON COLUMN sa.mtm_contact46_x_credit_card3.mtm_contact2x_credit_card IS 'Reference to objid of table table_contact';
COMMENT ON COLUMN sa.mtm_contact46_x_credit_card3.mtm_credit_card2contact IS 'MTM relation from credit card to contact';