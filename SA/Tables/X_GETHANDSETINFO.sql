CREATE TABLE sa.x_gethandsetinfo (
  objid NUMBER,
  x_order NUMBER,
  x_plan_type VARCHAR2(30 BYTE),
  x_due_date VARCHAR2(30 BYTE),
  x_triple_minutes VARCHAR2(30 BYTE),
  x_safelink VARCHAR2(30 BYTE),
  x_brand VARCHAR2(30 BYTE),
  x_account_id VARCHAR2(30 BYTE),
  x_redeem_in_last_90_days VARCHAR2(30 BYTE),
  x_balance NUMBER,
  x_balance_type VARCHAR2(30 BYTE),
  x_auto_refill VARCHAR2(30 BYTE),
  x_billing_direction VARCHAR2(300 BYTE),
  x_resolution_url VARCHAR2(300 BYTE),
  x_update_date DATE,
  x_update_user VARCHAR2(100 BYTE),
  x_device_type VARCHAR2(30 BYTE),
  x_device_os VARCHAR2(30 BYTE),
  x_ppe_enabled VARCHAR2(30 BYTE)
);
COMMENT ON TABLE sa.x_gethandsetinfo IS 'TO STORE HISTORY INFORMATION OF HANDSETS';
COMMENT ON COLUMN sa.x_gethandsetinfo.objid IS 'INTERNAL UNIQUE IDENTIFIER';
COMMENT ON COLUMN sa.x_gethandsetinfo.x_order IS 'RECORD ORDER';
COMMENT ON COLUMN sa.x_gethandsetinfo.x_plan_type IS 'PLAN TYPE: MONTHLY OR PAYGO';
COMMENT ON COLUMN sa.x_gethandsetinfo.x_due_date IS 'SITE_PART.X_EXPIRE_DT';
COMMENT ON COLUMN sa.x_gethandsetinfo.x_triple_minutes IS 'TRIPLE MINUTES PLAN OR NOT';
COMMENT ON COLUMN sa.x_gethandsetinfo.x_safelink IS 'LIFE LINE FLAG';
COMMENT ON COLUMN sa.x_gethandsetinfo.x_brand IS 'BUS ORG ID';
COMMENT ON COLUMN sa.x_gethandsetinfo.x_account_id IS 'TABLE_WEB_USER.OBJID ';
COMMENT ON COLUMN sa.x_gethandsetinfo.x_redeem_in_last_90_days IS 'WAS A REDEMPTION CARD REDEEMED IN THE LAST  90 days OR NOT';
COMMENT ON COLUMN sa.x_gethandsetinfo.x_balance IS 'UNITS WATER MARK   ';
COMMENT ON COLUMN sa.x_gethandsetinfo.x_balance_type IS 'TYPES FOR UNITS WATER MARK (<,>,OR =)';
COMMENT ON COLUMN sa.x_gethandsetinfo.x_auto_refill IS 'ENROLLED IN X_PROGRAM_ENROLLED OR NOT';
COMMENT ON COLUMN sa.x_gethandsetinfo.x_billing_direction IS 'AIRTIME OR CREDIT CARD STORE';
COMMENT ON COLUMN sa.x_gethandsetinfo.x_resolution_url IS 'URL FOR LANDING PAGE';
COMMENT ON COLUMN sa.x_gethandsetinfo.x_update_date IS 'DATE UPDATED';
COMMENT ON COLUMN sa.x_gethandsetinfo.x_update_user IS 'USER WHO UPDATED IT';
COMMENT ON COLUMN sa.x_gethandsetinfo.x_device_type IS 'NEW SEARCH FILTER BASED ON PART_CLASS DEVICE TYP';
COMMENT ON COLUMN sa.x_gethandsetinfo.x_device_os IS 'NEW SEARCH FILTER BASED ON PART_CLASS DEVICE OS';
COMMENT ON COLUMN sa.x_gethandsetinfo.x_ppe_enabled IS 'NEW SEARCH FILTER BASED ON PART_CLASS IF PHONE IS OR IS NOT A PRE PAID ENGINE PHONE.';