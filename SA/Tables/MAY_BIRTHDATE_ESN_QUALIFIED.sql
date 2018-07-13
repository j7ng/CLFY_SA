CREATE TABLE sa.may_birthdate_esn_qualified (
  esn VARCHAR2(30 BYTE)
);
ALTER TABLE sa.may_birthdate_esn_qualified ADD SUPPLEMENTAL LOG GROUP dmtsora1705357242_0 (esn) ALWAYS;