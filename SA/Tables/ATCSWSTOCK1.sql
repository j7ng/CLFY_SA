CREATE TABLE sa.atcswstock1 (
  cellular_n VARCHAR2(15 BYTE),
  status_a VARCHAR2(26 BYTE)
);
ALTER TABLE sa.atcswstock1 ADD SUPPLEMENTAL LOG GROUP dmtsora186818086_0 (cellular_n, status_a) ALWAYS;