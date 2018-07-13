CREATE TABLE sa.mtm_affpart_prog_promo (
  partner_name VARCHAR2(100 BYTE),
  mtm2busorg NUMBER,
  mtm2prog NUMBER,
  mtm2promo NUMBER
);
COMMENT ON COLUMN sa.mtm_affpart_prog_promo.partner_name IS 'Partner Name from TABLE_AFFILIATED_PARTNERS';
COMMENT ON COLUMN sa.mtm_affpart_prog_promo.mtm2busorg IS 'BusOrg Objid from TABLE_BUS_ORG';
COMMENT ON COLUMN sa.mtm_affpart_prog_promo.mtm2prog IS 'Program Objid from X_PROGRAM_PARAMETERS';
COMMENT ON COLUMN sa.mtm_affpart_prog_promo.mtm2promo IS 'Promo Objid from TABLE_X_PROMOTION';