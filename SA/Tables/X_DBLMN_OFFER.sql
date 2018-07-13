CREATE TABLE sa.x_dblmn_offer (
  at_card VARCHAR2(100 BYTE),
  at_units NUMBER,
  at_days NUMBER,
  offered_price NUMBER,
  offered_units NUMBER,
  offered_days VARCHAR2(100 BYTE)
);
COMMENT ON TABLE sa.x_dblmn_offer IS 'table is created to offer new offers when a dblmin customer tries to purchase a dblmin card';
COMMENT ON COLUMN sa.x_dblmn_offer.at_card IS 'Description of the Card';
COMMENT ON COLUMN sa.x_dblmn_offer.at_units IS 'Units provided by Card';
COMMENT ON COLUMN sa.x_dblmn_offer.at_days IS 'Days provided by the Card';
COMMENT ON COLUMN sa.x_dblmn_offer.offered_price IS 'Retail Price of the offer.';
COMMENT ON COLUMN sa.x_dblmn_offer.offered_units IS 'Units Offered';
COMMENT ON COLUMN sa.x_dblmn_offer.offered_days IS 'Days Offered';