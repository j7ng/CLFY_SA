CREATE TABLE sa.draggo_17000 (
  esn CHAR(11 BYTE),
  act_date DATE,
  deact_date DATE,
  status VARCHAR2(15 BYTE),
  month1_red NUMBER(10),
  month1_usage NUMBER(10),
  month2_red NUMBER(10),
  month2_usage NUMBER(10),
  month3_red NUMBER(10),
  month3_usage NUMBER(10),
  month4_red NUMBER(10),
  month4_usage NUMBER(10),
  month5_red NUMBER(10),
  month5_usage NUMBER(10),
  month6_red NUMBER(10),
  month6_usage NUMBER(10),
  month7_red NUMBER(10),
  month7_usage NUMBER(10),
  month8_red NUMBER(10),
  month8_usage NUMBER(10),
  month9_red NUMBER(10),
  month9_usage NUMBER(10),
  month10_red NUMBER(10),
  month10_usage NUMBER(10),
  month11_red NUMBER(10),
  month11_usage NUMBER(10),
  month12_red NUMBER(10),
  month12_usage NUMBER(10),
  month13_red NUMBER(10),
  month13_usage NUMBER(10),
  month14_red NUMBER(10),
  month14_usage NUMBER(10),
  month15_red NUMBER(10),
  month15_usage NUMBER(10)
);
ALTER TABLE sa.draggo_17000 ADD SUPPLEMENTAL LOG GROUP dmtsora1540668806_1 (month15_usage) ALWAYS;
ALTER TABLE sa.draggo_17000 ADD SUPPLEMENTAL LOG GROUP dmtsora1540668806_0 (act_date, deact_date, esn, month10_red, month10_usage, month11_red, month11_usage, month12_red, month12_usage, month13_red, month13_usage, month14_red, month14_usage, month15_red, month1_red, month1_usage, month2_red, month2_usage, month3_red, month3_usage, month4_red, month4_usage, month5_red, month5_usage, month6_red, month6_usage, month7_red, month7_usage, month8_red, month8_usage, month9_red, month9_usage, status) ALWAYS;