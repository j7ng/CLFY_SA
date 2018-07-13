CREATE TABLE sa.x_x3xmn_offer (
  at_card VARCHAR2(100 BYTE),
  at_units NUMBER,
  at_days NUMBER,
  offered_price NUMBER,
  offered_units NUMBER,
  offered_days VARCHAR2(100 BYTE)
);
COMMENT ON TABLE sa.x_x3xmn_offer IS 'TABLE IS CREATED TO OFFER NEW OFFERS WHEN A X3XMIN CUSTOMER TRIES TO PURCHASE A X3XMIN CARD ';
COMMENT ON COLUMN sa.x_x3xmn_offer.at_card IS 'DESCRIPTION OF THE CARD';
COMMENT ON COLUMN sa.x_x3xmn_offer.at_units IS 'UNITS PROVIDED BY CARD';
COMMENT ON COLUMN sa.x_x3xmn_offer.at_days IS 'DAYS PROVIDED BY THE CARD';
COMMENT ON COLUMN sa.x_x3xmn_offer.offered_price IS 'RETAIL PRICE OF THE OFFER';
COMMENT ON COLUMN sa.x_x3xmn_offer.offered_units IS 'UNITS OFFERED';
COMMENT ON COLUMN sa.x_x3xmn_offer.offered_days IS 'DAYS OFFERED';