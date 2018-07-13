CREATE TABLE sa.zip2tech_final (
  zip VARCHAR2(5 BYTE),
  x_act_analog NUMBER,
  x_act_technology VARCHAR2(20 BYTE)
);
ALTER TABLE sa.zip2tech_final ADD SUPPLEMENTAL LOG GROUP dmtsora1246933814_0 (x_act_analog, x_act_technology, zip) ALWAYS;