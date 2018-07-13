CREATE TABLE sa.mtm_ll_plans2serv_plan (
  ll_plan_id NUMBER,
  sp_objid NUMBER,
  CONSTRAINT fk1_mtm_ll_plans2serv_plan FOREIGN KEY (ll_plan_id) REFERENCES sa.ll_plans (plan_id)
);