CREATE TABLE sa.x_ivr_sla_mgmt (
  objid NUMBER NOT NULL,
  "ACTION" VARCHAR2(50 BYTE),
  status VARCHAR2(50 BYTE),
  log_time DATE,
  order_number VARCHAR2(50 BYTE),
  status_message VARCHAR2(200 BYTE),
  fulfillment_type VARCHAR2(50 BYTE),
  pin VARCHAR2(50 BYTE),
  esn VARCHAR2(50 BYTE),
  "MIN" VARCHAR2(50 BYTE),
  service_id VARCHAR2(50 BYTE),
  call_trans_objid VARCHAR2(50 BYTE),
  "KEY" VARCHAR2(50 BYTE),
  "VALUE" VARCHAR2(50 BYTE),
  order_line_number VARCHAR2(100 BYTE),
  title_of_ticket VARCHAR2(50 BYTE),
  issue VARCHAR2(1000 BYTE),
  source_system VARCHAR2(50 BYTE),
  brand_name VARCHAR2(50 BYTE),
  type_of_issue VARCHAR2(50 BYTE),
  payment_source_id VARCHAR2(50 BYTE),
  fulfilling_part VARCHAR2(50 BYTE),
  ticket_note VARCHAR2(50 BYTE),
  CONSTRAINT pk_x_ivr_sla_mgmt PRIMARY KEY (objid)
);