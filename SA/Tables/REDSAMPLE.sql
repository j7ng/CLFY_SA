CREATE TABLE sa.redsample (
  esnnum VARCHAR2(254 BYTE),
  reddate DATE
);
ALTER TABLE sa.redsample ADD SUPPLEMENTAL LOG GROUP dmtsora798192929_0 (esnnum, reddate) ALWAYS;