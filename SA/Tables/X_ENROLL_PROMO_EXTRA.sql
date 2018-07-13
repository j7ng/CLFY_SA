CREATE TABLE sa.x_enroll_promo_extra (
  objid NUMBER,
  program_objid NUMBER,
  promo_objid NUMBER,
  extra_promo_objid NUMBER
);
COMMENT ON TABLE sa.x_enroll_promo_extra IS 'TO STORE INFO OF PROMOTION HAS EXTRA PROMOTION FOR ENROLLMENT';
COMMENT ON COLUMN sa.x_enroll_promo_extra.objid IS 'INTERNAL RECORD ID';
COMMENT ON COLUMN sa.x_enroll_promo_extra.program_objid IS 'Referece to OBJID from table x_ program_parameters';
COMMENT ON COLUMN sa.x_enroll_promo_extra.promo_objid IS 'Referece to OBJID From table_x_promotion';
COMMENT ON COLUMN sa.x_enroll_promo_extra.extra_promo_objid IS 'Referece to OBJID from table_x_promotion (only if promo has enrollment promotion associated)';