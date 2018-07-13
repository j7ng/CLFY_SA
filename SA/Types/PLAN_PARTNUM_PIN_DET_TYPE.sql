CREATE OR REPLACE TYPE sa."PLAN_PARTNUM_PIN_DET_TYPE" FORCE  AS object (
  esn                       VARCHAR2(30),
  min                       VARCHAR2(30),
  plan_part_number          VARCHAR2(50),
  part_number_quantity      NUMBER      ,
  service_plan_objid        NUMBER      ,
  service_plan_name         VARCHAR2(50),
  service_plan_group        VARCHAR2(50),
  pin_list                  pin_smp_tab,
  smp_list                  pin_smp_tab,
  response                  VARCHAR2(1000)
  );
/