CREATE TABLE sa.table_x_point_account (
  objid NUMBER,
  x_min VARCHAR2(30 BYTE),
  x_esn VARCHAR2(30 BYTE),
  total_points NUMBER(12,2),
  x_points_category VARCHAR2(50 BYTE),
  x_last_calc_date DATE,
  account_status VARCHAR2(30 BYTE),
  account_status_reason VARCHAR2(500 BYTE),
  bus_org_objid NUMBER,
  subscriber_uid VARCHAR2(50 BYTE),
  x_expiry_date DATE
);
COMMENT ON COLUMN sa.table_x_point_account.objid IS 'UNIQUE RECORD IDENTIFIER';
COMMENT ON COLUMN sa.table_x_point_account.x_min IS 'MIN';
COMMENT ON COLUMN sa.table_x_point_account.x_esn IS 'ESN ASSOCIATED WITH MIN';
COMMENT ON COLUMN sa.table_x_point_account.total_points IS 'TOTAL POINTS AVAILABLE THAT CAN BE CONVERTED INTO MONEY';
COMMENT ON COLUMN sa.table_x_point_account.x_points_category IS 'CATEGORY OF THE POINT LIKE REWARDS / BONUS ETC.';
COMMENT ON COLUMN sa.table_x_point_account.x_last_calc_date IS 'DATE WHEN THE TOTAL POINTS WHERE CALCULATED';
COMMENT ON COLUMN sa.table_x_point_account.account_status IS 'Indicates whether account is active or Inactive';
COMMENT ON COLUMN sa.table_x_point_account.account_status_reason IS 'Describes the reason why account get inactivated';
COMMENT ON COLUMN sa.table_x_point_account.bus_org_objid IS 'INDICATES THE CURRENT BRAND OF MIN and ESN';
COMMENT ON COLUMN sa.table_x_point_account.subscriber_uid IS 'Unique subscriber id that remains with points no matter if esn/min is changed';
COMMENT ON COLUMN sa.table_x_point_account.x_expiry_date IS 'Date when the total points will expire and cannot be used; this date will be populated as deactivation date + X days';