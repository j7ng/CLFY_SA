CREATE TABLE sa.x_chargeback_trans (
  objid NUMBER,
  x_actv_date DATE,
  x_file_name VARCHAR2(255 BYTE),
  x_last_update DATE,
  x_status VARCHAR2(30 BYTE)
);
ALTER TABLE sa.x_chargeback_trans ADD SUPPLEMENTAL LOG GROUP dmtsora1595679334_0 (objid, x_actv_date, x_file_name, x_last_update, x_status) ALWAYS;
COMMENT ON TABLE sa.x_chargeback_trans IS 'Header Billing Chargeback Transactions';
COMMENT ON COLUMN sa.x_chargeback_trans.objid IS 'Internal Record ID
';
COMMENT ON COLUMN sa.x_chargeback_trans.x_actv_date IS 'Activity Date';
COMMENT ON COLUMN sa.x_chargeback_trans.x_file_name IS 'File Name';
COMMENT ON COLUMN sa.x_chargeback_trans.x_last_update IS 'last Update';
COMMENT ON COLUMN sa.x_chargeback_trans.x_status IS 'Status';