CREATE TABLE sa.x_promocode_hist (
  promo_code VARCHAR2(10 BYTE),
  transact_type VARCHAR2(15 BYTE),
  source_system VARCHAR2(10 BYTE),
  zip_code VARCHAR2(5 BYTE),
  esn VARCHAR2(30 BYTE),
  promo_units NUMBER,
  access_days NUMBER,
  error_num VARCHAR2(5 BYTE),
  time_stamp DATE,
  x_sms NUMBER(22),
  x_data_mb NUMBER(22),
  x_device_type VARCHAR2(60 BYTE)
);
ALTER TABLE sa.x_promocode_hist ADD SUPPLEMENTAL LOG GROUP dmtsora2108072330_0 (access_days, error_num, esn, promo_code, promo_units, source_system, time_stamp, transact_type, zip_code) ALWAYS;
COMMENT ON TABLE sa.x_promocode_hist IS 'Promocode usage history';
COMMENT ON COLUMN sa.x_promocode_hist.promo_code IS 'Promo Code, reference table_x_promotion';
COMMENT ON COLUMN sa.x_promocode_hist.transact_type IS 'Transaction Type: Purchase,Activation, Redemption, Reactivation';
COMMENT ON COLUMN sa.x_promocode_hist.source_system IS 'Source Application: WEB,WEBCSR,IVR,OTA';
COMMENT ON COLUMN sa.x_promocode_hist.zip_code IS 'Zip Code';
COMMENT ON COLUMN sa.x_promocode_hist.esn IS 'Phone Serial Number';
COMMENT ON COLUMN sa.x_promocode_hist.promo_units IS 'units Granted';
COMMENT ON COLUMN sa.x_promocode_hist.access_days IS 'Days Granted';
COMMENT ON COLUMN sa.x_promocode_hist.error_num IS 'Error Number, optional';
COMMENT ON COLUMN sa.x_promocode_hist.time_stamp IS 'Timestamp';
COMMENT ON COLUMN sa.x_promocode_hist.x_sms IS 'Bonus Sms';
COMMENT ON COLUMN sa.x_promocode_hist.x_data_mb IS 'Bonus Data in mb';
COMMENT ON COLUMN sa.x_promocode_hist.x_device_type IS 'Device type';