CREATE TABLE sa.annual_plan_members (
  esn VARCHAR2(30 BYTE),
  technology VARCHAR2(20 BYTE),
  x_start_date DATE,
  x_end_date DATE,
  active_flag NUMBER
);
ALTER TABLE sa.annual_plan_members ADD SUPPLEMENTAL LOG GROUP dmtsora103088170_0 (active_flag, esn, technology, x_end_date, x_start_date) ALWAYS;