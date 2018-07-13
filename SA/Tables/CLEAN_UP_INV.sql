CREATE TABLE sa.clean_up_inv (
  card_smp VARCHAR2(30 BYTE),
  redemption_date DATE
);
ALTER TABLE sa.clean_up_inv ADD SUPPLEMENTAL LOG GROUP dmtsora1784210309_0 (card_smp, redemption_date) ALWAYS;