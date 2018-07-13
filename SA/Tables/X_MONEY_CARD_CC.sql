CREATE TABLE sa.x_money_card_cc (
  objid NUMBER,
  x_esn VARCHAR2(30 BYTE),
  x_usage_counter NUMBER,
  x_last_modified_date DATE,
  x_money_card2creditcard NUMBER,
  x_money_card2promo_grpdtl NUMBER,
  x_money_card2promotion NUMBER
);
COMMENT ON TABLE sa.x_money_card_cc IS 'This is extension table for Table_X_Credit_Card which will be used to identify Money Card';
COMMENT ON COLUMN sa.x_money_card_cc.objid IS 'Internal sequential Number';
COMMENT ON COLUMN sa.x_money_card_cc.x_esn IS 'ESN';
COMMENT ON COLUMN sa.x_money_card_cc.x_usage_counter IS 'Used to see how many times the system provided Money Card Discount. ';
COMMENT ON COLUMN sa.x_money_card_cc.x_last_modified_date IS 'Date when the transaction last modified in this table';
COMMENT ON COLUMN sa.x_money_card_cc.x_money_card2creditcard IS 'Reference to objid of Table_X_Credit_Card table.';
COMMENT ON COLUMN sa.x_money_card_cc.x_money_card2promo_grpdtl IS 'Reference to objid of X_Promotion_Group_Dtl table.';
COMMENT ON COLUMN sa.x_money_card_cc.x_money_card2promotion IS 'Reference to objid of Table_X_Promotion.';