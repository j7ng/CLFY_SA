CREATE TABLE sa.table_x_promo_text (
  objid NUMBER,
  promo_text2promotion NUMBER,
  x_promotion_text LONG
);
ALTER TABLE sa.table_x_promo_text ADD SUPPLEMENTAL LOG GROUP dmtsora907535133_0 (objid, promo_text2promotion) ALWAYS;
COMMENT ON TABLE sa.table_x_promo_text IS 'Contains the text that is associated with a promotion';
COMMENT ON COLUMN sa.table_x_promo_text.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_x_promo_text.promo_text2promotion IS 'Promotion Relation to Text';
COMMENT ON COLUMN sa.table_x_promo_text.x_promotion_text IS 'Text used for promotion';