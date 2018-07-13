CREATE TABLE sa.x_daily_click_plan_fix (
  duggi_sp_objid NUMBER,
  plan_hist2click_plan NUMBER
);
ALTER TABLE sa.x_daily_click_plan_fix ADD SUPPLEMENTAL LOG GROUP dmtsora337004044_0 (duggi_sp_objid, plan_hist2click_plan) ALWAYS;