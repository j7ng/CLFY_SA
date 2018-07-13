CREATE TABLE sa.x_billing_code_table (
  objid NUMBER,
  x_code_type VARCHAR2(50 BYTE),
  x_code VARCHAR2(50 BYTE),
  x_code_desc VARCHAR2(1000 BYTE),
  x_update_stamp DATE,
  x_update_status VARCHAR2(1 BYTE),
  x_update_user VARCHAR2(255 BYTE)
);
ALTER TABLE sa.x_billing_code_table ADD SUPPLEMENTAL LOG GROUP dmtsora1252296456_0 (objid, x_code, x_code_desc, x_code_type, x_update_stamp, x_update_status, x_update_user) ALWAYS;
COMMENT ON TABLE sa.x_billing_code_table IS 'Billing Code Definitions Table, different processes and functions for billing application have their codes defined in this table.';
COMMENT ON COLUMN sa.x_billing_code_table.objid IS 'Internal Record ID';
COMMENT ON COLUMN sa.x_billing_code_table.x_code_type IS 'Type of Billing Code';
COMMENT ON COLUMN sa.x_billing_code_table.x_code IS 'Billing Code Number';
COMMENT ON COLUMN sa.x_billing_code_table.x_code_desc IS 'Code Description';
COMMENT ON COLUMN sa.x_billing_code_table.x_update_stamp IS 'Update Timestamp';
COMMENT ON COLUMN sa.x_billing_code_table.x_update_status IS 'Update Status';
COMMENT ON COLUMN sa.x_billing_code_table.x_update_user IS 'Updated By';