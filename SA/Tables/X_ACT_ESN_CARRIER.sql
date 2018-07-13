CREATE TABLE sa.x_act_esn_carrier (
  active_on DATE,
  carrier_name VARCHAR2(30 BYTE),
  click_plan2 NUMBER,
  click_plan3 NUMBER,
  click_plan4 NUMBER,
  click_plan9_9 NUMBER,
  cnt NUMBER
);
ALTER TABLE sa.x_act_esn_carrier ADD SUPPLEMENTAL LOG GROUP dmtsora639226599_0 (active_on, carrier_name, click_plan2, click_plan3, click_plan4, click_plan9_9, cnt) ALWAYS;