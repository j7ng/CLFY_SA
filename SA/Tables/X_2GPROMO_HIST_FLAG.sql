CREATE TABLE sa.x_2gpromo_hist_flag (
  objid NUMBER,
  x_esn VARCHAR2(30 BYTE),
  promoflag2x_promotion NUMBER,
  update_stamp DATE
);
COMMENT ON TABLE sa.x_2gpromo_hist_flag IS 'TABLE TO KEEP THE 2G PHONE HISTORY FOR UPGRADE PROMOTIONS';
COMMENT ON COLUMN sa.x_2gpromo_hist_flag.objid IS 'Internal record number';
COMMENT ON COLUMN sa.x_2gpromo_hist_flag.x_esn IS 'PART SERIAL NUMBER';
COMMENT ON COLUMN sa.x_2gpromo_hist_flag.promoflag2x_promotion IS 'History of redeemed promotions by code';
COMMENT ON COLUMN sa.x_2gpromo_hist_flag.update_stamp IS 'UPDATE TIME';