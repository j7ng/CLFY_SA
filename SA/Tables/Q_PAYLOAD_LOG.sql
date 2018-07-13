CREATE TABLE sa.q_payload_log (
  esn VARCHAR2(30 BYTE),
  "MIN" VARCHAR2(30 BYTE),
  brand VARCHAR2(30 BYTE),
  event_name VARCHAR2(100 BYTE),
  creation_date DATE DEFAULT SYSDATE,
  created_by VARCHAR2(50 BYTE)
);