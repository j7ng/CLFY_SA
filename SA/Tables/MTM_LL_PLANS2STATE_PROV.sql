CREATE TABLE sa.mtm_ll_plans2state_prov (
  plan_id NUMBER,
  state_code VARCHAR2(40 BYTE),
  CONSTRAINT fk1_mtm_ll_plans2state_prov FOREIGN KEY (plan_id) REFERENCES sa.ll_plans (plan_id)
);