CREATE TABLE sa.x_promotion_group_dtl (
  objid NUMBER,
  description VARCHAR2(15 BYTE),
  x_status VARCHAR2(20 BYTE),
  x_promo_grpdtl2promo_grp NUMBER
);
COMMENT ON TABLE sa.x_promotion_group_dtl IS 'This is Detail table of Promotion Group which will be used to identify the Money Card (Credit Card).';
COMMENT ON COLUMN sa.x_promotion_group_dtl.objid IS 'Internal sequential Number';
COMMENT ON COLUMN sa.x_promotion_group_dtl.description IS 'Bean Number (Initial n digit of Credit Card that will be used to Identify Money Card)';
COMMENT ON COLUMN sa.x_promotion_group_dtl.x_status IS 'Status of the Promotion Group Detail. ';
COMMENT ON COLUMN sa.x_promotion_group_dtl.x_promo_grpdtl2promo_grp IS 'Reference to objid of Table_X_Promotion_Group table.';