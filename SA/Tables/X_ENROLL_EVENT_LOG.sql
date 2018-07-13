CREATE TABLE sa.x_enroll_event_log (
  x_esn VARCHAR2(30 BYTE),
  event_send_status VARCHAR2(3 BYTE),
  event_generate_date TIMESTAMP,
  event sa.q_payload_t
);