CREATE TABLE sa.flash2 (
  dealer_id NUMBER,
  dealer_name VARCHAR2(100 BYTE),
  activations NUMBER,
  reactivations NUMBER,
  redemption_units NUMBER,
  redemption_count NUMBER
);
ALTER TABLE sa.flash2 ADD SUPPLEMENTAL LOG GROUP dmtsora359284668_0 (activations, dealer_id, dealer_name, reactivations, redemption_count, redemption_units) ALWAYS;