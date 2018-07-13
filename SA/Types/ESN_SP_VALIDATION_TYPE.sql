CREATE OR REPLACE TYPE sa.esn_sp_validation_type IS OBJECT
(
  msgnum                        VARCHAR2(1000),
  msgstr                        VARCHAR2(1000),
  available_capacity            NUMBER(2),
  number_of_lines               NUMBER(3),
  service_plan_id               NUMBER(22),
  payment_pending_group_id      NUMBER(22),
  program_enrolled_id           NUMBER(22)
);
/