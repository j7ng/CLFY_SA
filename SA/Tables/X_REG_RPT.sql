CREATE TABLE sa.x_reg_rpt (
  reg_date DATE,
  flash_dealer VARCHAR2(80 BYTE),
  region VARCHAR2(40 BYTE),
  red_act NUMBER,
  red_cs NUMBER,
  red_free NUMBER,
  red_paid NUMBER,
  red_rp NUMBER,
  act NUMBER,
  react NUMBER,
  curr_act NUMBER
);
ALTER TABLE sa.x_reg_rpt ADD SUPPLEMENTAL LOG GROUP dmtsora1881514215_0 (act, curr_act, flash_dealer, react, red_act, red_cs, red_free, red_paid, red_rp, region, reg_date) ALWAYS;