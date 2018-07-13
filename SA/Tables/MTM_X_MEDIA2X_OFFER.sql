CREATE TABLE sa.mtm_x_media2x_offer (
  x_media2x_offer NUMBER,
  x_offer2x_media NUMBER
);
COMMENT ON TABLE sa.mtm_x_media2x_offer IS 'Media content info for low balance offers';
COMMENT ON COLUMN sa.mtm_x_media2x_offer.x_media2x_offer IS 'Reference to objid of table X_LB_OFFER';
COMMENT ON COLUMN sa.mtm_x_media2x_offer.x_offer2x_media IS 'Reference to objid of table X_LB_MEDIA_LIBRARY';