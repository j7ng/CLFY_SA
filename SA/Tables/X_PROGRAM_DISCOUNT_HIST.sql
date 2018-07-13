CREATE TABLE sa.x_program_discount_hist (
  objid NUMBER,
  x_discount_amount NUMBER(10,2),
  pgm_discount2x_promo NUMBER,
  pgm_discount2pgm_enrolled NUMBER,
  pgm_discount2prog_hdr NUMBER,
  pgm_discount2web_user NUMBER
);
ALTER TABLE sa.x_program_discount_hist ADD SUPPLEMENTAL LOG GROUP dmtsora1478512248_0 (objid, pgm_discount2pgm_enrolled, pgm_discount2prog_hdr, pgm_discount2web_user, pgm_discount2x_promo, x_discount_amount) ALWAYS;
COMMENT ON TABLE sa.x_program_discount_hist IS 'Transaction log for discounts applied to billing programs accounts';
COMMENT ON COLUMN sa.x_program_discount_hist.x_discount_amount IS 'Discount Dollar Amount';
COMMENT ON COLUMN sa.x_program_discount_hist.pgm_discount2x_promo IS 'Reference to objid table_x_promotion';
COMMENT ON COLUMN sa.x_program_discount_hist.pgm_discount2pgm_enrolled IS 'Reference to objid x_program_enrolled';
COMMENT ON COLUMN sa.x_program_discount_hist.pgm_discount2prog_hdr IS 'Reference to objid x_program_parameters';
COMMENT ON COLUMN sa.x_program_discount_hist.pgm_discount2web_user IS 'Reference to objid table_web_user';