CREATE TABLE sa.x_payload_error_log (
  esn VARCHAR2(30 BYTE),
  "MIN" VARCHAR2(30 BYTE),
  event_name VARCHAR2(30 BYTE),
  error_text VARCHAR2(4000 BYTE),
  insert_timestamp DATE DEFAULT SYSDATE,
  queue_message sa.q_payload_t
);