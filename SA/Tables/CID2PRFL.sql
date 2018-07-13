CREATE TABLE sa.cid2prfl (
  x_carrier_id NUMBER,
  x_default_queue VARCHAR2(30 BYTE)
);
ALTER TABLE sa.cid2prfl ADD SUPPLEMENTAL LOG GROUP dmtsora1443767048_0 (x_carrier_id, x_default_queue) ALWAYS;