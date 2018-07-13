CREATE TABLE sa.x_carrier_system (
  carrier_id NUMBER,
  parent_name VARCHAR2(40 BYTE),
  carrier_name VARCHAR2(40 BYTE),
  carrier_market_name VARCHAR2(30 BYTE),
  "METHOD" VARCHAR2(30 BYTE),
  "TEMPLATE" VARCHAR2(30 BYTE),
  "SYSTEM" VARCHAR2(30 BYTE)
);
ALTER TABLE sa.x_carrier_system ADD SUPPLEMENTAL LOG GROUP dmtsora1567981991_0 (carrier_id, carrier_market_name, carrier_name, "METHOD", parent_name, "SYSTEM", "TEMPLATE") ALWAYS;