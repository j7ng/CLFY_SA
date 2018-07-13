CREATE TABLE sa.table_x_click_plan_hist_err (
  objid NUMBER(38),
  curr_hist2site_part NUMBER(38),
  x_start_date DATE,
  plan_hist2click_plan NUMBER(38),
  error_text VARCHAR2(2000 BYTE)
);
ALTER TABLE sa.table_x_click_plan_hist_err ADD SUPPLEMENTAL LOG GROUP dmtsora1140286133_0 (curr_hist2site_part, error_text, objid, plan_hist2click_plan, x_start_date) ALWAYS;