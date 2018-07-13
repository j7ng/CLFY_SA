CREATE TABLE sa.x_nonusage_esns (
  x_esn VARCHAR2(20 BYTE),
  x_exp_deact_date DATE,
  x_last_redemp_date DATE,
  x_last_call_date DATE,
  x_deact_type VARCHAR2(20 BYTE),
  x_product_line VARCHAR2(20 BYTE),
  x_membership_name VARCHAR2(50 BYTE),
  x_purpose VARCHAR2(50 BYTE),
  x_toss_cust_id VARCHAR2(20 BYTE),
  x_carrier_id NUMBER,
  x_toss_deact_date DATE,
  x_deact_flag NUMBER,
  x_rundate DATE,
  x_load_date DATE
);
COMMENT ON TABLE sa.x_nonusage_esns IS 'Deactivation Request Table, based on inactivity of the service.';
COMMENT ON COLUMN sa.x_nonusage_esns.x_esn IS 'Phone Serial Number';
COMMENT ON COLUMN sa.x_nonusage_esns.x_exp_deact_date IS 'Expected Deactivation Date';
COMMENT ON COLUMN sa.x_nonusage_esns.x_last_redemp_date IS 'Last Redemption Date';
COMMENT ON COLUMN sa.x_nonusage_esns.x_last_call_date IS 'Last Call Date';
COMMENT ON COLUMN sa.x_nonusage_esns.x_deact_type IS 'Requested Deactivation Type';
COMMENT ON COLUMN sa.x_nonusage_esns.x_product_line IS 'Product Line, Also known as brand.';
COMMENT ON COLUMN sa.x_nonusage_esns.x_membership_name IS 'Type of service: PAGO, Unlimited, etc.';
COMMENT ON COLUMN sa.x_nonusage_esns.x_purpose IS 'Transaction Type Description: DEACTIVATION';
COMMENT ON COLUMN sa.x_nonusage_esns.x_toss_cust_id IS 'Reference to x_cust_id field in table_contact';
COMMENT ON COLUMN sa.x_nonusage_esns.x_carrier_id IS 'Reference to x_carrier_id in table_x_carrier';
COMMENT ON COLUMN sa.x_nonusage_esns.x_toss_deact_date IS 'Service Deactivation Date';
COMMENT ON COLUMN sa.x_nonusage_esns.x_deact_flag IS 'Flag required by seactivation service, provided by the deactivation reason.';
COMMENT ON COLUMN sa.x_nonusage_esns.x_rundate IS 'Deactivation Job Run Date';
COMMENT ON COLUMN sa.x_nonusage_esns.x_load_date IS 'Record creation date.';