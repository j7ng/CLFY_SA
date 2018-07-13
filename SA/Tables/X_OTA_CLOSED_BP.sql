CREATE TABLE sa.x_ota_closed_bp (
  x_esn VARCHAR2(30 BYTE) NOT NULL,
  x_min VARCHAR2(30 BYTE) NOT NULL,
  x_ota_call_trans NUMBER,
  x_trans_date DATE,
  x_closed_date DATE,
  x_mode VARCHAR2(50 BYTE)
);
ALTER TABLE sa.x_ota_closed_bp ADD SUPPLEMENTAL LOG GROUP dmtsora327731416_0 (x_closed_date, x_esn, x_min, x_mode, x_ota_call_trans, x_trans_date) ALWAYS;
COMMENT ON TABLE sa.x_ota_closed_bp IS 'Batch Closing of OTA Transactions';
COMMENT ON COLUMN sa.x_ota_closed_bp.x_esn IS 'Phone Serial Number';
COMMENT ON COLUMN sa.x_ota_closed_bp.x_min IS 'Phone Number';
COMMENT ON COLUMN sa.x_ota_closed_bp.x_ota_call_trans IS 'Reference to objid in table_x_call_trans';
COMMENT ON COLUMN sa.x_ota_closed_bp.x_trans_date IS 'Transaction Date';
COMMENT ON COLUMN sa.x_ota_closed_bp.x_closed_date IS 'Close Date';
COMMENT ON COLUMN sa.x_ota_closed_bp.x_mode IS 'Mode/Process';