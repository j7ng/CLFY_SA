CREATE TABLE sa.x_ota_admin_resend (
  x_ota_trans_id NUMBER,
  batch_id NUMBER,
  status VARCHAR2(30 BYTE)
);
ALTER TABLE sa.x_ota_admin_resend ADD SUPPLEMENTAL LOG GROUP dmtsora1619924021_0 (batch_id, status, x_ota_trans_id) ALWAYS;