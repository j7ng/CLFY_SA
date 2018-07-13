CREATE TABLE sa.test_carr (
  carrier_id NUMBER,
  script_type VARCHAR2(20 BYTE)
);
ALTER TABLE sa.test_carr ADD SUPPLEMENTAL LOG GROUP dmtsora1857238474_0 (carrier_id, script_type) ALWAYS;