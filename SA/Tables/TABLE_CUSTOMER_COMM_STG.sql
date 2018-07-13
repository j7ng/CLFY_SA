CREATE TABLE sa.table_customer_comm_stg (
  objid NUMBER(22) NOT NULL,
  esn VARCHAR2(30 BYTE),
  "MIN" VARCHAR2(30 BYTE),
  brand VARCHAR2(50 BYTE),
  sms_message VARCHAR2(4000 BYTE),
  source_system VARCHAR2(50 BYTE),
  status VARCHAR2(1 BYTE),
  error_message VARCHAR2(4000 BYTE),
  retry_count NUMBER DEFAULT 0,
  insert_timestamp DATE,
  update_timestamp DATE,
  schedule_timestamp DATE,
  PRIMARY KEY (objid)
);