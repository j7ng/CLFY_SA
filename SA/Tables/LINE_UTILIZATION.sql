CREATE TABLE sa.line_utilization (
  "STATE" VARCHAR2(4 BYTE),
  "ZONE" VARCHAR2(100 BYTE),
  marketid FLOAT,
  mrkt_area VARCHAR2(33 BYTE),
  carrier_id FLOAT,
  carrier_name VARCHAR2(255 BYTE),
  "SID" VARCHAR2(10 BYTE),
  av_activations NUMBER,
  max_activations NUMBER
);