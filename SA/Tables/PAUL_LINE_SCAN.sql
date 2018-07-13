CREATE TABLE sa.paul_line_scan (
  npa VARCHAR2(10 BYTE),
  nxx VARCHAR2(10 BYTE),
  carrier_id NUMBER,
  carrier_name VARCHAR2(30 BYTE),
  "SID" VARCHAR2(10 BYTE),
  available NUMBER
);
ALTER TABLE sa.paul_line_scan ADD SUPPLEMENTAL LOG GROUP dmtsora1652475190_0 (available, carrier_id, carrier_name, npa, nxx, "SID") ALWAYS;