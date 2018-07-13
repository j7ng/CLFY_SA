CREATE TABLE sa.x_napaudit (
  login VARCHAR2(100 BYTE),
  zip VARCHAR2(10 BYTE),
  esn VARCHAR2(20 BYTE),
  action_date DATE
);
ALTER TABLE sa.x_napaudit ADD SUPPLEMENTAL LOG GROUP dmtsora1384304842_0 (action_date, esn, login, zip) ALWAYS;