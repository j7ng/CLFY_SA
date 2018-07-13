CREATE TABLE sa.daily_carrier_act (
  cnt NUMBER,
  x_carrier_id NUMBER,
  x_mkt_submkt_name VARCHAR2(30 BYTE)
);
ALTER TABLE sa.daily_carrier_act ADD SUPPLEMENTAL LOG GROUP dmtsora1455955919_0 (cnt, x_carrier_id, x_mkt_submkt_name) ALWAYS;