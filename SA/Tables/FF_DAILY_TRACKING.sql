CREATE TABLE sa.ff_daily_tracking (
  return_tracking_number VARCHAR2(50 BYTE),
  load_date DATE
);
COMMENT ON TABLE sa.ff_daily_tracking IS 'Stores the tracking numbers received from Fedex - which indicates handset has been dropped off by customer at Fedex';
COMMENT ON COLUMN sa.ff_daily_tracking.return_tracking_number IS 'the return tracking number of handset being shipped back to Tracfone';