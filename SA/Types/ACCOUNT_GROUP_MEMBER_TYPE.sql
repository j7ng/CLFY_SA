CREATE OR REPLACE TYPE sa.account_group_member_type IS OBJECT
(
  account_group_id             NUMBER(22)     ,
  account_group_name           VARCHAR2(50)   ,
  master_esn                   VARCHAR2(30)   ,
  service_plan_id              NUMBER(22)     ,
  service_plan_feature_date    DATE           ,
  program_enrolled_id          NUMBER(22)     ,
  account_group_status         VARCHAR2(30)   ,
  account_group_start_date     DATE           ,
  account_group_end_date       DATE           ,
  member_id                    NUMBER(22)     ,
  esn                          VARCHAR2(30)   ,
  member_order                 NUMBER(2)      ,
  site_part_id                 NUMBER(22)     ,
  promotion_id                 NUMBER(22)     ,
  member_status                VARCHAR2(30)   ,
  subscriber_uid               VARCHAR2(50)   ,
  program_param_id             NUMBER(22)     ,
  member_start_date            DATE           ,
  member_end_date              DATE           ,
  service_end_date             DATE           , -- CR50270
  next_refill_date             DATE             -- CR50270
  );
/