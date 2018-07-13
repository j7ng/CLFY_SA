CREATE TABLE sa.rpt_total_lines1 (
  npa VARCHAR2(3 BYTE),
  nxx VARCHAR2(3 BYTE),
  carrier_id NUMBER,
  carrier_name VARCHAR2(100 BYTE),
  "ACTIVE" NUMBER DEFAULT 0,
  used NUMBER DEFAULT 0,
  "NEW" NUMBER DEFAULT 0,
  usedhold NUMBER DEFAULT 0,
  newhold NUMBER DEFAULT 0
);
ALTER TABLE sa.rpt_total_lines1 ADD SUPPLEMENTAL LOG GROUP dmtsora1622492544_0 ("ACTIVE", carrier_id, carrier_name, "NEW", newhold, npa, nxx, used, usedhold) ALWAYS;