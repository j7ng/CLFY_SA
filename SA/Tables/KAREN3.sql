CREATE TABLE sa.karen3 (
  esn VARCHAR2(30 BYTE),
  cellnum VARCHAR2(30 BYTE),
  activation_date DATE
);
ALTER TABLE sa.karen3 ADD SUPPLEMENTAL LOG GROUP dmtsora1024470720_0 (activation_date, cellnum, esn) ALWAYS;