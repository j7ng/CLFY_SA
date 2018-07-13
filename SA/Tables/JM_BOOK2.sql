CREATE TABLE sa.jm_book2 (
  cellular_n VARCHAR2(15 BYTE)
);
ALTER TABLE sa.jm_book2 ADD SUPPLEMENTAL LOG GROUP dmtsora684027459_0 (cellular_n) ALWAYS;