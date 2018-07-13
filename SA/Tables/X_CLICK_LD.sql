CREATE TABLE sa.x_click_ld (
  active_on DATE,
  carrier_name VARCHAR2(100 BYTE),
  click_plan1 NUMBER,
  click_plan1_5 NUMBER,
  cnt NUMBER
);
ALTER TABLE sa.x_click_ld ADD SUPPLEMENTAL LOG GROUP dmtsora1122714648_0 (active_on, carrier_name, click_plan1, click_plan1_5, cnt) ALWAYS;