CREATE TABLE sa.x_b2b_promo_org (
  objid NUMBER(10) NOT NULL,
  x_commerce_id VARCHAR2(150 BYTE),
  x_promo_objid NUMBER(30),
  x_promo_code VARCHAR2(30 BYTE),
  x_promo_group_objid NUMBER(30),
  x_start_date DATE,
  x_end_date DATE,
  date_created DATE DEFAULT SYSDATE NOT NULL,
  user_created VARCHAR2(50 BYTE) NOT NULL,
  date_updated DATE DEFAULT SYSDATE NOT NULL,
  user_updated VARCHAR2(50 BYTE) NOT NULL,
  CONSTRAINT x_b2b_promo_org_pk PRIMARY KEY (objid)
);
COMMENT ON TABLE sa.x_b2b_promo_org IS 'This table links between promotions and organizations';
COMMENT ON COLUMN sa.x_b2b_promo_org.objid IS 'Objid - Primary key';
COMMENT ON COLUMN sa.x_b2b_promo_org.x_commerce_id IS 'This is B2B - Organization Id. On Clarify side, it is stored in SA.TABLE_SITE.X_COMMERCE_ID';
COMMENT ON COLUMN sa.x_b2b_promo_org.x_promo_objid IS 'Objid from SA.TABLE_X_PROMOTION';
COMMENT ON COLUMN sa.x_b2b_promo_org.x_promo_code IS 'Promotion code from SA.TABLE_X_PROMOTION';
COMMENT ON COLUMN sa.x_b2b_promo_org.x_promo_group_objid IS 'Objid from SA.TABLE_X_PROMOTION_GROUP';
COMMENT ON COLUMN sa.x_b2b_promo_org.x_start_date IS 'Date from which this promotion should start for this org';
COMMENT ON COLUMN sa.x_b2b_promo_org.x_end_date IS 'Date on which this promotion should end for this org';
COMMENT ON COLUMN sa.x_b2b_promo_org.date_created IS 'Date on which this record is inserted';
COMMENT ON COLUMN sa.x_b2b_promo_org.user_created IS 'User who created this record';
COMMENT ON COLUMN sa.x_b2b_promo_org.date_updated IS 'Date on whihc this record is updated';
COMMENT ON COLUMN sa.x_b2b_promo_org.user_updated IS 'User who updated this record';