CREATE TABLE sa.x_valid_npa_nxx (
  npanxx VARCHAR2(6 BYTE)
);
ALTER TABLE sa.x_valid_npa_nxx ADD SUPPLEMENTAL LOG GROUP dmtsora989973860_0 (npanxx) ALWAYS;