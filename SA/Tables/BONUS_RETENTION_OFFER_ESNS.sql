CREATE TABLE sa.bonus_retention_offer_esns (
  esn VARCHAR2(30 BYTE),
  bonus_offer VARCHAR2(100 BYTE),
  enroll_yn CHAR,
  enroll_dt DATE
);
ALTER TABLE sa.bonus_retention_offer_esns ADD SUPPLEMENTAL LOG GROUP dmtsora446471048_0 (bonus_offer, enroll_dt, enroll_yn, esn) ALWAYS;