CREATE TABLE sa.table_x_exchange_zone (
  x_zone VARCHAR2(100 BYTE),
  x_state VARCHAR2(100 BYTE),
  x_technology VARCHAR2(100 BYTE)
);
ALTER TABLE sa.table_x_exchange_zone ADD SUPPLEMENTAL LOG GROUP dmtsora1286158996_0 (x_state, x_technology, x_zone) ALWAYS;