CREATE TABLE sa.x_mtm_pgm_redcard_bonus (
  program_param_objid NUMBER,
  redcard_partnum_objid NUMBER,
  redcard_promo_objid NUMBER
);
ALTER TABLE sa.x_mtm_pgm_redcard_bonus ADD SUPPLEMENTAL LOG GROUP dmtsora362975059_0 (program_param_objid, redcard_partnum_objid, redcard_promo_objid) ALWAYS;