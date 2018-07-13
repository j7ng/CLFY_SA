CREATE TABLE sa.table_x_point_trans (
  objid NUMBER,
  x_trans_date DATE,
  x_min VARCHAR2(30 BYTE),
  x_esn VARCHAR2(30 BYTE),
  x_points NUMBER(12,2),
  x_points_category VARCHAR2(50 BYTE),
  x_points_action VARCHAR2(50 BYTE),
  points_action_reason VARCHAR2(2000 BYTE),
  point_trans2ref_table_objid NUMBER,
  ref_table_name VARCHAR2(30 BYTE),
  point_trans2service_plan NUMBER,
  point_trans2point_account NUMBER,
  point_trans2purchase_objid NUMBER,
  purchase_table_name VARCHAR2(30 BYTE),
  point_trans2site_part NUMBER,
  point_trans2benefit NUMBER,
  point_display_reason VARCHAR2(2000 BYTE)
);
COMMENT ON COLUMN sa.table_x_point_trans.objid IS 'UNIQUE RECORD IDENTIFIER';
COMMENT ON COLUMN sa.table_x_point_trans.x_trans_date IS 'POINTS TRANSACTION DATE';
COMMENT ON COLUMN sa.table_x_point_trans.x_min IS 'MIN';
COMMENT ON COLUMN sa.table_x_point_trans.x_esn IS 'ESN ASSOCIATED WITH MIN';
COMMENT ON COLUMN sa.table_x_point_trans.x_points IS 'HOW MANY POINTS INVOLVED IN THIS TRANSACTION';
COMMENT ON COLUMN sa.table_x_point_trans.x_points_category IS 'CATEGORY OF THE POINT LIKE REWARDS / BONUS ETC.';
COMMENT ON COLUMN sa.table_x_point_trans.x_points_action IS 'ACTION TAKEN ON POINTS LIKE ADD / DEDUCT / EXPIRY / EXPIRED / REFUND ETC.';
COMMENT ON COLUMN sa.table_x_point_trans.points_action_reason IS 'DESCRIPTION OF ACTION TAKEN ON POINTS';
COMMENT ON COLUMN sa.table_x_point_trans.point_trans2ref_table_objid IS 'REFERS OBJID of TABLE NAME MENTIONED IN COLUMN=REF_TABLE_NAME (REFUND RECORD)OR the TAS userID  who compensated the points for customer';
COMMENT ON COLUMN sa.table_x_point_trans.ref_table_name IS 'TABLE NAME TO WHICH POINT_TRANS2REF_TABLE_OBJID REFERS';
COMMENT ON COLUMN sa.table_x_point_trans.point_trans2service_plan IS 'WHICH SERVICE PLAN PROVIDED THE POINTS';
COMMENT ON COLUMN sa.table_x_point_trans.point_trans2point_account IS 'REFERS TABLE_X_POINT_ACCOUNT.OBJID';
COMMENT ON COLUMN sa.table_x_point_trans.point_trans2purchase_objid IS 'REFERS OBJID of TABLE_X_PURCH_HDR / X_PROGRAM_PURCH_HDR / TABLE_X_RED_CARD - (SALES RECORD )';
COMMENT ON COLUMN sa.table_x_point_trans.purchase_table_name IS 'The table name to which POINT_TRANS2PURCHASE_OBJID refers';
COMMENT ON COLUMN sa.table_x_point_trans.point_trans2site_part IS 'Refers Table_site_part.Objid';
COMMENT ON COLUMN sa.table_x_point_trans.point_trans2benefit IS 'reference to the benefit that customer has earned. refers Table_X_Benefits.Objid';
COMMENT ON COLUMN sa.table_x_point_trans.point_display_reason IS 'Text describing the point transaction reason to show on user interface';