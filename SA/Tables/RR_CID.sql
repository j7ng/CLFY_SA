CREATE TABLE sa.rr_cid (
  x_carrier_id NUMBER,
  x_transmit_template VARCHAR2(30 BYTE)
);
ALTER TABLE sa.rr_cid ADD SUPPLEMENTAL LOG GROUP dmtsora1678446205_0 (x_carrier_id, x_transmit_template) ALWAYS;