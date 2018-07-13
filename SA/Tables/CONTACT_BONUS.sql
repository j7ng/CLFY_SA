CREATE TABLE sa.contact_bonus (
  esn VARCHAR2(20 BYTE),
  enroll_yn VARCHAR2(20 BYTE),
  enroll_date DATE
);
ALTER TABLE sa.contact_bonus ADD SUPPLEMENTAL LOG GROUP dmtsora1755953435_0 (enroll_date, enroll_yn, esn) ALWAYS;