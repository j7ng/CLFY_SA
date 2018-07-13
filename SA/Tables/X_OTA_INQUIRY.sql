CREATE TABLE sa.x_ota_inquiry (
  x_min VARCHAR2(30 BYTE),
  x_trans_id NUMBER,
  x_sent_date DATE,
  x_received_date DATE,
  x_ack_text VARCHAR2(255 BYTE),
  x_status VARCHAR2(60 BYTE)
);
ALTER TABLE sa.x_ota_inquiry ADD SUPPLEMENTAL LOG GROUP dmtsora153326895_0 (x_ack_text, x_min, x_received_date, x_sent_date, x_status, x_trans_id) ALWAYS;