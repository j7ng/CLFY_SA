CREATE TABLE sa.test_sr (
  table_name VARCHAR2(300 BYTE)
);
ALTER TABLE sa.test_sr ADD SUPPLEMENTAL LOG GROUP dmtsora1169906596_0 (table_name) ALWAYS;