CREATE TABLE sa.mtm_ll_subs2ll_plans (
  ll_subs_objid NUMBER,
  ll_plan_id NUMBER,
  CONSTRAINT fk1_mtm_ll_subs2ll_plans FOREIGN KEY (ll_subs_objid) REFERENCES sa.ll_subscribers (objid) DISABLE NOVALIDATE,
  CONSTRAINT fk2_mtm_ll_subs2ll_plans FOREIGN KEY (ll_plan_id) REFERENCES sa.ll_plans (plan_id)
);