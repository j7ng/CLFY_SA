CREATE TABLE sa.zip2carrier (
  zip VARCHAR2(9 BYTE),
  st VARCHAR2(9 BYTE),
  carrier VARCHAR2(23 BYTE),
  flag NUMBER(1)
);
ALTER TABLE sa.zip2carrier ADD SUPPLEMENTAL LOG GROUP dmtsora231239940_0 (carrier, flag, st, zip) ALWAYS;