CREATE OR REPLACE TYPE sa."ESN_MIN_STATUS_DET_TYPE" FORCE  AS object (
  esn                       VARCHAR2(30),
  min                       VARCHAR2(30),
  esn_part_inst_status      VARCHAR2(20),
  service_plan_objid        NUMBER      ,
  remaining_Service_days    NUMBER      ,
  response                  VARCHAR2(1000),
  service_end_date          DATE          ,
  transaction_pending       VARCHAR2(30)
  );
/