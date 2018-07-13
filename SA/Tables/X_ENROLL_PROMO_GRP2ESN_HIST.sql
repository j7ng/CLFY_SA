CREATE TABLE sa.x_enroll_promo_grp2esn_hist (
  objid NUMBER,
  x_start_date DATE,
  x_end_date DATE,
  x_action_date DATE,
  x_action_type VARCHAR2(30 BYTE),
  x_esn VARCHAR2(30 BYTE),
  promo_grp2esn_objid NUMBER,
  promo_objid NUMBER,
  program_enrolled_objid NUMBER,
  x_holiday_promo_balance NUMBER(22)
);
COMMENT ON TABLE sa.x_enroll_promo_grp2esn_hist IS 'TABLE IS USED DURING UPGRADES / WARRANTY EXCHANGES TO TRANSFER ENROLLMENT BENEFITS FROM ONE ESN TO THE OTHER';
COMMENT ON COLUMN sa.x_enroll_promo_grp2esn_hist.objid IS 'INTERNAL RECORD ID ';
COMMENT ON COLUMN sa.x_enroll_promo_grp2esn_hist.x_start_date IS 'DATE THE PROMOTION WAS ENROLLED';
COMMENT ON COLUMN sa.x_enroll_promo_grp2esn_hist.x_end_date IS 'DATE THE PROMOTION WAS DE-ENROLLED';
COMMENT ON COLUMN sa.x_enroll_promo_grp2esn_hist.x_action_date IS 'DATE THE ACTION TOOK PLACE';
COMMENT ON COLUMN sa.x_enroll_promo_grp2esn_hist.x_action_type IS 'TYPE OF ACTION (UPGRADE, WARRANTY)';
COMMENT ON COLUMN sa.x_enroll_promo_grp2esn_hist.x_esn IS 'PHONE SERIAL NUMBER ';
COMMENT ON COLUMN sa.x_enroll_promo_grp2esn_hist.promo_grp2esn_objid IS 'REFERENCE TO OBJID OF X_ENROLL_PROMO_GRP2ESN';
COMMENT ON COLUMN sa.x_enroll_promo_grp2esn_hist.promo_objid IS 'REFERENCE TO OBJID OF TABLE_X_PROMOTION';
COMMENT ON COLUMN sa.x_enroll_promo_grp2esn_hist.program_enrolled_objid IS 'REFERENCE TO OBJID OF X_PROGRAM_ENROLLED';