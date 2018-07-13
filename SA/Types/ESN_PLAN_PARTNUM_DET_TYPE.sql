CREATE OR REPLACE TYPE sa."ESN_PLAN_PARTNUM_DET_TYPE" FORCE  AS object (
  esn                       VARCHAR2(30),
  plan_purchase_part_number VARCHAR2(50),
  service_plan_objid        NUMBER,
  service_plan_name         VARCHAR2(50),
  esn_part_inst_objid       NUMBER      ,
  plan_part_class           VARCHAR2(40),
  service_plan_group           VARCHAR2(50) ,
  error_code                   VARCHAR2(50) ,
  error_message                VARCHAR2(1000)
  );
/