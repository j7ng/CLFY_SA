CREATE TABLE sa.x_esn_ber_place_holder (
  objid NUMBER,
  x_esn VARCHAR2(30 BYTE),
  x_model VARCHAR2(30 BYTE),
  x_reserved_flag VARCHAR2(30 BYTE),
  x_last_reserved_date DATE
);
COMMENT ON TABLE sa.x_esn_ber_place_holder IS 'THIS TABLE IS USED TO PASS PLACE HOLDER ESN S TO SPRINT TO IMPORT NEW BYOP PHONES';
COMMENT ON COLUMN sa.x_esn_ber_place_holder.objid IS 'UNIQUE IDENTIFIER';
COMMENT ON COLUMN sa.x_esn_ber_place_holder.x_esn IS 'PLACE HOLDER ESN';
COMMENT ON COLUMN sa.x_esn_ber_place_holder.x_model IS 'MODEL OF SPRINT PHONE';
COMMENT ON COLUMN sa.x_esn_ber_place_holder.x_reserved_flag IS 'IS PLACE HOLDER ESN IN USE Y/N';
COMMENT ON COLUMN sa.x_esn_ber_place_holder.x_last_reserved_date IS 'WHEN PLACE HOLD ESN WAS PUT INTO USE';