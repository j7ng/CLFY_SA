CREATE TABLE sa.scrub180 (
  esn VARCHAR2(30 BYTE),
  e_mail VARCHAR2(80 BYTE)
);
ALTER TABLE sa.scrub180 ADD SUPPLEMENTAL LOG GROUP dmtsora720442159_0 (esn, e_mail) ALWAYS;