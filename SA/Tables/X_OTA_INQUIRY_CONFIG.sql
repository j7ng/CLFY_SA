CREATE TABLE sa.x_ota_inquiry_config (
  x_min VARCHAR2(30 BYTE),
  x_carrier_name VARCHAR2(30 BYTE),
  x_time_interval NUMBER,
  x_history_days NUMBER,
  x_inquiry_message VARCHAR2(255 BYTE)
);
ALTER TABLE sa.x_ota_inquiry_config ADD SUPPLEMENTAL LOG GROUP dmtsora111824187_0 (x_carrier_name, x_history_days, x_inquiry_message, x_min, x_time_interval) ALWAYS;