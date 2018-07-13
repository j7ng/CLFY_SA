CREATE TABLE sa.x_pre_val_purch_dtl (
  objid NUMBER NOT NULL,
  x_part_numbers VARCHAR2(30 BYTE),
  x_card_qty NUMBER(4),
  x_esn VARCHAR2(20 BYTE),
  x_program_type VARCHAR2(30 BYTE),
  x_program_name VARCHAR2(40 BYTE),
  x_cc_schedule_date VARCHAR2(30 BYTE),
  x_count_esn_primary VARCHAR2(3 BYTE),
  x_count_esn_secondary VARCHAR2(3 BYTE),
  x_cc_scheduled VARCHAR2(30 BYTE),
  x_preval_purch2promotion NUMBER,
  x_promo_code VARCHAR2(10 BYTE),
  x_preval_pur_dtl2program NUMBER,
  x_preval_pur_dtl2pre_purch_hdr NUMBER,
  x_idn_user_change_last VARCHAR2(50 BYTE),
  x_dte_change_last DATE
);
COMMENT ON TABLE sa.x_pre_val_purch_dtl IS 'This table is created to log data related to failed transactions - details ';
COMMENT ON COLUMN sa.x_pre_val_purch_dtl.objid IS 'Primary key column of X_PRE_VAL_PURCH_DTL table';
COMMENT ON COLUMN sa.x_pre_val_purch_dtl.x_part_numbers IS 'Redemption card part number ';
COMMENT ON COLUMN sa.x_pre_val_purch_dtl.x_card_qty IS 'Number of redemption cards ';
COMMENT ON COLUMN sa.x_pre_val_purch_dtl.x_esn IS 'ESN ';
COMMENT ON COLUMN sa.x_pre_val_purch_dtl.x_program_type IS 'Program type ';
COMMENT ON COLUMN sa.x_pre_val_purch_dtl.x_program_name IS 'Program name ';
COMMENT ON COLUMN sa.x_pre_val_purch_dtl.x_cc_schedule_date IS 'Credit card Scheduled date ';
COMMENT ON COLUMN sa.x_pre_val_purch_dtl.x_count_esn_primary IS 'Number of primary ESNs ';
COMMENT ON COLUMN sa.x_pre_val_purch_dtl.x_count_esn_secondary IS 'Number of secondary ESNs ';
COMMENT ON COLUMN sa.x_pre_val_purch_dtl.x_cc_scheduled IS 'Credit card scheduled ';
COMMENT ON COLUMN sa.x_pre_val_purch_dtl.x_preval_purch2promotion IS 'Objid of TABLE_X_PROMOTION ';
COMMENT ON COLUMN sa.x_pre_val_purch_dtl.x_promo_code IS 'Promotion code ';
COMMENT ON COLUMN sa.x_pre_val_purch_dtl.x_preval_pur_dtl2program IS 'Objid of TABLE_X_PROGRAM ';
COMMENT ON COLUMN sa.x_pre_val_purch_dtl.x_preval_pur_dtl2pre_purch_hdr IS 'Objid id reference to X_PRE_VAL_PURCH_HDR ';
COMMENT ON COLUMN sa.x_pre_val_purch_dtl.x_idn_user_change_last IS 'User who logged this record into DB. ';
COMMENT ON COLUMN sa.x_pre_val_purch_dtl.x_dte_change_last IS 'Date when this record is entered into DB. ';