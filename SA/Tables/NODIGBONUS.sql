CREATE TABLE sa.nodigbonus (
  esn VARCHAR2(14 BYTE),
  bonus_unit VARCHAR2(14 BYTE),
  card_redee VARCHAR2(14 BYTE),
  phone VARCHAR2(14 BYTE),
  email VARCHAR2(14 BYTE),
  firstname VARCHAR2(22 BYTE),
  lastname VARCHAR2(14 BYTE)
);
ALTER TABLE sa.nodigbonus ADD SUPPLEMENTAL LOG GROUP dmtsora1989012678_0 (bonus_unit, card_redee, email, esn, firstname, lastname, phone) ALWAYS;