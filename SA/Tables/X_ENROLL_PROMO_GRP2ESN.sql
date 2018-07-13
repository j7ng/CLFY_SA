CREATE TABLE sa.x_enroll_promo_grp2esn (
  objid NUMBER,
  x_esn_driven VARCHAR2(1 BYTE),
  x_esn VARCHAR2(30 BYTE),
  promo_group_objid NUMBER,
  promo_objid NUMBER,
  program_enrolled_objid NUMBER,
  x_start_date DATE,
  x_end_date DATE,
  x_priority NUMBER,
  x_holiday_promo_balance NUMBER(22)
);
COMMENT ON TABLE sa.x_enroll_promo_grp2esn IS 'TABLE IS USED TO MARK THE ELIGIBILITY OR ENROLLMENT OF A PARTICULAR ESN INTO A GIVEN PROMOTION';
COMMENT ON COLUMN sa.x_enroll_promo_grp2esn.objid IS 'INTERNAL RECORD ID ';
COMMENT ON COLUMN sa.x_enroll_promo_grp2esn.x_esn_driven IS 'SET TO Y WHEN ELIGIBLE VIA A ESN PROMOTION, ANY OTHER VALUE MEANS THE RECORD WAS CREATED FROM A PROGRAM PROMOTION ';
COMMENT ON COLUMN sa.x_enroll_promo_grp2esn.x_esn IS 'PHONE SERIAL NUMBER';
COMMENT ON COLUMN sa.x_enroll_promo_grp2esn.promo_group_objid IS 'REFERENCE TO OBJID OF TABLE_X_PROMOTION_GROUP';
COMMENT ON COLUMN sa.x_enroll_promo_grp2esn.promo_objid IS 'REFERENCE TO OBJID OF TABLE_X_PROMOTION';
COMMENT ON COLUMN sa.x_enroll_promo_grp2esn.program_enrolled_objid IS 'REFERENCE TO OBJID OF X_PROGRAM_ENROLLED. SET WHEN THE CUSTOMER ENROLLS';
COMMENT ON COLUMN sa.x_enroll_promo_grp2esn.x_start_date IS 'DATE THE PROMOTION WAS ENROLLED, IF NULL RECORD IS AN ELIGIBILITY';
COMMENT ON COLUMN sa.x_enroll_promo_grp2esn.x_end_date IS 'DATE THE PROMOTION WAS DE-ENROLLED. IF NULL, PROMO IS ACTIVE';
COMMENT ON COLUMN sa.x_enroll_promo_grp2esn.x_priority IS 'PROMOTION PRIORITY';