CREATE TABLE sa.atcswstock2 (
  airtouch_a VARCHAR2(10 BYTE),
  cellular_n VARCHAR2(15 BYTE),
  status VARCHAR2(27 BYTE)
);
ALTER TABLE sa.atcswstock2 ADD SUPPLEMENTAL LOG GROUP dmtsora2010050722_0 (airtouch_a, cellular_n, status) ALWAYS;