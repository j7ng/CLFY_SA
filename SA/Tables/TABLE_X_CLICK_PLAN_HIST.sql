CREATE TABLE sa.table_x_click_plan_hist (
  objid NUMBER,
  curr_hist2site_part NUMBER,
  plan_hist2site_part NUMBER,
  x_end_date DATE,
  x_start_date DATE,
  plan_hist2click_plan NUMBER
);
ALTER TABLE sa.table_x_click_plan_hist ADD SUPPLEMENTAL LOG GROUP dmtsora1003887795_0 (curr_hist2site_part, objid, plan_hist2click_plan, plan_hist2site_part, x_end_date, x_start_date) ALWAYS;