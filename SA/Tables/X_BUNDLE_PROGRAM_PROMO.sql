CREATE TABLE sa.x_bundle_program_promo (
  objid NUMBER NOT NULL,
  x_promo_objid NUMBER NOT NULL,
  x_promo_code VARCHAR2(10 BYTE),
  x_parent_prog_param_objid NUMBER NOT NULL,
  x_parent_prog_name VARCHAR2(60 BYTE),
  x_child_prog_param_objid NUMBER NOT NULL,
  x_child_prog_name VARCHAR2(60 BYTE),
  x_bundle_start_date DATE,
  x_bundle_end_date DATE,
  x_created_user VARCHAR2(50 BYTE),
  x_created_date DATE,
  x_last_change_user VARCHAR2(50 BYTE),
  x_last_change_date DATE
);
COMMENT ON TABLE sa.x_bundle_program_promo IS 'This table will contain data required for providing bundle promotion. It links parent child billing programs and promotion';
COMMENT ON COLUMN sa.x_bundle_program_promo.objid IS 'Primary key column of X_BUNDLE_PROGRAM_PROMO table';
COMMENT ON COLUMN sa.x_bundle_program_promo.x_promo_objid IS 'Promotion objid';
COMMENT ON COLUMN sa.x_bundle_program_promo.x_parent_prog_param_objid IS 'Program parameters objid of parent billing program';
COMMENT ON COLUMN sa.x_bundle_program_promo.x_parent_prog_name IS 'Parent Billing program name';
COMMENT ON COLUMN sa.x_bundle_program_promo.x_child_prog_param_objid IS 'Program parameters objid of child billing program';
COMMENT ON COLUMN sa.x_bundle_program_promo.x_child_prog_name IS 'Child Billing program name';
COMMENT ON COLUMN sa.x_bundle_program_promo.x_bundle_start_date IS 'Date on which this bundle is starting';
COMMENT ON COLUMN sa.x_bundle_program_promo.x_bundle_end_date IS 'Date on which this bundle is ending';
COMMENT ON COLUMN sa.x_bundle_program_promo.x_created_user IS 'User who created this record ';
COMMENT ON COLUMN sa.x_bundle_program_promo.x_created_date IS 'Date when this record is created ';
COMMENT ON COLUMN sa.x_bundle_program_promo.x_last_change_user IS 'User who updated this record ';
COMMENT ON COLUMN sa.x_bundle_program_promo.x_last_change_date IS 'Date when this record is updated ';