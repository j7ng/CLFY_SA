CREATE TABLE sa.x_promotion_relation (
  objid NUMBER,
  promo_id NUMBER,
  related_promo_id NUMBER,
  relationship_type VARCHAR2(60 BYTE)
);
COMMENT ON TABLE sa.x_promotion_relation IS 'TO LINK RELATIONS BETWEEN PROMOTIONS.';
COMMENT ON COLUMN sa.x_promotion_relation.objid IS 'INTERNAL RECORD ID';
COMMENT ON COLUMN sa.x_promotion_relation.promo_id IS 'OBJID of a promotion in TABLE_X_PROMOTION';
COMMENT ON COLUMN sa.x_promotion_relation.related_promo_id IS 'OBJID  of the promotion in TABLE_X_PROMOTION related to the one identified by PROMO_ID';
COMMENT ON COLUMN sa.x_promotion_relation.relationship_type IS 'Relationship: PARENT-CHILD OR REPLACEMENT';