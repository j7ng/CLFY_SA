CREATE TABLE sa.x_click_change_log (
  site_part NUMBER,
  esn VARCHAR2(30 BYTE),
  cellnum VARCHAR2(15 BYTE),
  zipcode VARCHAR2(10 BYTE),
  dealer_id VARCHAR2(30 BYTE),
  dealer_name VARCHAR2(255 BYTE),
  click_change2x_plan NUMBER,
  click_change_date DATE,
  agent VARCHAR2(30 BYTE)
);
ALTER TABLE sa.x_click_change_log ADD SUPPLEMENTAL LOG GROUP dmtsora1524442624_0 (agent, cellnum, click_change2x_plan, click_change_date, dealer_id, dealer_name, esn, site_part, zipcode) ALWAYS;