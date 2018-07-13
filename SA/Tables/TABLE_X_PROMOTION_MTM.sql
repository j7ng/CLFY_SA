CREATE TABLE sa.table_x_promotion_mtm (
  objid NUMBER,
  x_promo_mtm2x_promo_group NUMBER,
  x_promo_mtm2x_promotion NUMBER
);
ALTER TABLE sa.table_x_promotion_mtm ADD SUPPLEMENTAL LOG GROUP dmtsora1862601116_0 (objid, x_promo_mtm2x_promotion, x_promo_mtm2x_promo_group) ALWAYS;
COMMENT ON TABLE sa.table_x_promotion_mtm IS 'Stores the Many to Many Relation Between Promotion and Promotion Group';
COMMENT ON COLUMN sa.table_x_promotion_mtm.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_x_promotion_mtm.x_promo_mtm2x_promo_group IS 'relation to promotion group';
COMMENT ON COLUMN sa.table_x_promotion_mtm.x_promo_mtm2x_promotion IS 'relation to promotion';