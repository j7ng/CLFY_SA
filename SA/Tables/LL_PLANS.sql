CREATE TABLE sa.ll_plans (
  plan_id NUMBER NOT NULL,
  plan_description VARCHAR2(100 BYTE),
  discount_code VARCHAR2(30 BYTE),
  discount_amount NUMBER,
  max_cards_in_q NUMBER DEFAULT 10,
  min_serv_days_for_discount NUMBER,
  brm_code VARCHAR2(100 BYTE),
  CONSTRAINT pk1_ll_plans PRIMARY KEY (plan_id)
);