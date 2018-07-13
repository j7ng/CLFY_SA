CREATE TABLE sa.rpt_flash (
  dealer_id NUMBER,
  dealer_name VARCHAR2(100 BYTE),
  activations NUMBER,
  reactivations NUMBER,
  redemption_units NUMBER,
  redemption_count NUMBER
);
ALTER TABLE sa.rpt_flash ADD SUPPLEMENTAL LOG GROUP dmtsora1338002944_0 (activations, dealer_id, dealer_name, reactivations, redemption_count, redemption_units) ALWAYS;