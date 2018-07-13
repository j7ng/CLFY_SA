CREATE TABLE sa.alt_inv_calcs (
  st VARCHAR2(2 BYTE),
  "ZONE" VARCHAR2(100 BYTE),
  carrier_id FLOAT,
  sum_of_trans NUMBER,
  sum_of_available NUMBER
);
ALTER TABLE sa.alt_inv_calcs ADD SUPPLEMENTAL LOG GROUP dmtsora1833007517_0 (carrier_id, st, sum_of_available, sum_of_trans, "ZONE") ALWAYS;